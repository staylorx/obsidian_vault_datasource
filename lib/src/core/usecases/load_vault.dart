import 'dart:io';
import 'package:fpdart/fpdart.dart';
import '../../domain/entities/entities.dart';
import '../../domain/failures.dart';
import '../../data/adapters/file_system_adapter.dart';
import '../../data/repositories/note_repository.dart';

/// Loads an existing vault from disk.
class LoadVault {
  LoadVault(this._fileSystemAdapter, this._noteRepository);

  final FileSystemAdapter _fileSystemAdapter;
  final NoteRepository _noteRepository;

  TaskEither<Failure, Vault> call({required String path}) {
    return TaskEither(() async {
      final existsResult = await _fileSystemAdapter.directoryExists(path);

      return existsResult.fold(
        (failure) => Left<Failure, Vault>(failure),
        (exists) async {
          if (!exists) {
            return Left<Failure, Vault>(DirectoryNotFoundFailure(path));
          }

          final name = path.split(Platform.pathSeparator).last;

          final notesResult =
              await _noteRepository.readNotesFromDirectory(path);
          final rootFolderResult = await _noteRepository.loadFolder(path, '');

          return notesResult.fold(
            (failure) => Left<Failure, Vault>(failure),
            (notes) => rootFolderResult.fold(
              (failure) => Left<Failure, Vault>(failure),
              (rootFolder) => Right<Failure, Vault>(Vault(
                name: name,
                path: path,
                rootFolder: rootFolder.copyWith(notes: notes),
              )),
            ),
          );
        },
      ) as Future<Either<Failure, Vault>>;
    });
  }
}
