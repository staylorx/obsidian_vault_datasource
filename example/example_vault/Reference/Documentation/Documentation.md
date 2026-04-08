---
tags: [reference, documentation, tech]
updated: 2024-01-15
---

# Documentation

Technical documentation for the ObsidianDatasource project.

## Getting Started

See [[Welcome]] for a general overview.

### Installation

```bash
dart pub add obsidian_vault_datasource
```

### Quick Start

```dart
import 'package:obsidian_vault_datasource/obsidian_vault_datasource.dart';

void main() async {
  // Create a new vault
  final vault = ObsidianVault.create('/data/my-vault', 'My Vault');
  
  // Create a note
  await vault.createNote('Getting Started', content: '# Hello World').run();
  
  // Refresh to load from disk
  final refreshed = await vault.refresh().run();
  
  // Find your note
  final note = refreshed.fold((_) => null, (v) => v)?.findNote('Getting Started');
}
```

## Architecture

The library follows clean architecture principles:

```
lib/
├── src/
│   ├── domain/          # Business logic
│   │   ├── entities/   # Note, Folder, Vault
│   │   └── failures.dart
│   ├── data/           # Data layer
│   │   ├── adapters/   # FileSystemAdapter
│   │   └── repositories/
│   ├── core/           # Use cases
│   └── api/             # Public API
```

## API Reference

- [[Reference/API/Obsidian API]]
- [[Reference/API/Authentication]]

## Testing

```dart
test('create note', () async {
  final vault = ObsidianVault.create(tempDir, 'Test');
  await vault.createNote('Test Note').run();
  expect(vault.findNote('Test Note'), isNotNull);
});
```

## See Also

- [[Changelog/Changelog]] - Version history
- [Development Notes](Reference/Documentation/Development Notes.md) - Internal dev docs
- [[Reference/Tech Stack/Dart]]
- [[Reference/Tech Stack/Flutter]]
- [[Reference/External Services/AWS]]
