# Obsidian Vault Datasource

A Dart library for working with Obsidian vault datasources using functional programming with fpdart.

## Features

- Create and load Obsidian vaults
- CRUD operations for notes and folders
- Frontmatter properties support
- Wiki-style link management (`[[link]]`)
- Fluent API with TaskEither for error handling

## Installation

```yaml
dependencies:
  obsidian_vault_datasource: ^1.0.2
```

## Usage

```dart
import 'package:obsidian_vault_datasource/obsidian_vault_datasource.dart';

void main() async {
  // Create a new vault
  final vault = ObsidianVault.create('/path/to/vault', 'My Vault');
  await vault.createNote('Hello', content: 'World').run();
  
  // Refresh to load from disk
  final refreshed = await vault.refresh().run();
  final loadedVault = refreshed.fold((_) => vault, (v) => v);
  
  // Find your note
  final note = loadedVault.findNote('Hello');
  print(note?.title); // 'Hello'
}
```

## API

| Method | Description |
|--------|-------------|
| `ObsidianVault.create(path, name)` | Creates new vault directory |
| `ObsidianVault.load(path)` | Loads existing vault |
| `vault.refresh()` | Reloads vault from disk |
| `vault.createNote(title, content)` | Creates a note |
| `vault.createFolder(name)` | Creates a folder |
| `note.createProperty(key, value)` | Adds frontmatter |
| `note.createLink(target)` | Adds wiki link |

## Examples

See the `examples/` directory for complete examples:

- [Create Vault Example](examples/create_vault_example.dart) - Creates a vault with folders and notes with links
- [Read Vault Example](examples/read_vault_example.dart) - Loads the example vault and prints all notes, properties, and links

Run examples:
```bash
dart run examples/create_vault_example.dart
dart run examples/read_vault_example.dart
```

## Testing

```bash
dart test
```

## License

MIT License - see [LICENSE](LICENSE) file.

## Trademark Notice

Flutter and Dart logos are trademarks of Google. The Flutter and Dart images included in this project or documentation are owned by their copyright holder, Google. This project is not affiliated with or endorsed by Google.
