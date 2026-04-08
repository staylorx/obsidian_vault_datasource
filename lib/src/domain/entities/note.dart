import 'package:equatable/equatable.dart';
import 'package:yaml/yaml.dart' as yaml;
import 'property.dart';
import 'link.dart';

/// Represents a single note in an Obsidian vault.
class Note with EquatableMixin {
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
      final frontmatterMap = <String, dynamic>{};
      for (final prop in frontmatterProps) {
        frontmatterMap[prop.key] = prop.value;
      }

      buffer.writeln('---');
      buffer.write(_dumpYaml(frontmatterMap));
      buffer.writeln('---');
      buffer.writeln();
    }

    buffer.write(content);

    return buffer.toString();
  }

  static String _dumpYaml(dynamic value, {int indent = 0}) {
    final buffer = StringBuffer();
    final prefix = '  ' * indent;

    if (value == null) {
      buffer.writeln('${prefix}null');
    } else if (value is bool) {
      buffer.writeln('$prefix${value.toString()}');
    } else if (value is num) {
      buffer.writeln('$prefix${value.toString()}');
    } else if (value is String) {
      if (value.contains('\n') ||
          value.contains(':') ||
          value.contains('#') ||
          value.startsWith('"') ||
          value.startsWith("'")) {
        final escaped = value.replaceAll('"', '\\"');
        buffer.writeln('$prefix"$escaped"');
      } else {
        buffer.writeln('$prefix$value');
      }
    } else if (value is List) {
      for (final item in value) {
        if (item is Map || item is List) {
          buffer.writeln('$prefix-');
          buffer.write(_dumpYaml(item, indent: indent + 1));
        } else {
          buffer.writeln('$prefix- ${_formatYamlValue(item)}');
        }
      }
    } else if (value is Map) {
      for (final entry in value.entries) {
        final key = entry.key.toString();
        final val = entry.value;
        if (val is Map || val is List) {
          buffer.writeln('$prefix$key:');
          buffer.write(_dumpYaml(val, indent: indent + 1));
        } else {
          buffer.writeln('$prefix$key: ${_formatYamlValue(val)}');
        }
      }
    }

    return buffer.toString();
  }

  static String _formatYamlValue(dynamic value) {
    if (value == null) return 'null';
    if (value is bool) return value.toString();
    if (value is num) return value.toString();
    if (value is String) {
      if (value.contains('\n') ||
          value.contains(':') ||
          value.contains('#') ||
          value.startsWith('"') ||
          value.startsWith("'")) {
        final escaped = value.replaceAll('"', '\\"');
        return '"$escaped"';
      }
      return value;
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

  static Map<String, dynamic> _parseYamlSimple(String yamlContent) {
    try {
      final parsed = yaml.loadYaml(yamlContent);
      if (parsed is! yaml.YamlMap) return {};

      return _convertYamlToMap(parsed);
    } catch (e) {
      return {};
    }
  }

  static Map<String, dynamic> _convertYamlToMap(yaml.YamlMap yamlMap) {
    final result = <String, dynamic>{};
    for (final entry in yamlMap.entries) {
      final key = entry.key.toString();
      final value = entry.value;
      result[key] = _convertYamlValue(value);
    }
    return result;
  }

  static dynamic _convertYamlValue(dynamic value) {
    if (value is yaml.YamlMap) {
      return _convertYamlToMap(value);
    } else if (value is yaml.YamlList) {
      return value.map((e) => _convertYamlValue(e)).toList();
    } else if (value is Map) {
      return Map.fromEntries(
        value.entries
            .map((e) => MapEntry(e.key.toString(), _convertYamlValue(e.value))),
      );
    } else if (value is List) {
      return value.map((e) => _convertYamlValue(e)).toList();
    }
    return value;
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
