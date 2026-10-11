# Obsidian Vault Datasource

A Dart library for working with Obsidian vault datasources using functional programming with fpdart.

## API Style

This library is built around [fpdart](https://pub.dev/packages/fpdart)'s `TaskEither` for type-safe error handling. All operations return `TaskEither<Failure, T>` - call `.run()` to get a `Future`:

```dart
// Each operation returns TaskEither
final result = await vault.createNote(title: 'Hello').run();

// Handle the Either
result.fold(
  (failure) => print('Error: $failure'),
  (note) => print('Created: ${note.title}'),
);
```

If you prefer plain Futures without the Either, you can add your own extension:

```dart
import 'package:fpdart/fpdart.dart';

extension TaskEitherExt<R, L> on TaskEither<R, L> {
  /// Executes the TaskEither and returns the value, throwing on failure
  Future<R> toFuture() async {
    return (await run()).getOrElse((l) => throw Exception(l.toString()));
  }

  /// Executes the TaskEither and returns the value, or a default
  Future<R> toFutureOr(R defaultValue) async {
    return (await run()).getOrElse((l) => defaultValue);
  }
}

// Now you can use:
final note = await vault.createNote(title: 'Hello').toFuture();
```

## Features

- Create and load Obsidian vaults
- CRUD operations for notes and folders
- Frontmatter properties support
- Wiki-style link management (`[[link]]`)
- Fluent API with TaskEither for error handling

## Installation

```yaml
dependencies:
  obsidian_vault_datasource: ^1.1.0
```

## Usage

```dart
import 'package:obsidian_vault_datasource/obsidian_vault_datasource.dart';

void main() async {
  // Load an existing vault - returns TaskEither, auto-refreshes
  final vaultResult = await ObsidianVault.load(path: '/path/to/vault').run();
  final vault = vaultResult.fold((f) => throw Exception(f), (v) => v);
  
  // Create a note
  await vault.createNote(title: 'Hello', content: 'World').run();
  
  // Find your note
  final note = vault.findNote(title: 'Hello');
  print(note?.title); // 'Hello'
}
```

## API

| Method | Description |
|--------|-------------|
| `ObsidianVault.create(path: 'path', name: 'name')` | Creates new vault directory |
| `ObsidianVault.load(path: 'path')` | Loads existing vault |
| `vault.refresh()` | Reloads vault from disk |
| `vault.createNote(title: 'title', content: 'content')` | Creates a note |
| `vault.createFolder(name: 'name')` | Creates a folder |
| `note.createProperty(key: 'key', value: value)` | Adds frontmatter |
| `note.createLink(targetTitle: 'target')` | Adds wiki link |

## Examples

See the `example/` directory for complete example:

- [Create Vault Example](example/create_vault_example.dart) - Creates a vault with folders and notes with links
- [Read Vault Example](example/read_vault_example.dart) - Loads the example vault and prints all notes, properties, and links

Run example:
```bash
dart run example/create_vault_example.dart
dart run example/read_vault_example.dart
```

## Testing

```bash
dart test
```

## License

MIT License - see [LICENSE](LICENSE) file.

## Trademark Notice

Flutter and Dart logos are trademarks of Google. Obsidian logs are trademarks of Obsidian. All images included in this project or documentation are owned by their respective copyright holders.
