import 'package:fpdart/fpdart.dart';
import '../../domain/entities/entities.dart';
import '../../domain/failures.dart';
import '../../data/adapters/file_system_adapter.dart';

/// Creates a new folder in a vault.
class CreateFolder {
  CreateFolder(this._fileSystemAdapter);

  final FileSystemAdapter _fileSystemAdapter;

  TaskEither<Failure, Unit> call({required Vault vault, required String name}) {
    return TaskEither(() async {
      final folderPath = _fileSystemAdapter.joinPaths(vault.path, name);
      return _fileSystemAdapter.createDirectory(folderPath);
    });
  }
}
