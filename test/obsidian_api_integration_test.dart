import 'dart:io';
import 'package:obsidian_vault_datasource/obsidian_vault_datasource.dart';
import 'package:shouldly/shouldly.dart';
import 'package:test/test.dart';

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
      ObsidianVault.create(path: tempVaultPath, name: 'My Vault');

      final adapter = FileSystemAdapter();
      final exists = await adapter.directoryExists(tempVaultPath);
      exists.fold((_) => false, (v) => v).should.beTrue();
    });

    test('should create note file on disk', () async {
      final vault = ObsidianVault.create(path: tempVaultPath, name: 'My Vault');

      final result = await vault
          .createNote(title: 'Test Note', content: 'Hello content')
          .run();

      result.isRight().should.beTrue();
      final notePath = '$tempVaultPath${Platform.pathSeparator}Test Note.md';
      File(notePath).existsSync().should.beTrue();

      final content = await File(notePath).readAsString();
      content.should.contain('Hello content');
    });

    test('should find note after refresh', () async {
      final vault = ObsidianVault.create(path: tempVaultPath, name: 'My Vault');

      await vault.createNote(title: 'Note One', content: 'First').run();
      final refreshed1 = await vault.refresh().run();
      final vault1 = refreshed1.fold((_) => vault, (v) => v);

      await vault1.createNote(title: 'Note Two', content: 'Second').run();
      final refreshed2 = await vault1.refresh().run();
      final vault2 = refreshed2.fold((_) => vault1, (v) => v);

      vault2.findNote(title: 'Note One')!.title.should.be('Note One');
    });

    test('should create folder on disk', () async {
      final vault = ObsidianVault.create(path: tempVaultPath, name: 'My Vault');

      final result = await vault.createFolder(name: 'Notes').run();
      result.isRight().should.beTrue();

      final folderPath = '$tempVaultPath${Platform.pathSeparator}Notes';
      Directory(folderPath).existsSync().should.beTrue();
    });
  });

  group('Given an ObsidianNote', () {
    late String tempVaultPath;
    late ObsidianNote note;

    setUp(() async {
      tempVaultPath = Directory.systemTemp.createTempSync('note_test_').path;
      final vault = ObsidianVault.create(path: tempVaultPath, name: 'Test');
      final result = await vault.createNote(title: 'My Note').run();
      note = result.fold((_) => throw Exception('Failed'), (v) => v);
    });

    tearDown(() {
      try {
        Directory(tempVaultPath).deleteSync(recursive: true);
      } catch (_) {}
    });

    test('should update content on disk', () async {
      final updateResult =
          await note.updateContent(content: 'Updated content').run();
      updateResult.isRight().should.beTrue();

      final fileContent =
          await File('$tempVaultPath${Platform.pathSeparator}My Note.md')
              .readAsString();
      fileContent.should.contain('Updated content');
    });

    test('should add frontmatter property', () async {
      final propResult = await note
          .createProperty(key: 'tags', value: ['important', 'draft']).run();
      propResult.isRight().should.beTrue();

      final fileContent =
          await File('$tempVaultPath${Platform.pathSeparator}My Note.md')
              .readAsString();
      fileContent.should.contain('tags:');
    });

    test('should update existing property', () async {
      await note.createProperty(key: 'status', value: 'draft').run();
      final updateResult =
          await note.updateProperty(key: 'status', value: 'published').run();
      updateResult.isRight().should.beTrue();
    });

    test('should remove property', () async {
      await note.createProperty(key: 'temp', value: 'value').run();
      final removeResult = await note.removeProperty(key: 'temp').run();
      removeResult.isRight().should.beTrue();
    });

    test('should add link to content', () async {
      final vault = ObsidianVault.create(path: tempVaultPath, name: 'Test');
      await vault.createNote(title: 'Target Note').run();

      final linkResult =
          await note.createLink(targetTitle: 'Target Note').run();
      linkResult.isRight().should.beTrue();

      final fileContent =
          await File('$tempVaultPath${Platform.pathSeparator}My Note.md')
              .readAsString();
      fileContent.should.contain('[[Target Note]]');
    });
  });
}
