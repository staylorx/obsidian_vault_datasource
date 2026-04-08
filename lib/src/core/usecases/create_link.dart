import 'package:fpdart/fpdart.dart';
import '../../domain/entities/entities.dart';
import '../../domain/failures.dart';
import '../../data/repositories/note_repository.dart';

class CreateLink {
  CreateLink(this._noteRepository);

  final NoteRepository _noteRepository;

  TaskEither<Failure, Note> call(
      {required Note ref,
      required String targetTitle,
      String? alias,
      bool createIfMissing = false}) {
    return TaskEither(() async {
      final link = Link(
        target: targetTitle,
        alias: alias,
        createIfMissing: createIfMissing,
      );

      final updatedNote = ref.copyWith(
        links: [...ref.links, link],
        content: '${ref.content}\n\n${link.toMarkdown()}',
      );

      if (ref.path != null) {
        final result = await _noteRepository.writeNote(ref.path!, updatedNote);
        return result.map((_) => updatedNote);
      }

      return Right(updatedNote);
    });
  }
}
