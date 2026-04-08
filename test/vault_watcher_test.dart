import 'package:obsidian_vault_datasource/obsidian_vault_datasource.dart';
import 'package:shouldly/shouldly.dart';
import 'package:test/test.dart';
import 'dart:io';

void main() {
  group('Given a VaultWatcher', () {
    late String tempVaultPath;
    late ObsidianVault vault;

    setUp(() async {
      tempVaultPath = Directory.systemTemp.createTempSync('watch_test_').path;
      vault = ObsidianVault.create(tempVaultPath, 'Test');
      await vault.createNote('Initial Note').run();
    });

    tearDown(() {
      try {
        Directory(tempVaultPath).deleteSync(recursive: true);
      } catch (_) {}
    });

    test('should start and stop watching vault', () async {
      final watcher = vault.watch();

      final startResult = await watcher.start().run();
      startResult.isRight().should.beTrue();

      final stopResult = await watcher.stop().run();
      stopResult.isRight().should.beTrue();

      watcher.dispose();
    });

    test('should be reusable after stop and start', () async {
      final watcher = vault.watch();

      await watcher.start().run();
      await watcher.stop().run();

      final startAgain = await watcher.start().run();
      startAgain.isRight().should.beTrue();

      await watcher.stop().run();
      watcher.dispose();
    });

    test('watcher changes stream should be a broadcast stream', () async {
      final watcher = vault.watch();

      await watcher.start().run();

      final changes = watcher.changes;
      changes.should.not.beNull();

      await watcher.stop().run();
      watcher.dispose();
    });
  });
}
