---
tags: [documentation, dev, notes]
created: 2024-01-15
updated: 2026-04-08
---

# Development Notes

Internal notes for developing the Obsidian Vault Datasource.

## Current Work

- v1.0.0 released on 2026-04-08

## Architecture Decisions

### Why fpdart TaskEither?
- Provides fluent async error handling
- Composable operations
- Preferred over Future<Either> for readability

### Why custom YAML parser?
- Simpler than pulling in full yaml package
- Covers 90% of Obsidian frontmatter use cases
- Can upgrade to yaml package later if needed

### File System Adapter Pattern
- Abstraction over dart:io for testability
- Can swap with in-memory implementation
- Future: mock for unit tests

## Testing Strategy

- Integration tests with temp directories
- Example vault for real-world testing
- Shouldly for readable assertions

## Known Limitations

- No file watching (manual refresh required)
- No support for Obsidian attachments (images, etc.)
- Basic frontmatter parsing (no complex YAML)

## Future Considerations

- Consider adding file watching for live updates
- Could add support for canvas files
- Consider adding more sophisticated YAML parsing

## Related

- [Changelog](Changelog.md)
- [Reference/Documentation/Documentation.md](Reference/Documentation/Documentation.md)