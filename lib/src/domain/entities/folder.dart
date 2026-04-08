import 'package:equatable/equatable.dart';
import 'note.dart';

class Folder extends Equatable {
  const Folder({
    required this.name,
    this.notes = const [],
    this.subfolders = const [],
    this.path,
  });

  final String name;
  final List<Note> notes;
  final List<Folder> subfolders;
  final String? path;

  List<Note> get allNotes {
    final result = List<Note>.from(notes);
    for (final subfolder in subfolders) {
      result.addAll(subfolder.allNotes);
    }
    return result;
  }

  Folder copyWith({
    String? name,
    List<Note>? notes,
    List<Folder>? subfolders,
    String? path,
  }) {
    return Folder(
      name: name ?? this.name,
      notes: notes ?? this.notes,
      subfolders: subfolders ?? this.subfolders,
      path: path ?? this.path,
    );
  }

  @override
  List<Object?> get props => [name, notes, subfolders, path];
}
