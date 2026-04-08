import 'dart:io' show Platform;
import 'package:obsidian_vault_datasource/obsidian_vault_datasource.dart';
import 'package:shouldly/shouldly.dart';
import 'package:test/test.dart';

void main() {
  group('Given the example vault', () {
    test('should load and find notes', () async {
      final examplePath = 'example${Platform.pathSeparator}example_vault';

      final adapter = FileSystemAdapter();
      final exists = await adapter.directoryExists(examplePath);
      exists.fold((_) => false, (v) => v).should.beTrue();

      final vaultResult = await ObsidianVault.load(path: examplePath).run();
      final loadedVault =
          vaultResult.fold((f) => throw Exception(f.toString()), (v) => v);

      loadedVault
          .findNote(title: 'Welcome to Your Vault')!
          .title
          .should
          .be('Welcome to Your Vault');
    });

    test('should load notes from nested folders', () async {
      final examplePath = 'example${Platform.pathSeparator}example_vault';

      final vaultResult = await ObsidianVault.load(path: examplePath).run();
      final loadedVault =
          vaultResult.fold((f) => throw Exception(f.toString()), (v) => v);

      loadedVault.allNotes.length.should.beGreaterThan(10);

      final hasNestedNotes = loadedVault.allNotes
          .any((n) => n.path?.contains('Meeting Notes') ?? false);
      hasNestedNotes.should.beTrue();
    });

    test('should parse frontmatter properties from loaded notes', () async {
      final examplePath = 'example${Platform.pathSeparator}example_vault';

      final vaultResult = await ObsidianVault.load(path: examplePath).run();
      final loadedVault =
          vaultResult.fold((f) => throw Exception(f.toString()), (v) => v);

      final welcomeNote = loadedVault.findNote(title: 'Welcome to Your Vault');
      welcomeNote!.properties.isNotEmpty.should.beTrue();
      welcomeNote.properties.any((p) => p.key == 'tags').should.beTrue();
    });

    test('should parse links from loaded notes', () async {
      final examplePath = 'example${Platform.pathSeparator}example_vault';

      final vaultResult = await ObsidianVault.load(path: examplePath).run();
      final loadedVault =
          vaultResult.fold((f) => throw Exception(f.toString()), (v) => v);

      final welcomeNote = loadedVault.findNote(title: 'Welcome to Your Vault');
      welcomeNote!.links.isNotEmpty.should.beTrue();
    });
  });
}
