# Changelog

All notable changes to this project will be documented in this file.

## 1.0.2 - Attachment Support (2026-04-08)

### Features

- Attachment entity with type detection (image/video/audio/pdf)
- Load attachments from vault directory
- Write attachments to vault
- Delete attachments from vault
- Read attachment bytes
- Support for images (png, jpg, gif, webp, svg, bmp)
- Support for videos (mp4, mov, webm, avi, mkv)
- Support for audio (mp3, wav, ogg, m4a, flac)
- Support for PDFs

### API Changes

- `ObsidianVault.loadAttachments()` - Load all attachments
- `ObsidianVault.getAttachment(fileName)` - Get specific attachment
- `ObsidianVault.writeAttachment(fileName, bytes)` - Write attachment
- `ObsidianVault.deleteAttachment(fileName)` - Delete attachment
- `ObsidianVault.readAttachmentBytes(fileName)` - Read raw bytes

## 1.0.1 - File Watching & YAML Improvements (2026-04-08)

### Features

- VaultWatcher class for live vault updates
- Dart Streams for change notifications
- Start/stop watching lifecycle
- Real-time refresh on file changes

### YAML Parsing (Improved)

- Full YAML package integration
- Nested objects in frontmatter
- Arrays and complex types
- Proper boolean and date handling

### Bug Fixes

- Fixed canvas file handling - now properly ignored
- Fixed path handling for nested folders

## 1.0.0

- Initial version.
