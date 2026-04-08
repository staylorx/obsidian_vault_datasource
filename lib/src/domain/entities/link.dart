import 'package:equatable/equatable.dart';

/// Represents a wiki-style link between notes in an Obsidian vault.
class Link with EquatableMixin {
  const Link({
    required this.target,
    this.alias,
    this.createIfMissing = false,
  });

  final String target;
  final String? alias;
  final bool createIfMissing;

  String toMarkdown() {
    if (alias != null && alias!.isNotEmpty) {
      return '[[$target|$alias]]';
    }
    return '[[$target]]';
  }

  static Link fromMarkdown(String markdown) {
    final linkRegex = RegExp(r'\[\[([^|\]]+)(?:\|([^\]]+))?\]\]');
    final match = linkRegex.firstMatch(markdown);
    if (match == null) {
      return Link(target: markdown);
    }
    return Link(
      target: match.group(1)!,
      alias: match.group(2),
    );
  }

  Link copyWith({
    String? target,
    String? alias,
    bool? createIfMissing,
  }) {
    return Link(
      target: target ?? this.target,
      alias: alias ?? this.alias,
      createIfMissing: createIfMissing ?? this.createIfMissing,
    );
  }

  @override
  List<Object?> get props => [target, alias, createIfMissing];
}
