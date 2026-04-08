---
tags: [documentation, dev, notes]
created: 2024-01-15
updated: 2026-04-08
---

# Development Notes

Internal notes for developing the Obsidian Vault Datasource.

## Current Work

- v1.0.1 released on 2026-04-08
- File watching support added
- YAML parsing improved with full yaml package

## Architecture Decisions

### Why fpdart TaskEither?
- Provides fluent async error handling
- Composable operations
- Preferred over Future<Either> for readability

### Why yaml package?
- Full YAML 1.1 support
- Handles nested objects, arrays, booleans, dates
- Replaces custom parser from v1.0.0

### VaultWatcher
- Uses `watcher` package for cross-platform file watching
- Dart Streams for reactive change notifications
- Can be started/stopped cyclically

### File System Adapter Pattern
- Abstraction over dart:io for testability
- Can swap with in-memory implementation
- Future: mock for unit tests

## Testing Strategy

- Integration tests with temp directories
- Example vault for real-world testing
- Shouldly for readable assertions

## Known Limitations

- No support for Obsidian attachments (images, etc.)
- Canvas files are not supported (presentation-specific)

## Future Considerations

- Consider adding support for canvas files
- Could add more search capabilities
- Consider adding attachment handling

## Related

- [Changelog](Changelog.md)
- [Reference/Documentation/Documentation.md](Reference/Documentation/Documentation.md)