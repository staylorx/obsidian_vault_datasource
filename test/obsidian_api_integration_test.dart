import 'package:obsidian_vault_datasource/obsidian_vault_datasource.dart';
import 'package:test/test.dart';
import 'dart:io';

void main() {
  group('Given an ObsidianVault created from scratch', () {
    late String tempVaultPath;

    setUp(() {
      tempVaultPath = Directory.systemTemp.createTempSync('vault_test_').path;
    });

    tearDown(() {
      try {
        Directory(tempVaultPath).deleteSync(recursive: true);
      } catch (_) {}
    });

    test('should create vault directory on disk', () async {
      ObsidianVault.create(tempVaultPath, 'My Vault');

      final adapter = FileSystemAdapter();
      final exists = await adapter.directoryExists(tempVaultPath);
      expect(exists.fold((_) => false, (v) => v), true);
    });

    test('should create note file on disk', () async {
      final vault = ObsidianVault.create(tempVaultPath, 'My Vault');

      final result =
          await vault.createNote('Test Note', content: 'Hello content').run();

      expect(result.isRight(), true);
      final notePath = '$tempVaultPath${Platform.pathSeparator}Test Note.md';
      expect(File(notePath).existsSync(), true);

      final content = await File(notePath).readAsString();
      expect(content.contains('Hello content'), true);
    });

    test('should find note after refresh', () async {
      final vault = ObsidianVault.create(tempVaultPath, 'My Vault');

      await vault.createNote('Note One', content: 'First').run();
      final refreshed1 = await vault.refresh().run();
      final vault1 = refreshed1.fold((_) => vault, (v) => v);

      await vault1.createNote('Note Two', content: 'Second').run();
      final refreshed2 = await vault1.refresh().run();
      final vault2 = refreshed2.fold((_) => vault1, (v) => v);

      final found = vault2.findNote('Note One');
      expect(found?.title, 'Note One');
    });

    test('should create folder on disk', () async {
      final vault = ObsidianVault.create(tempVaultPath, 'My Vault');

      final result = await vault.createFolder('Notes').run();
      expect(result.isRight(), true);

      final folderPath = '$tempVaultPath${Platform.pathSeparator}Notes';
      expect(Directory(folderPath).existsSync(), true);
    });
  });

  group('Given an ObsidianNote', () {
    late String tempVaultPath;
    late ObsidianNote note;

    setUp(() async {
      tempVaultPath = Directory.systemTemp.createTempSync('note_test_').path;
      final vault = ObsidianVault.create(tempVaultPath, 'Test');
      final result = await vault.createNote('My Note').run();
      note = result.fold((_) => throw Exception('Failed'), (v) => v);
    });

    tearDown(() {
      try {
        Directory(tempVaultPath).deleteSync(recursive: true);
      } catch (_) {}
    });

    test('should update content on disk', () async {
      final updateResult = await note.updateContent('Updated content').run();
      expect(updateResult.isRight(), true);

      final fileContent =
          await File('$tempVaultPath${Platform.pathSeparator}My Note.md')
              .readAsString();
      expect(fileContent.contains('Updated content'), true);
    });

    test('should add frontmatter property', () async {
      final propResult =
          await note.createProperty('tags', ['important', 'draft']).run();
      expect(propResult.isRight(), true);

      final fileContent =
          await File('$tempVaultPath${Platform.pathSeparator}My Note.md')
              .readAsString();
      expect(fileContent.contains('tags: [important, draft]'), true);
    });

    test('should add link to content', () async {
      final vault = ObsidianVault.create(tempVaultPath, 'Test');
      await vault.createNote('Target Note').run();

      final linkResult = await note.createLink('Target Note').run();
      expect(linkResult.isRight(), true);

      final fileContent =
          await File('$tempVaultPath${Platform.pathSeparator}My Note.md')
              .readAsString();
      expect(fileContent.contains('[[Target Note]]'), true);
    });

    test('should update existing property', () async {
      final propResult = await note.createProperty('status', 'active').run();
      final noteWithProp =
          propResult.fold((_) => throw Exception('Failed'), (v) => v);

      final updateResult =
          await noteWithProp.updateProperty('status', 'completed').run();
      expect(updateResult.isRight(), true);

      final fileContent =
          await File('$tempVaultPath${Platform.pathSeparator}My Note.md')
              .readAsString();
      expect(fileContent.contains('status: completed'), true);
    });

    test('should remove property', () async {
      final propResult = await note.createProperty('temp', 'value').run();
      final noteWithProp =
          propResult.fold((_) => throw Exception('Failed'), (v) => v);

      final removeResult = await noteWithProp.removeProperty('temp').run();
      expect(removeResult.isRight(), true);

      final fileContent =
          await File('$tempVaultPath${Platform.pathSeparator}My Note.md')
              .readAsString();
      expect(fileContent.contains('temp:'), false);
    });

    test('should remove property', () async {
      await note.createProperty('temp', 'value').run();
      final removeResult = await note.removeProperty('temp').run();
      expect(removeResult.isRight(), true);

      final fileContent =
          await File('$tempVaultPath${Platform.pathSeparator}My Note.md')
              .readAsString();
      expect(fileContent.contains('temp:'), false);
    });
  });
}
