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
        markdown.should.contain('tags:');
        markdown.should.contain('- important');
        markdown.should.contain('- draft');
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

      test('should parse complex YAML frontmatter with nested objects', () {
        const markdown = '''---
tags: [important, draft]
status: active
metadata:
  author: John Doe
  created: 2024-01-15
  priority: high
settings:
  notify: true
  retries: 3
---

# Complex Note

Content here.
''';
        final note = Note.fromMarkdown(markdown);

        note.properties.length.should.be(4);
        note.properties.any((p) => p.key == 'tags').should.beTrue();
        note.properties.any((p) => p.key == 'status').should.beTrue();

        final metadataProp =
            note.properties.firstWhere((p) => p.key == 'metadata');
        final Map<String, dynamic> metadataValue =
            metadataProp.value as Map<String, dynamic>;
        (metadataValue['author'] as String).should.be('John Doe');

        final settingsProp =
            note.properties.firstWhere((p) => p.key == 'settings');
        final Map<String, dynamic> settingsValue =
            settingsProp.value as Map<String, dynamic>;
        (settingsValue['notify'] as bool).should.be(true);
        (settingsValue['retries'] as int).should.be(3);
      });

      test('should parse YAML with dates and booleans', () {
        const markdown = '''---
created: 2024-01-15
updated: 2024-02-20
published: true
archived: false
count: 42
---

# Date Note

Test content.
''';
        final note = Note.fromMarkdown(markdown);

        note.properties.length.should.be(5);
        note.properties
            .any((p) => p.key == 'published' && p.value == true)
            .should
            .beTrue();
        note.properties
            .any((p) => p.key == 'archived' && p.value == false)
            .should
            .beTrue();
        note.properties
            .any((p) => p.key == 'count' && p.value == 42)
            .should
            .beTrue();
      });

      test('should parse YAML with nested arrays', () {
        const markdown = '''---
matrix:
  - [1, 2, 3]
  - [4, 5, 6]
tags:
  - one
  - two
  - three
---

# Array Note

Content.
''';
        final note = Note.fromMarkdown(markdown);

        note.properties.any((p) => p.key == 'tags').should.beTrue();
        final tagsProp = note.properties.firstWhere((p) => p.key == 'tags');
        (tagsProp.value as List).length.should.be(3);
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
