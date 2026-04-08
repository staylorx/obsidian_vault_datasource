---
tags: [documentation, dev, notes]
created: 2024-01-15
updated: 2026-04-08
---

# Development Notes

Internal notes for developing the Obsidian Vault Datasource.

## Current Work

- v1.0.2 released on 2026-04-08
- Attachment support added for images, videos, audio, PDFs

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

### Attachment Support
- Binary file read/write via FileSystemAdapter
- AttachmentRepository for CRUD operations
- Automatic file type detection (image/video/audio/pdf)
- ObsidianVault API: loadAttachments, getAttachment, writeAttachment, deleteAttachment

### File System Adapter Pattern
- Abstraction over dart:io for testability
- Can swap with in-memory implementation
- Binary operations added for attachments

## Testing Strategy

- Integration tests with temp directories
- Example vault for real-world testing
- Shouldly for readable assertions

## Known Limitations

- Canvas files are not supported (presentation-specific)

## Future Considerations

- Consider adding support for canvas files
- Could add more search capabilities
- Could add attachment embedding in notes

## Related

- [Changelog](Changelog.md)
- [Reference/Documentation/Documentation.md](Reference/Documentation/Documentation.md)