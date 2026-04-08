import 'package:equatable/equatable.dart';
import 'property.dart';
import 'link.dart';

class Note extends Equatable {
  const Note({
    required this.title,
    this.content = '',
    this.properties = const [],
    this.links = const [],
    this.path,
  });

  final String title;
  final String content;
  final List<Property> properties;
  final List<Link> links;
  final String? path;

  String toMarkdown() {
    final buffer = StringBuffer();

    final frontmatterProps = properties.where((p) => p.isFrontmatter).toList();
    if (frontmatterProps.isNotEmpty) {
      buffer.writeln('---');
      for (final prop in frontmatterProps) {
        final valueStr = _formatPropertyValue(prop.value);
        buffer.writeln('${prop.key}: $valueStr');
      }
      buffer.writeln('---');
      buffer.writeln();
    }

    buffer.write(content);

    return buffer.toString();
  }

  String _formatPropertyValue(dynamic value) {
    if (value == null) return 'null';
    if (value is String) {
      if (value.contains('\n') || value.contains(':') || value.contains('#')) {
        return '"${value.replaceAll('"', '\\"')}"';
      }
      return value;
    }
    if (value is List) {
      final items = value.map((e) => _formatPropertyValue(e)).join(', ');
      return '[$items]';
    }
    return value.toString();
  }

  static Note fromMarkdown(String markdown, {String? path}) {
    final lines = markdown.split('\n');
    Map<String, dynamic> frontmatter = {};
    int contentStartIndex = 0;

    if (lines.isNotEmpty && lines[0].trim() == '---') {
      int endIndex = -1;
      for (int i = 1; i < lines.length; i++) {
        if (lines[i].trim() == '---') {
          endIndex = i;
          break;
        }
      }
      if (endIndex > 1) {
        final frontmatterBlock = lines.sublist(1, endIndex).join('\n');
        try {
          frontmatter = _parseYamlSimple(frontmatterBlock);
        } catch (_) {}
        contentStartIndex = endIndex + 1;
      }
    }

    final content = lines.sublist(contentStartIndex).join('\n').trim();

    final titleMatch =
        RegExp(r'^#\s+(.+)$', multiLine: true).firstMatch(content);
    String title;
    if (titleMatch != null) {
      title = titleMatch.group(1) ?? 'Untitled';
    } else if (path != null) {
      final fileName = path.split(RegExp(r'[/\\]')).last;
      title = fileName.replaceAll(RegExp(r'\.md$'), '');
    } else {
      title = 'Untitled';
    }

    final properties = frontmatter.entries
        .map((e) => Property(
              key: e.key,
              value: e.value,
              isFrontmatter: true,
            ))
        .toList();

    final links = _extractLinks(content);

    return Note(
      title: title,
      content: content,
      properties: properties,
      links: links,
      path: path,
    );
  }

  static Map<String, dynamic> _parseYamlSimple(String yaml) {
    final result = <String, dynamic>{};
    for (final line in yaml.split('\n')) {
      final colonIndex = line.indexOf(':');
      if (colonIndex > 0) {
        final key = line.substring(0, colonIndex).trim();
        var value = line.substring(colonIndex + 1).trim();
        if (value.startsWith('"') && value.endsWith('"')) {
          value = value.substring(1, value.length - 1);
        } else if (value.startsWith("'") && value.endsWith("'")) {
          value = value.substring(1, value.length - 1);
        }
        result[key] = value;
      }
    }
    return result;
  }

  static List<Link> _extractLinks(String content) {
    final linkRegex = RegExp(r'\[\[([^|\]]+)(?:\|([^\]]+))?\]\]');
    return linkRegex
        .allMatches(content)
        .map((m) => Link(
              target: m.group(1)!,
              alias: m.group(2),
            ))
        .toList();
  }

  Note copyWith({
    String? title,
    String? content,
    List<Property>? properties,
    List<Link>? links,
    String? path,
  }) {
    return Note(
      title: title ?? this.title,
      content: content ?? this.content,
      properties: properties ?? this.properties,
      links: links ?? this.links,
      path: path ?? this.path,
    );
  }

  @override
  List<Object?> get props => [title, content, properties, links, path];
}
