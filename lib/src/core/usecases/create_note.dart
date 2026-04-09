import 'package:fpdart/fpdart.dart';
import '../../domain/entities/entities.dart';
import '../../domain/failures.dart';
import '../../data/adapters/file_system_adapter.dart';
import '../../data/repositories/note_repository.dart';
import 'validate_markdown.dart';

/// Creates a new note in a vault.
class CreateNote {
  CreateNote(this._fileSystemAdapter, this._noteRepository)
      : _validateMarkdown = const ValidateMarkdown();

  final FileSystemAdapter _fileSystemAdapter;
  final NoteRepository _noteRepository;
  final ValidateMarkdown _validateMarkdown;

  TaskEither<Failure, Note> call({
    required Vault vault,
    required String title,
    required String path,
    String content = '',
    bool overwrite = false,
  }) {
    return _validateMarkdown(content: content).flatMap(
      (_) => TaskEither(() async {
        final existingNote = vault.findNote(title);
        if (existingNote != null && !overwrite) {
          return Left(NoteAlreadyExistsFailure(title));
        }

        final note = Note(title: title, content: content);

        final existsResult = await _fileSystemAdapter.fileExists(path);
        final fileExists = existsResult.fold((_) => false, (e) => e);
        if (fileExists && !overwrite) {
          return Left(FileExistsFailure(path));
        }

        final result = await _noteRepository.writeNote(path, note);

        return result.map((_) => note.copyWith(path: path));
      }),
    );
  }
}
