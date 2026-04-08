# AGENTS.md

## Commands

- `dart test` - Run all tests
- `dart analyze` - Run linting and type checks
- `dart pub get` - Install dependencies

## Testing

Tests auto-clean up temp directories. The example vault in `examples/example_vault/` is used for integration tests. The `.obsidian/` folder is automatically ignored when loading vaults.

### Testing Hard Skills

* Always use mocktail package if mocking is used at all (prefer real tests here since that's what we're building).
* Use a TDD-style Group-group-test naming that starts with "Given, when, then" in each of the names.
* Prefer use of "should" over expect as much as possible.

## API Design

The `ObsidianVault` uses a fluent builder pattern via `TaskEither<Failure, T>`:
```dart
final vault = ObsidianVault.create('path', 'name');
await vault.createNote('Note Title', content: 'Content').run();
final refreshed = await vault.refresh().run();
final note = refreshed.fold((_) => null, (v) => v)?.findNote('Note Title');
```

- `ObsidianVault.create()` - Creates new vault directory in memory
- `ObsidianVault.load()` - Loads existing vault, must call `refresh()` to populate
- `vault.refresh()` - Reloads vault from disk, returns new ObsidianVault instance
- `vault.createNote()`, `vault.createFolder()` - Write to disk immediately
- `note.createProperty()`, `note.updateContent()`, `note.createLink()` - Modify and persist

## Dependencies

- `fpdart` - TaskEither for async error handling (preferred over Future<Either>)
- `equatable` - Value equality for domain entities
- `yaml` - Frontmatter parsing (currently using custom parser, yaml package available)

## Cross-platform file development

- Always assume we're using LF-only file terminations but make no assumptions about platform: this should work on any platform with files including but not limited to Mac, Windows, Linux, etc.
