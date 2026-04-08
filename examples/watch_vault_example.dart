// ignore_for_file: avoid_print
import 'dart:io';
import 'package:obsidian_vault_datasource/obsidian_vault_datasource.dart';

void main() async {
  final vaultPath = 'examples/example_vault';
  print('Loading vault for watching: $vaultPath\n');

  final vault = ObsidianVault.load(vaultPath);
  final refreshed = await vault.refresh().run();
  final loadedVault = refreshed.fold((_) => vault, (v) => v);

  final watcher = loadedVault.watch();

  final startResult = await watcher.start().run();
  startResult.fold(
    (failure) => print('Failed to start watcher: $failure'),
    (_) => print('Watching for changes...'),
  );

  print('\nOpen another terminal and:');
  print('1. Create a new note in: $vaultPath');
  print('2. Edit an existing note');
  print('3. Delete a note');
  print('\nPress Enter to stop watching...\n');

  final changeSubscription = watcher.changes.listen((change) async {
    print('\n=== Change Detected ===');
    print('Type: ${change.type}');
    print('Path: ${change.path}');

    final refreshResult = await loadedVault.refresh().run();
    refreshResult.fold(
      (failure) => print('Refresh failed: $failure'),
      (v) {
        print('Vault now has ${v.allNotes.length} notes');
        final allTitles = v.allNotes.map((n) => n.title).toList();
        print('Notes: ${allTitles.join(', ')}');
      },
    );
  });

  await stdin.first;

  await watcher.stop().run();
  changeSubscription.cancel();
  watcher.dispose();

  print('\nWatcher stopped.');
}
