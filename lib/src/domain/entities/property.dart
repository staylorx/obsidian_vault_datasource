import 'package:equatable/equatable.dart';

enum PropertyType {
  string,
  number,
  boolean,
  date,
  list,
}

class Property extends Equatable {
  const Property({
    required this.key,
    required this.value,
    this.type = PropertyType.string,
    this.isFrontmatter = true,
  });

  final String key;
  final dynamic value;
  final PropertyType type;
  final bool isFrontmatter;

  Property copyWith({
    String? key,
    dynamic value,
    PropertyType? type,
    bool? isFrontmatter,
  }) {
    return Property(
      key: key ?? this.key,
      value: value ?? this.value,
      type: type ?? this.type,
      isFrontmatter: isFrontmatter ?? this.isFrontmatter,
    );
  }

  @override
  List<Object?> get props => [key, value, type, isFrontmatter];
}
