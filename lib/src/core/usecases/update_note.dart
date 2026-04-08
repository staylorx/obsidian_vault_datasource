import 'package:fpdart/fpdart.dart';
import '../../domain/entities/entities.dart';
import '../../domain/failures.dart';
import '../../data/repositories/note_repository.dart';

/// Updates/saves an existing note to disk.
class UpdateNote {
  UpdateNote(this._noteRepository);

  final NoteRepository _noteRepository;

  TaskEither<Failure, Note> call({required Note ref}) {
    return TaskEither(() async {
      if (ref.path == null) {
        return Left(const Failure('Note has no path'));
      }

      final result = await _noteRepository.writeNote(ref.path!, ref);
      return result.map((_) => ref);
    });
  }
}
