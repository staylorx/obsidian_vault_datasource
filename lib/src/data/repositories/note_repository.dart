import 'dart:io';
import 'package:fpdart/fpdart.dart';
import '../../domain/entities/entities.dart';
import '../../domain/failures.dart';
import '../adapters/file_system_adapter.dart';

class NoteRepository {
  NoteRepository(this._fileSystemAdapter);

  final FileSystemAdapter _fileSystemAdapter;

  Future<Either<Failure, Note>> readNote(String path) async {
    final result = await _fileSystemAdapter.readFile(path);
    return result.map((content) {
      return Note.fromMarkdown(content, path: path);
    });
  }

  Future<Either<Failure, Unit>> writeNote(String path, Note note) async {
    return _fileSystemAdapter.writeFile(path, note.toMarkdown());
  }

  Future<Either<Failure, List<Note>>> readNotesFromDirectory(
      String dirPath) async {
    final listResult = await _fileSystemAdapter.listDirectory(dirPath);

    return listResult.fold(
      (failure) => Left(failure),
      (paths) async {
        final notes = <Note>[];
        final markdownFiles = paths.where((p) => p.endsWith('.md'));

        for (final filePath in markdownFiles) {
          final noteResult = await readNote(filePath);
          noteResult.fold(
            (failure) => null,
            (note) => notes.add(note),
          );
        }

        return Right(notes);
      },
    );
  }

  Future<Either<Failure, Map<String, Folder>>> readFoldersFromDirectory(
    String dirPath,
    String parentName,
  ) async {
    final listResult = await _fileSystemAdapter.listDirectory(dirPath);

    return listResult.fold(
      (failure) => Left(failure),
      (paths) async {
        final folders = <String, Folder>{};
        final directories = paths.where((p) => Directory(p).existsSync());

        for (final dirPath in directories) {
          final name = _fileSystemAdapter.getDirectoryName(dirPath);
          final folderResult = await loadFolder(dirPath, name);
          folderResult.fold(
            (failure) => null,
            (folder) => folders[name] = folder,
          );
        }

        return Right(folders);
      },
    );
  }

  Future<Either<Failure, Folder>> loadFolder(String path, String name) async {
    final notesResult = await readNotesFromDirectory(path);
    final foldersResult = await readFoldersFromDirectory(path, name);

    return notesResult.fold(
      (failure) => Left(failure),
      (notes) => foldersResult.fold(
        (failure) => Left(failure),
        (subfolders) => Right(Folder(
          name: name,
          notes: notes,
          subfolders: subfolders.values.toList(),
          path: path,
        )),
      ),
    );
  }
}
