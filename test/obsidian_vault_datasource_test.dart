import 'package:obsidian_vault_datasource/obsidian_vault_datasource.dart';
import 'package:test/test.dart';
import 'dart:io';

void main() {
  group('Entity Tests', () {
    test('Note toMarkdown with frontmatter', () {
      final note = Note(
        title: 'Test Note',
        content: 'Hello world',
        properties: [
          Property(
              key: 'tags', value: ['important', 'draft'], isFrontmatter: true),
          Property(key: 'created', value: '2024-01-01', isFrontmatter: true),
        ],
      );

      final markdown = note.toMarkdown();
      expect(markdown.contains('---'), true);
      expect(markdown.contains('tags: [important, draft]'), true);
      expect(markdown.contains('created: 2024-01-01'), true);
      expect(markdown.contains('Hello world'), true);
    });

    test('Note toMarkdown without frontmatter', () {
      final note = Note(
        title: 'Simple Note',
        content: 'Just content',
      );

      final markdown = note.toMarkdown();
      expect(markdown.contains('---'), false);
      expect(markdown.contains('Just content'), true);
    });

    test('Note fromMarkdown parses frontmatter', () {
      const markdown = '''---
tags: [one, two]
status: active
---

# My Note

Some content here.
''';

      final note = Note.fromMarkdown(markdown);
      expect(note.title, 'My Note');
      expect(note.content.contains('Some content here'), true);
      expect(note.properties.length, 2);
      expect(note.properties.any((p) => p.key == 'tags'), true);
    });

    test('Note fromMarkdown parses links', () {
      const markdown = '''# Test Note

Some text with [[a link]] and another [[link target|display text]].
''';

      final note = Note.fromMarkdown(markdown);
      expect(note.links.length, 2);
      expect(note.links[0].target, 'a link');
      expect(note.links[1].target, 'link target');
      expect(note.links[1].alias, 'display text');
    });

    test('Link toMarkdown', () {
      expect(Link(target: 'My Note').toMarkdown(), '[[My Note]]');
      expect(Link(target: 'My Note', alias: 'Display').toMarkdown(),
          '[[My Note|Display]]');
    });

    test('Link fromMarkdown', () {
      expect(Link.fromMarkdown('[[Test]]').target, 'Test');
      expect(Link.fromMarkdown('[[Test|Alias]]').target, 'Test');
      expect(Link.fromMarkdown('[[Test|Alias]]').alias, 'Alias');
    });

    test('Vault findNote', () {
      final vault = Vault(
        name: 'Test Vault',
        path: '/test/path',
        rootFolder: const Folder(
          name: '',
          notes: [
            Note(title: 'Note1', content: ''),
            Note(title: 'Note2', content: ''),
          ],
        ),
      );

      expect(vault.findNote('Note1')?.title, 'Note1');
      expect(vault.findNote('Note3'), null);
    });

    test('Vault searchNotes', () {
      final vault = Vault(
        name: 'Test Vault',
        path: '/test/path',
        rootFolder: const Folder(
          name: '',
          notes: [
            Note(
                title: 'Flutter App',
                content: 'This is about mobile development'),
            Note(title: 'Dart Guide', content: 'Learn the Dart language'),
          ],
        ),
      );

      final results = vault.searchNotes('dart');
      expect(results.length, 1);
      expect(results[0].title, 'Dart Guide');
    });
  });

  group('FileSystemAdapter Tests', () {
    late FileSystemAdapter adapter;
    late String tempDir;

    setUp(() async {
      adapter = FileSystemAdapter();
      tempDir = Directory.systemTemp.createTempSync('obsidian_test_').path;
    });

    tearDown(() async {
      await adapter.deleteDirectory(tempDir);
    });

    test('createDirectory and directoryExists', () async {
      final subDir = '$tempDir${Platform.pathSeparator}subfolder';

      final result = await adapter.createDirectory(subDir);
      expect(result.isRight(), true);

      final exists = await adapter.directoryExists(subDir);
      expect(exists.fold((_) => false, (v) => v), true);
    });

    test('writeFile and readFile', () async {
      final filePath = '$tempDir${Platform.pathSeparator}test.txt';
      const content = 'Hello, World!';

      await adapter.writeFile(filePath, content);
      final result = await adapter.readFile(filePath);

      expect(result.fold((_) => '', (v) => v), content);
    });

    test('readFile returns failure for non-existent file', () async {
      final result = await adapter
          .readFile('$tempDir${Platform.pathSeparator}nonexistent.txt');
      expect(result.isLeft(), true);
    });

    test('joinPaths', () {
      final result = adapter.joinPaths('/base', 'sub');
      expect(result, '/base${Platform.pathSeparator}sub');
    });
  });

  group('Integration Tests', () {
    late String tempVaultPath;

    setUp(() {
      tempVaultPath = Directory.systemTemp.createTempSync('vault_test_').path;
    });

    tearDown(() {
      try {
        Directory(tempVaultPath).deleteSync(recursive: true);
      } catch (_) {}
    });

    test('ObsidianVault.create creates vault directory', () async {
      ObsidianVault.create(tempVaultPath, 'My Vault');

      final adapter = FileSystemAdapter();
      final exists = await adapter.directoryExists(tempVaultPath);
      expect(exists.fold((_) => false, (v) => v), true);
    });

    test('ObsidianVault.createNote creates note file', () async {
      final vault = ObsidianVault.create(tempVaultPath, 'My Vault');

      final result =
          await vault.createNote('Test Note', content: 'Hello content').run();

      expect(result.isRight(), true);
      final notePath = '$tempVaultPath${Platform.pathSeparator}Test Note.md';
      expect(File(notePath).existsSync(), true);

      final content = await File(notePath).readAsString();
      expect(content.contains('Hello content'), true);
    });

    test('ObsidianVault.findNote finds created note', () async {
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

    test('ObsidianNote.updateContent updates note', () async {
      final vault = ObsidianVault.create(tempVaultPath, 'My Vault');

      final noteResult = await vault.createNote('My Note').run();
      final note = noteResult.fold((_) => throw Exception('Failed'), (v) => v);

      final updateResult = await note.updateContent('Updated content').run();
      expect(updateResult.isRight(), true);

      final fileContent =
          await File('$tempVaultPath${Platform.pathSeparator}My Note.md')
              .readAsString();
      expect(fileContent.contains('Updated content'), true);
    });

    test('ObsidianNote.createProperty adds frontmatter', () async {
      final vault = ObsidianVault.create(tempVaultPath, 'My Vault');

      final noteResult = await vault.createNote('My Note').run();
      final note = noteResult.fold((_) => throw Exception('Failed'), (v) => v);

      final propResult =
          await note.createProperty('tags', ['important', 'draft']).run();
      expect(propResult.isRight(), true);

      final fileContent =
          await File('$tempVaultPath${Platform.pathSeparator}My Note.md')
              .readAsString();
      expect(fileContent.contains('tags: [important, draft]'), true);
    });

    test('ObsidianNote.createLink adds link to content', () async {
      final vault = ObsidianVault.create(tempVaultPath, 'My Vault');

      await vault.createNote('Target Note').run();
      final noteResult = await vault.createNote('Source Note').run();
      final note = noteResult.fold((_) => throw Exception('Failed'), (v) => v);

      final linkResult = await note.createLink('Target Note').run();
      expect(linkResult.isRight(), true);

      final fileContent =
          await File('$tempVaultPath${Platform.pathSeparator}Source Note.md')
              .readAsString();
      expect(fileContent.contains('[[Target Note]]'), true);
    });

    test('ObsidianVault.createFolder creates folder', () async {
      final vault = ObsidianVault.create(tempVaultPath, 'My Vault');

      final result = await vault.createFolder('Notes').run();
      expect(result.isRight(), true);

      final folderPath = '$tempVaultPath${Platform.pathSeparator}Notes';
      expect(Directory(folderPath).existsSync(), true);
    });
  });

  group('Load Example Vault', () {
    test('load the example vault from examples folder', () async {
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
  });
}
