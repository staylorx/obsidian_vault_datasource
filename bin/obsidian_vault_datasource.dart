import 'package:obsidian_vault_datasource/obsidian_vault_datasource.dart';

void main() async {
  final vault = ObsidianVault.create('test_vault', 'Test Vault');

  final noteResult = await vault.createNote('Hello', content: 'World').run();

  noteResult.fold(
    (failure) => print('Error: $failure'),
    (note) => print('Created note: ${note.title}'),
  );

  final refreshed = await vault.refresh().run();
  refreshed.fold(
    (failure) => print('Error refreshing: $failure'),
    (v) {
      final found = v.findNote('Hello');
      print('Found note: ${found?.title}');
    },
  );
}
