import 'package:obsidian_vault_datasource/obsidian_vault_datasource.dart';
import 'package:test/test.dart';
import 'dart:io' show Platform;

void main() {
  group('Given the example vault', () {
    test('should load and find notes', () async {
      final examplePath = 'examples${Platform.pathSeparator}example_vault';

      final adapter = FileSystemAdapter();
      final exists = await adapter.directoryExists(examplePath);
      expect(exists.fold((_) => false, (v) => v), true);

      final vault = ObsidianVault.load(examplePath);
      final refreshed = await vault.refresh().run();
      final loadedVault = refreshed.fold((_) => vault, (v) => v);

      final found = loadedVault.findNote('Welcome to Your Vault');
      expect(found?.title, 'Welcome to Your Vault');
    });

    test('should load notes from nested folders', () async {
      final examplePath = 'examples${Platform.pathSeparator}example_vault';

      final vault = ObsidianVault.load(examplePath);
      final refreshed = await vault.refresh().run();
      final loadedVault = refreshed.fold((_) => vault, (v) => v);

      final allNotes = loadedVault.allNotes;
      expect(allNotes.length, greaterThan(10));

      final hasNestedNotes =
          allNotes.any((n) => n.path?.contains('Meeting Notes') ?? false);
      expect(hasNestedNotes, true);
    });

    test('should parse frontmatter properties from loaded notes', () async {
      final examplePath = 'examples${Platform.pathSeparator}example_vault';

      final vault = ObsidianVault.load(examplePath);
      final refreshed = await vault.refresh().run();
      final loadedVault = refreshed.fold((_) => vault, (v) => v);

      final welcomeNote = loadedVault.findNote('Welcome to Your Vault');
      expect(welcomeNote?.properties.isNotEmpty, true);
      expect(welcomeNote?.properties.any((p) => p.key == 'tags'), true);
    });

    test('should parse links from loaded notes', () async {
      final examplePath = 'examples${Platform.pathSeparator}example_vault';

      final vault = ObsidianVault.load(examplePath);
      final refreshed = await vault.refresh().run();
      final loadedVault = refreshed.fold((_) => vault, (v) => v);

      final welcomeNote = loadedVault.findNote('Welcome to Your Vault');
      expect(welcomeNote?.links.isNotEmpty, true);
    });
  });
}
