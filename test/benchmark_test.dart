import 'dart:async';
import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:test/test.dart';
import 'package:obsidian_vault_datasource/obsidian_vault_datasource.dart';

void main() {
  group('Performance & Stress Tests', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('obsidian_bench_');
    });

    tearDown(() async {
      try {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      } catch (_) {}
    });

    test('100 notes loads under 2 seconds', () async {
      final vault = ObsidianVault.create(
        path: tempDir.path,
        name: 'benchmark',
      );

      for (var i = 0; i < 100; i++) {
        await vault
            .createNote(
              title: 'Note $i',
              content: '# Note $i\n\nContent for note $i',
            )
            .run();
      }

      final stopwatch = Stopwatch()..start();
      final result = await ObsidianVault.load(path: tempDir.path).run();
      stopwatch.stop();

      result.fold(
        (f) => fail(f.toString()),
        (v) {
          expect(v.allNotes.length, 100);
          expect(stopwatch.elapsedMilliseconds, lessThan(2000));
        },
      );
    }, timeout: const Timeout(Duration(seconds: 30)));

    test('100 notes writes under 3 seconds', () async {
      final vault = ObsidianVault.create(
        path: tempDir.path,
        name: 'benchmark',
      );

      final stopwatch = Stopwatch()..start();
      for (var i = 0; i < 100; i++) {
        await vault
            .createNote(
              title: 'Note $i',
              content: '# Note $i\n\nContent for note $i',
            )
            .run();
      }
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(3000));
    }, timeout: const Timeout(Duration(seconds: 30)));

    test('100 concurrent writes completes', () async {
      final vault = ObsidianVault.create(
        path: tempDir.path,
        name: 'benchmark',
      );

      final futures = <Future<Either<Failure, ObsidianNote>>>[];
      for (var i = 0; i < 100; i++) {
        futures.add(vault
            .createNote(
              title: 'Note $i',
              content: '# Note $i',
            )
            .run());
      }

      final results = await Future.wait(futures);
      final successCount = results.where((r) => r.isRight()).length;

      expect(successCount, 100);
    }, timeout: const Timeout(Duration(seconds: 30)));

    test('concurrent writes: first wins, others fail', () async {
      final vault = ObsidianVault.create(
        path: tempDir.path,
        name: 'benchmark',
      );

      await vault.createNote(title: 'Shared Note', content: 'First').run();
      await Future.delayed(const Duration(milliseconds: 10));

      final futures = <Future<Either<Failure, ObsidianNote>>>[];
      for (var i = 0; i < 10; i++) {
        futures.add(vault
            .createNote(
              title: 'Shared Note',
              content: 'Attempt $i',
            )
            .run());
      }

      final results = await Future.wait(futures);
      final failures = results.where((r) => r.isLeft()).length;

      expect(failures, greaterThanOrEqualTo(1));
    }, timeout: const Timeout(Duration(seconds: 30)));

    test('overwrite: all writes succeed', () async {
      final vault = ObsidianVault.create(
        path: tempDir.path,
        name: 'benchmark',
      );

      await vault.createNote(title: 'Shared Note', content: 'First').run();

      final futures = <Future<Either<Failure, ObsidianNote>>>[];
      for (var i = 0; i < 10; i++) {
        futures.add(vault
            .createNote(
              title: 'Shared Note',
              content: 'Attempt $i',
              overwrite: true,
            )
            .run());
      }

      final results = await Future.wait(futures);
      final successes = results.where((r) => r.isRight()).length;

      expect(successes, 10);
    }, timeout: const Timeout(Duration(seconds: 30)));

    test('deep folder structure', () async {
      final vault = ObsidianVault.create(
        path: tempDir.path,
        name: 'benchmark',
      );

      final deepPath = '${tempDir.path}/a/b/c/d/e';
      await Directory(deepPath).create(recursive: true);
      await vault
          .createNote(
            title: 'Deep Note',
            content: '# Deep Note',
            path: '$deepPath/Deep Note.md',
          )
          .run();

      final result = await ObsidianVault.load(path: tempDir.path).run();

      result.fold(
        (f) => fail(f.toString()),
        (v) => expect(v.findNote(title: 'Deep Note'), isNotNull),
      );
    }, timeout: const Timeout(Duration(seconds: 30)));

    test('large note (25KB)', () async {
      final largeContent = 'x' * (25 * 1024);

      final vault = ObsidianVault.create(
        path: tempDir.path,
        name: 'benchmark',
      );

      await vault
          .createNote(
            title: 'Large Note',
            content: largeContent,
          )
          .run();

      final result = await ObsidianVault.load(path: tempDir.path).run();

      result.fold(
        (f) => fail(f.toString()),
        (v) {
          final note = v.findNote(title: 'Large Note');
          expect(note!.content.length, 25 * 1024);
        },
      );
    }, timeout: const Timeout(Duration(seconds: 30)));

    test('create note works', () async {
      final vault = ObsidianVault.create(
        path: tempDir.path,
        name: 'benchmark',
      );

      final result = await vault
          .createNote(
            title: 'Test',
            content: '# Test Note\n\nSome content',
          )
          .run();

      expect(result.isRight(), true);
    }, timeout: const Timeout(Duration(seconds: 30)));
  });
}
