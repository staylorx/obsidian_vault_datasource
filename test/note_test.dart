import 'package:obsidian_vault_datasource/obsidian_vault_datasource.dart';
import 'package:test/test.dart';

void main() {
  group('Given a Note entity, when converting to Markdown', () {
    test('should include frontmatter when properties exist', () {
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

    test('should not include frontmatter when no properties', () {
      final note = Note(title: 'Simple Note', content: 'Just content');

      final markdown = note.toMarkdown();
      expect(markdown.contains('---'), false);
      expect(markdown.contains('Just content'), true);
    });
  });

  group('Given a Note parsed from Markdown', () {
    test('should extract frontmatter properties', () {
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

    test('should extract wiki-style links', () {
      const markdown = '''# Test Note

Some text with [[a link]] and another [[link target|display text]].
''';
      final note = Note.fromMarkdown(markdown);

      expect(note.links.length, 2);
      expect(note.links[0].target, 'a link');
      expect(note.links[1].target, 'link target');
      expect(note.links[1].alias, 'display text');
    });
  });

  group('Given a Link entity', () {
    test('should render as wiki link without alias', () {
      expect(Link(target: 'My Note').toMarkdown(), '[[My Note]]');
    });

    test('should render as wiki link with alias', () {
      expect(Link(target: 'My Note', alias: 'Display').toMarkdown(),
          '[[My Note|Display]]');
    });

    test('should parse wiki link without alias', () {
      expect(Link.fromMarkdown('[[Test]]').target, 'Test');
    });

    test('should parse wiki link with alias', () {
      expect(Link.fromMarkdown('[[Test|Alias]]').target, 'Test');
      expect(Link.fromMarkdown('[[Test|Alias]]').alias, 'Alias');
    });
  });
}
