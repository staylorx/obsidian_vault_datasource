/// Base failure class for all errors in this library.
class Failure implements Exception {
  const Failure(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Failed to find a file on disk.
class FileNotFoundFailure extends Failure {
  const FileNotFoundFailure(String path) : super('File not found: $path');
}

/// Failed to find a directory on disk.
class DirectoryNotFoundFailure extends Failure {
  const DirectoryNotFoundFailure(String path)
      : super('Directory not found: $path');
}

/// Failed to parse frontmatter in a note.
class InvalidFrontmatterFailure extends Failure {
  const InvalidFrontmatterFailure(String reason)
      : super('Invalid frontmatter: $reason');
}

/// Attempted to create a vault where one already exists.
class VaultAlreadyExistsFailure extends Failure {
  const VaultAlreadyExistsFailure(String path)
      : super('Vault already exists at: $path');
}

/// Attempted to create a note that already exists.
class NoteAlreadyExistsFailure extends Failure {
  const NoteAlreadyExistsFailure(String title)
      : super('Note already exists: $title');
}

/// Attempted to create a folder that already exists.
class FolderAlreadyExistsFailure extends Failure {
  const FolderAlreadyExistsFailure(String name)
      : super('Folder already exists: $name');
}

/// Link target note was not found.
class LinkTargetNotFoundFailure extends Failure {
  const LinkTargetNotFoundFailure(String target)
      : super('Link target not found: $target');
}

/// Property not found on a note.
class PropertyNotFoundFailure extends Failure {
  const PropertyNotFoundFailure(String key) : super('Property not found: $key');
}
