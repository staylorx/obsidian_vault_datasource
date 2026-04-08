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
    String content = '',
    bool overwrite = false,
    String? path,
  }) {
    return _validateMarkdown(content: content).flatMap(
      (_) => TaskEither(() async {
        final existingNote = vault.findNote(title);
        if (existingNote != null && !overwrite) {
          return Left(NoteAlreadyExistsFailure(title));
        }

        final note = Note(title: title, content: content);
        final notePath =
            path ?? _fileSystemAdapter.joinPaths(vault.path, '$title.md');

        final existsResult = await _fileSystemAdapter.fileExists(notePath);
        final fileExists = existsResult.fold((_) => false, (e) => e);
        if (fileExists && !overwrite) {
          return Left(FileExistsFailure(notePath));
        }

        final result = await _noteRepository.writeNote(notePath, note);

        return result.map((_) => note.copyWith(path: notePath));
      }),
    );
  }
}
