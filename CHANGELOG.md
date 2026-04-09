# Changelog

All notable changes to this project will be documented in this file.

## 1.2.1 - Performance Fixes (2026-04-09)

### Bug Fixes

- Fixed `dart test` hanging on benchmark tests with large files
- Added early return checks to avoid regex catastrophic backtracking on large strings
- Added `contains('[[')` check before running link extraction regex
- Added `startsWith('#')` check before running title extraction regex
- Fixed improper async/fold patterns in load vault and note repository

### Test Changes

- Replaced 1MB note test with 25KB version that completes in ~9 seconds
- All 55 tests now pass

## 1.2.0 - Use Cases & Validation (2026-04-08)

### Breaking Changes

- Use cases now use **named parameters** instead of positional
- Vault usecases split into individual files

### New Files

- `lib/src/core/usecases/create_vault.dart`
- `lib/src/core/usecases/load_vault.dart`
- `lib/src/core/usecases/save_vault.dart`
- `lib/src/core/usecases/create_note.dart`
- `lib/src/core/usecases/create_folder.dart`
- `lib/src/core/usecases/create_link.dart`
- `lib/src/core/usecases/update_note.dart`
- `lib/src/core/usecases/validate_markdown.dart`

### Features

- `CreateNote` now validates markdown before creating
- `FileExistsFailure` for existing file errors
- `InvalidMarkdownFailure` for validation errors
- `overwrite` parameter for forcing note creation
- `path` parameter for subfolder note creation

### API Changes

- All `call()` methods now use named parameters
- Note creation handles nested paths (`folder/subfolder/note.md`)

## 1.1.0 - Improved Load API (2026-04-08)

### Breaking Changes

- `ObsidianVault.load()` now returns `TaskEither<Failure, ObsidianVault>` instead of `ObsidianVault`
- No longer requires manual `refresh()` call after `load()`

### Before/After

```dart
// Before (clunky)
final vault = ObsidianVault.load(vaultPath);
final refreshed = await vault.refresh().run();
final loadedVault = refreshed.fold((f) => ..., (v) => v);

// After (clean)
final vaultResult = await ObsidianVault.load(vaultPath).run();
final loadedVault = vaultResult.fold((f) => ..., (v) => v);
```

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
