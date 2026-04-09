/// Base failure class for all errors in this library.
abstract class Failure implements Exception {
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

/// File already exists.
class FileExistsFailure extends Failure {
  const FileExistsFailure(String path) : super('File already exists: $path');
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

/// Invalid markdown content.
class InvalidMarkdownFailure extends Failure {
  const InvalidMarkdownFailure(String reason)
      : super('Invalid markdown: $reason');
}

/// Note has no path set.
class NoteHasNoPathFailure extends Failure {
  const NoteHasNoPathFailure() : super('Note has no path');
}

/// Cannot reload: vault was not loaded.
class CannotReloadFailure extends Failure {
  const CannotReloadFailure() : super('Cannot reload: vault was not loaded');
}

/// Failed to list directory.
class ListDirectoryFailure extends Failure {
  const ListDirectoryFailure(String reason)
      : super('Failed to list directory: $reason');
}

/// Failed to check file existence.
class CheckFileFailure extends Failure {
  const CheckFileFailure(String reason)
      : super('Failed to check file: $reason');
}

/// Failed to check directory existence.
class CheckDirectoryFailure extends Failure {
  const CheckDirectoryFailure(String reason)
      : super('Failed to check directory: $reason');
}

/// Failed to read file.
class ReadFileFailure extends Failure {
  const ReadFileFailure(String reason) : super('Failed to read file: $reason');
}

/// Failed to write file.
class WriteFileFailure extends Failure {
  const WriteFileFailure(String reason)
      : super('Failed to write file: $reason');
}

/// Failed to delete file.
class DeleteFileFailure extends Failure {
  const DeleteFileFailure(String reason)
      : super('Failed to delete file: $reason');
}

/// Failed to create directory.
class CreateDirectoryFailure extends Failure {
  const CreateDirectoryFailure(String reason)
      : super('Failed to create directory: $reason');
}

/// Failed to delete directory.
class DeleteDirectoryFailure extends Failure {
  const DeleteDirectoryFailure(String reason)
      : super('Failed to delete directory: $reason');
}

/// Failed to read file bytes.
class ReadFileBytesFailure extends Failure {
  const ReadFileBytesFailure(String reason)
      : super('Failed to read file bytes: $reason');
}

/// Failed to write file bytes.
class WriteFileBytesFailure extends Failure {
  const WriteFileBytesFailure(String reason)
      : super('Failed to write file bytes: $reason');
}

/// Failed to get file size.
class GetFileSizeFailure extends Failure {
  const GetFileSizeFailure(String reason)
      : super('Failed to get file size: $reason');
}

/// Failed to start watching vault.
class WatchFailure extends Failure {
  const WatchFailure(String reason)
      : super('Failed to start watching: $reason');
}
