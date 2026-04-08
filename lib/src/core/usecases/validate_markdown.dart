import 'package:fpdart/fpdart.dart';
import 'package:markdown/markdown.dart';
import '../../domain/failures.dart';

/// Validates markdown content can be parsed.
class ValidateMarkdown {
  const ValidateMarkdown();

  TaskEither<Failure, Unit> call({required String content}) {
    return TaskEither(() async {
      try {
        Document().parse(content);
        return const Right(unit);
      } catch (e) {
        return Left(InvalidMarkdownFailure(e.toString()));
      }
    });
  }
}
