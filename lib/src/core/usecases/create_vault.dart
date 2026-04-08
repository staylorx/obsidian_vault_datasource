import 'package:fpdart/fpdart.dart';
import '../../domain/entities/entities.dart';
import '../../domain/failures.dart';
import '../../data/adapters/file_system_adapter.dart';

/// Creates a new vault directory on disk.
class CreateVault {
  CreateVault(this._fileSystemAdapter);

  final FileSystemAdapter _fileSystemAdapter;

  TaskEither<Failure, Vault> call(
      {required String path, required String name}) {
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
