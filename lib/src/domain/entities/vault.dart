import 'package:equatable/equatable.dart';
import 'folder.dart';
import 'note.dart';

/// Represents an entire Obsidian vault with its notes and folders.
class Vault extends Equatable {
  const Vault({
    required this.name,
    this.rootFolder = const Folder(name: ''),
    required this.path,
  });

  final String name;
  final Folder rootFolder;
  final String path;

  List<Note> get allNotes => rootFolder.allNotes;

  Note? findNote(String title) {
    for (final note in allNotes) {
      if (note.title == title) return note;
    }
    return null;
  }

  List<Note> searchNotes(String query) {
    final lowerQuery = query.toLowerCase();
    return allNotes.where((note) {
      return note.title.toLowerCase().contains(lowerQuery) ||
          note.content.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  Vault copyWith({
    String? name,
    Folder? rootFolder,
    String? path,
  }) {
    return Vault(
      name: name ?? this.name,
      rootFolder: rootFolder ?? this.rootFolder,
      path: path ?? this.path,
    );
  }

  @override
  List<Object?> get props => [name, rootFolder, path];
}
