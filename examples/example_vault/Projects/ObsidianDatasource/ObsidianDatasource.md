---
tags: [project, dart, library]
status: in-progress
priority: high
created: 2024-01-01
---

# ObsidianDatasource

A Dart library for working with Obsidian vault datasources.

## Overview

This library provides a fluent API for CRUD operations on Obsidian vaults, similar to working with databases or YAML files.

## Features

- ✅ Vault loading and creation
- ✅ Note CRUD operations
- ✅ Frontmatter properties
- ✅ Link management
- 🔄 Folder hierarchy
- 🔄 Search

## Architecture

See [[Reference/Documentation/Architecture]] for details.

### Key Classes

- `ObsidianVault` - Main entry point
- `ObsidianNote` - Note manipulation
- `FileSystemAdapter` - File operations

## Dependencies

```yaml
dependencies:
  fpdart: ^1.2.0
  equatable: ^2.0.7
  yaml: ^3.1.2
```

## Usage

```dart
final vault = ObsidianVault.create('/path', 'My Vault');
await vault.createNote('Hello', content: 'World').run();
```

---

**Related**:
- [[Projects/ObsidianDatasource/API Integration]]
- [[Projects/ObsidianDatasource/Code Review PR #42]]
- [[Projects/ObsidianDatasource/v1.0 Release]]
- [[Reference/API/Obsidian API]]
