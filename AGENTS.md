# AGENTS.md

## Commands

- `dart test` - Run all tests
- `dart analyze` - Run linting and type checks
- `dart pub get` - Install dependencies

## Testing

Tests auto-clean up temp directories. The example vault in `example/example_vault/` is used for integration tests. The `.obsidian/` folder is automatically ignored when loading vaults.

### Test Conventions

* Use `shouldly` package for assertions (`.should.be()`, `.should.contain()`, etc.)
* Naming: `group-Given, group-when, test-then`
  ```dart
  group('Given a Note entity', () {
    group('when converting to Markdown', () {
      test('should include frontmatter when properties exist', () { ... });
    });
  });
  ```

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
