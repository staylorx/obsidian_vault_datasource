import 'package:obsidian_vault_datasource/obsidian_vault_datasource.dart';
import 'package:shouldly/shouldly.dart';
import 'package:test/test.dart';
import 'dart:io';

void main() {
  group('Given a VaultWatcher', () {
    group('when starting and stopping', () {
      late String tempVaultPath;
      late ObsidianVault vault;

      setUp(() async {
        tempVaultPath =
            Directory.systemTemp.createTempSync('watcher_test_').path;
        vault = ObsidianVault.create(path: tempVaultPath, name: 'Test');
        await vault.createNote(title: 'Initial Note').run();
      });

      tearDown(() async {
        await Directory(tempVaultPath).delete(recursive: true);
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

        watcher.dispose();
      });

      test('watcher changes stream should be a broadcast stream', () {
        final watcher = vault.watch();
        watcher.changes.isBroadcast.should.beTrue();
        watcher.dispose();
      });
    });
  });
}
