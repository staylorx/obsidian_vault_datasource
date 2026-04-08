class Failure implements Exception {
  const Failure(this.message);

  final String message;

  @override
  String toString() => message;
}

class FileNotFoundFailure extends Failure {
  const FileNotFoundFailure(String path) : super('File not found: $path');
}

class DirectoryNotFoundFailure extends Failure {
  const DirectoryNotFoundFailure(String path)
      : super('Directory not found: $path');
}

class InvalidFrontmatterFailure extends Failure {
  const InvalidFrontmatterFailure(String reason)
      : super('Invalid frontmatter: $reason');
}

class VaultAlreadyExistsFailure extends Failure {
  const VaultAlreadyExistsFailure(String path)
      : super('Vault already exists at: $path');
}

class NoteAlreadyExistsFailure extends Failure {
  const NoteAlreadyExistsFailure(String title)
      : super('Note already exists: $title');
}

class FolderAlreadyExistsFailure extends Failure {
  const FolderAlreadyExistsFailure(String name)
      : super('Folder already exists: $name');
}

class LinkTargetNotFoundFailure extends Failure {
  const LinkTargetNotFoundFailure(String target)
      : super('Link target not found: $target');
}

class PropertyNotFoundFailure extends Failure {
  const PropertyNotFoundFailure(String key) : super('Property not found: $key');
}
