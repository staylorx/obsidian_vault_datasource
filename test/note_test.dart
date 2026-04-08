import 'package:obsidian_vault_datasource/obsidian_vault_datasource.dart';
import 'package:shouldly/shouldly.dart';
import 'package:test/test.dart';

void main() {
  group('Given a Note entity', () {
    group('when converting to Markdown', () {
      test('should include frontmatter when properties exist', () {
        final note = Note(
          title: 'Test Note',
          content: 'Hello world',
          properties: [
            Property(
                key: 'tags',
                value: ['important', 'draft'],
                isFrontmatter: true),
            Property(key: 'created', value: '2024-01-01', isFrontmatter: true),
          ],
        );

        final markdown = note.toMarkdown();
        markdown.should.contain('---');
        markdown.should.contain('tags: [important, draft]');
        markdown.should.contain('created: 2024-01-01');
        markdown.should.contain('Hello world');
      });

      test('should not include frontmatter when no properties', () {
        final note = Note(title: 'Simple Note', content: 'Just content');

        final markdown = note.toMarkdown();
        markdown.should.not.contain('---');
        markdown.should.contain('Just content');
      });
    });

    group('when parsing from Markdown', () {
      test('should extract frontmatter properties', () {
        const markdown = '''---
tags: [one, two]
status: active
---

# My Note

Some content here.
''';
        final note = Note.fromMarkdown(markdown);

        note.title.should.be('My Note');
        note.content.should.contain('Some content here');
        note.properties.length.should.be(2);
        note.properties.any((p) => p.key == 'tags').should.beTrue();
      });

      test('should extract wiki-style links', () {
        const markdown = '''# Test Note

Some text with [[a link]] and another [[link target|display text]].
''';
        final note = Note.fromMarkdown(markdown);

        note.links.length.should.be(2);
        note.links[0].target.should.be('a link');
        note.links[1].target.should.be('link target');
        note.links[1].alias.should.be('display text');
      });
    });
  });

  group('Given a Link entity', () {
    test('should render as wiki link without alias', () {
      Link(target: 'My Note').toMarkdown().should.be('[[My Note]]');
    });

    test('should render as wiki link with alias', () {
      Link(target: 'My Note', alias: 'Display')
          .toMarkdown()
          .should
          .be('[[My Note|Display]]');
    });

    test('should parse wiki link without alias', () {
      Link.fromMarkdown('[[Test]]').target.should.be('Test');
    });

    test('should parse wiki link with alias', () {
      final link = Link.fromMarkdown('[[Test|Alias]]');
      link.target.should.be('Test');
      link.alias.should.be('Alias');
    });
  });
}
