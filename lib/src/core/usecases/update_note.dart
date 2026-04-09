import 'package:fpdart/fpdart.dart';
import '../../domain/entities/entities.dart';
import '../../domain/failures.dart';
import '../../data/repositories/note_repository.dart';

/// Updates/saves an existing note to disk.
class UpdateNote {
  UpdateNote(this._noteRepository);

  final NoteRepository _noteRepository;

  TaskEither<Failure, Note> call({required Note note}) {
    return TaskEither(() async {
      if (note.path == null) {
        return Left(const NoteHasNoPathFailure());
      }

      final result = await _noteRepository.writeNote(note.path!, note);
      return result.map((_) => note);
    });
  }
}
