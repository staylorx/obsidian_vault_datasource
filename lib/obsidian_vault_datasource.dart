/// Dart library for working with Obsidian vaults using functional programming.
///
/// Use [ObsidianVault] to create, load, and manage Obsidian vault content.
/// Requires fpdart for TaskEither-based error handling.
library;

export 'src/domain/entities/entities.dart';
export 'src/domain/failures.dart';
export 'src/data/adapters/file_system_adapter.dart';
export 'src/data/repositories/note_repository.dart';
export 'src/data/repositories/attachment_repository.dart';
export 'src/core/usecases/vault_usecases.dart';
export 'src/api/obsidian_api.dart';
export 'src/api/vault_watcher.dart';
