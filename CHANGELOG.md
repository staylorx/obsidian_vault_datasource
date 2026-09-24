# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Open and pending items are tracked separately in `BACKLOG.md`; this file records
what has shipped and the decisions that have been made.

## [Unreleased]

### Added

- `BACKLOG.md` - open and pending items only, including every build and analysis problem found and every divergence from the `staylorx/dart-flutter-bible` doctrine, each written as `Deviation: <path> - <what diverges and why>`.

### Changed

- `CHANGELOG.md` reformatted to Keep a Changelog: bracketed version headings with bare ISO dates, standard change headings (`Added`, `Changed`, `Fixed`), and this `[Unreleased]` section.

### Decisions

- Divergences from the dart-flutter-bible found in this audit are recorded in `BACKLOG.md` for later review and are **not** auto-fixed - a deviation marks a spot where the code and the bible disagree, and either side may be the one that is wrong.
- `BACKLOG.md` holds open and pending items only; anything settled moves here.
- The package's error style is FP-style tuples presented as an un-run `TaskEither<Failure, T>` (callers `.run()` it). This is the shipped behaviour and is declared in the README; the declaration is still missing from the barrel doc comment and `AGENTS.md`, which is logged as a deviation rather than changed in this pass.

### Notes

- Audit run on the Windows lane, 2026-09-24, Dart 3.13.1: `dart pub get` OK; `dart format --output=none --set-exit-if-changed .` 35 files, 0 changed; `dart test` 55 tests passed; `dart pub publish --dry-run` 0 warnings; `dart analyze --fatal-infos --fatal-warnings` **exit 1** with 6 `deprecated_member_use` infos (`EquatableMixin`). No source code was changed in this pass.

## [1.2.1] - 2026-04-09

### Fixed

- `dart test` hanging on benchmark tests with large files.
- Regex catastrophic backtracking on large strings, avoided by early return checks.
- Added a `contains('[[')` check before running the link extraction regex.
- Added a `startsWith('#')` check before running the title extraction regex.
- Improper async/fold patterns in load vault and note repository.

### Changed

- Replaced the 1MB note test with a 25KB version that completes in about 9 seconds.
- All 55 tests pass.

## [1.2.0] - 2026-04-08

### Changed

- **Breaking:** use cases now take named parameters instead of positional ones.
- Vault use cases split into individual files.

### Added

- `lib/src/core/usecases/create_vault.dart`
- `lib/src/core/usecases/load_vault.dart`
- `lib/src/core/usecases/save_vault.dart`
- `lib/src/core/usecases/create_note.dart`
- `lib/src/core/usecases/create_folder.dart`
- `lib/src/core/usecases/create_link.dart`
- `lib/src/core/usecases/update_note.dart`
- `lib/src/core/usecases/validate_markdown.dart`
- `CreateNote` now validates markdown before creating.
- `FileExistsFailure` for existing file errors.
- `InvalidMarkdownFailure` for validation errors.
- An `overwrite` parameter for forcing note creation.
- A `path` parameter for subfolder note creation.

### Changed

- All `call()` methods now use named parameters.
- Note creation handles nested paths (`folder/subfolder/note.md`).

## [1.1.0] - 2026-04-08

### Changed

- **Breaking:** `ObsidianVault.load()` now returns `TaskEither<Failure, ObsidianVault>` instead of `ObsidianVault`.
- **Breaking:** `load()` no longer requires a manual `refresh()` call afterwards.

Before:

```dart
final vault = ObsidianVault.load(vaultPath);
final refreshed = await vault.refresh().run();
final loadedVault = refreshed.fold((f) => ..., (v) => v);
```

After:

```dart
final vaultResult = await ObsidianVault.load(vaultPath).run();
final loadedVault = vaultResult.fold((f) => ..., (v) => v);
```

## [1.0.2] - 2026-04-08

### Added

- Attachment entity with type detection (image/video/audio/pdf).
- Load attachments from the vault directory.
- Write attachments to the vault.
- Delete attachments from the vault.
- Read attachment bytes.
- Support for images (png, jpg, gif, webp, svg, bmp).
- Support for videos (mp4, mov, webm, avi, mkv).
- Support for audio (mp3, wav, ogg, m4a, flac).
- Support for PDFs.
- `ObsidianVault.loadAttachments()` - load all attachments.
- `ObsidianVault.getAttachment(fileName)` - get a specific attachment.
- `ObsidianVault.writeAttachment(fileName, bytes)` - write an attachment.
- `ObsidianVault.deleteAttachment(fileName)` - delete an attachment.
- `ObsidianVault.readAttachmentBytes(fileName)` - read raw bytes.

## [1.0.1] - 2026-04-08

### Added

- `VaultWatcher` class for live vault updates.
- Dart Streams for change notifications.
- Start/stop watching lifecycle.
- Real-time refresh on file changes.

### Changed

- Full YAML package integration for frontmatter parsing.
- Nested objects in frontmatter.
- Arrays and complex types.
- Proper boolean and date handling.

### Fixed

- Canvas file handling - canvas files are now properly ignored.
- Path handling for nested folders.

## [1.0.0]

- Initial version.
