import 'package:fpdart/fpdart.dart';
import '../../domain/entities/entities.dart';
import '../../domain/failures.dart';
import '../../data/adapters/file_system_adapter.dart';
import '../../data/repositories/note_repository.dart';

/// Saves a vault's notes to disk.
class SaveVault {
  SaveVault(this._fileSystemAdapter, this._noteRepository);

  final FileSystemAdapter _fileSystemAdapter;
  final NoteRepository _noteRepository;

  TaskEither<Failure, Unit> call({required Vault vault}) {
    return TaskEither(() async {
      for (final note in vault.allNotes) {
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
