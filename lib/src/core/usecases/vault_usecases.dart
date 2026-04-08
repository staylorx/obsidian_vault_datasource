import 'dart:io';
import 'package:fpdart/fpdart.dart';
import '../../domain/entities/entities.dart';
import '../../domain/failures.dart';
import '../../data/adapters/file_system_adapter.dart';
import '../../data/repositories/note_repository.dart';

class CreateVault {
  final FileSystemAdapter _fileSystemAdapter;

  CreateVault(this._fileSystemAdapter);

  TaskEither<Failure, Vault> call(String path, String name) {
    return TaskEither(() async {
      final existsResult = await _fileSystemAdapter.directoryExists(path);

      return existsResult.fold(
        (failure) => Left(failure),
        (exists) async {
          if (exists) {
            return Left(VaultAlreadyExistsFailure(path));
          }

          final createResult = await _fileSystemAdapter.createDirectory(path);
          return createResult.fold(
            (failure) => Left(failure),
            (_) {
              final vault = Vault(name: name, path: path);
              return Right(vault);
            },
          );
        },
      );
    });
  }
}

class LoadVault {
  final FileSystemAdapter _fileSystemAdapter;
  final NoteRepository _noteRepository;

  LoadVault(this._fileSystemAdapter, this._noteRepository);

  TaskEither<Failure, Vault> call(String path) {
    return TaskEither(() async {
      final existsResult = await _fileSystemAdapter.directoryExists(path);

      return existsResult.fold(
        (failure) => Left(failure),
        (exists) async {
          if (!exists) {
            return Left(DirectoryNotFoundFailure(path));
          }

          final name = path.split(Platform.pathSeparator).last;

          final notesResult =
              await _noteRepository.readNotesFromDirectory(path);
          final rootFolderResult = await _noteRepository.loadFolder(path, '');

          return notesResult.fold(
            (failure) => Left(failure),
            (notes) => rootFolderResult.fold(
              (failure) => Left(failure),
              (rootFolder) => Right(Vault(
                name: name,
                path: path,
                notes: notes,
                rootFolder: rootFolder,
              )),
            ),
          );
        },
      );
    });
  }
}

class SaveVault {
  final FileSystemAdapter _fileSystemAdapter;
  final NoteRepository _noteRepository;

  SaveVault(this._fileSystemAdapter, this._noteRepository);

  TaskEither<Failure, Unit> call(Vault vault) {
    return TaskEither(() async {
      for (final note in vault.notes) {
        final notePath =
            _fileSystemAdapter.joinPaths(vault.path, '${note.title}.md');
        final result = await _noteRepository.writeNote(notePath, note);
        if (result.isLeft()) {
          return result;
        }
      }

      for (final note in vault.rootFolder.notes) {
        final notePath =
            _fileSystemAdapter.joinPaths(vault.path, '${note.title}.md');
        final result = await _noteRepository.writeNote(notePath, note);
        if (result.isLeft()) {
          return result;
        }
      }

      return const Right(unit);
    });
  }
}

class CreateNote {
  final FileSystemAdapter _fileSystemAdapter;
  final NoteRepository _noteRepository;

  CreateNote(this._fileSystemAdapter, this._noteRepository);

  TaskEither<Failure, Note> call(Vault vault, String title,
      {String content = ''}) {
    return TaskEither(() async {
      final existingNote = vault.findNote(title);
      if (existingNote != null) {
        return Left(NoteAlreadyExistsFailure(title));
      }

      final note = Note(title: title, content: content);
      final notePath = _fileSystemAdapter.joinPaths(vault.path, '$title.md');

      final result = await _noteRepository.writeNote(notePath, note);

      return result.map((_) => note.copyWith(path: notePath));
    });
  }
}

class CreateFolder {
  final FileSystemAdapter _fileSystemAdapter;

  CreateFolder(this._fileSystemAdapter);

  TaskEither<Failure, Unit> call(Vault vault, String name) {
    return TaskEither(() async {
      final folderPath = _fileSystemAdapter.joinPaths(vault.path, name);
      return _fileSystemAdapter.createDirectory(folderPath);
    });
  }
}

class CreateLink {
  final NoteRepository _noteRepository;

  CreateLink(this._noteRepository);

  TaskEither<Failure, Note> call(Note sourceNote, String targetTitle,
      {String? alias, bool createIfMissing = false}) {
    return TaskEither(() async {
      final link = Link(
        target: targetTitle,
        alias: alias,
        createIfMissing: createIfMissing,
      );

      final updatedNote = sourceNote.copyWith(
        links: [...sourceNote.links, link],
        content: '${sourceNote.content}\n\n${link.toMarkdown()}',
      );

      if (sourceNote.path != null) {
        final result =
            await _noteRepository.writeNote(sourceNote.path!, updatedNote);
        return result.map((_) => updatedNote);
      }

      return Right(updatedNote);
    });
  }
}
