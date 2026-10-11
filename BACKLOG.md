# Backlog

Open and pending items only. Decisions that have been made, and what shipped, go in `CHANGELOG.md`; this file is the list of things not done yet. One item per line.

## Build, analysis and dependency problems

- `dart_arch_test` is not a dev dependency, so the package-boundary and cycle-freedom gate is absent.
- README's `TaskEitherExt` sample reverses fpdart's `TaskEither<L, R>` parameter order and does not type-check against the values it is called on.
- README install snippet pins `obsidian_vault_datasource: ^1.1.0` while the package is at 1.2.1.
- `createIfMissing` is documented and accepted but never read; no note is ever created.
- `ObsidianNote.updateTitle` changes the heading but writes to the pre-rename path, so the file keeps its old name.
- `Note.toMarkdown` / `fromMarkdown` are not a lossless round trip; `fromMarkdown` trims leading/trailing blank lines.
- Malformed frontmatter fails silently; the parser swallows the parse error and reports no failure.
- File-type detection lists are duplicated in three places, so adding a type means three hand-synced edits.
- `test/benchmark_test.dart` asserts with `expect()` while all other test files assert with shouldly.
- `example/*.dart` carry blanket `avoid_print` suppresses and are exercised by no test or CI.
- The benchmark suite asserts wall-clock budgets with no warm-up, so it is machine-dependent.

## Deviations from the dart-flutter-bible

Compared against `staylorx/dart-flutter-bible`. Each item is a spot where this repo differs from the bible; flagged for review and deliberately not auto-fixed.

- Deviation: `lib/src/domain/failures.dart` - one flat `Failure implements Exception` with 22 non-sealed leaves instead of per-layer closed hierarchies.
- Deviation: `lib/src/api/obsidian_api.dart` - the public seam hands consumers un-run `TaskEither<Failure, T>`; the deviation from `Future<Either<Failure, T>>` is declared in the README but not in the barrel doc or AGENTS.md.
- Deviation: `lib/src/api/obsidian_api.dart` - `refresh()` and `loadAttachments()` wrap already-Either-returning calls in `TaskEither(() async {...})` instead of composing with `map`/`flatMap`.
- Deviation: `lib/src/api/vault_watcher.dart` - hand-rolled `try/catch` instead of `TaskEither.tryCatch`; the same shape appears in `validate_markdown.dart` and in domain `note.dart` where it is a hard ban.
- Deviation: `lib/src/data/adapters/file_system_adapter.dart` - 11 hand-rolled `try/catch` blocks instead of `Either.tryCatch`/`TaskEither.tryCatch`.
- Deviation: `lib/src/data/repositories/note_repository.dart` - only one repository and one adapter implementation exist, so the at-least-two-adapter rule and shared contract suite are absent.
- Deviation: `lib/src/data/adapters/file_system_adapter.dart` - the adapter is a concrete class constructed inside `ObsidianVault.create`/`load` and injected directly; no interface exists for the seam, and repository/datasource contracts belong in the domain package.
- Deviation: `pubspec.yaml` - a single monolithic package holding domain/usecases/data/api instead of separate packages, so no package boundary enforces inward dependencies and `dart_arch_test` has nothing to assert.
- Deviation: `pubspec.yaml` - `environment: sdk` is `>=3.0.0 <4.0.0` instead of the mandated `>=3.10.0 <4.0.0`.
- Deviation: `lib/src/domain/entities/note.dart` - the domain entity imports `package:yaml` and parses frontmatter itself, where the domain package should allow only `equatable` and `fpdart`.
- Deviation: `lib/src/api/obsidian_api.dart` - three public classes in one file, and `vault_watcher.dart` holds several types, against the one-class-per-file rule.
- Deviation: `analysis_options.yaml` - `public_member_api_docs` is not enabled, `todo` is not mapped to `error`, and `prefer_const_constructors` is both listed as a rule and ignored.
- Deviation: undocumented public members are pervasive, including `CreateLink.call`; sections 2 and 10 require a terse `///` on every declaration and public member.
- Deviation: `lib/src/core/usecases/create_link.dart` and `create_note.dart` - `call()` takes whole entities where section 4 asks for discrete business params; judgement call, needs review.
- Deviation: `lib/src/core/usecases/create_note.dart` - `call()` requires a filesystem `path` callers compose above the use case, making the signature path-shaped rather than business-shaped.
- Deviation: `lib/src/core/usecases/create_note.dart` - the use case checks both `vault.findNote` and file existence, holding two sources of truth for "does this note exist".
- Deviation: tests assert with `.should.beTrue()` / `.should.beFalse()`, which section 6 states shouldly does not have; it compiles on the pinned shouldly, so the bible looks wrong rather than the code.
- Deviation: `lib/src/core/usecases/vault_usecases.dart` and `lib/src/domain/entities/entities.dart` - extra re-export barrels inside `src/` beyond the mandated single library barrel.
- Deviation: `README.md` - carries a complete code sample and an API table where section 2 puts example code in tests first.
- Deviation: `lib/src/api/obsidian_api.dart` - `ObsidianFolder.createNote` builds its path with a raw `Platform.pathSeparator` while every other call site goes through `FileSystemAdapter.joinPaths`.
- Deviation: `lib/src/api/obsidian_api.dart` - `_attachments` is mutated in place inside otherwise pure-looking TaskEither chains.
- Deviation: `pubspec.yaml` - `analysis_options.yaml` uses the standard `lints/recommended` set with hand-listed rules rather than the stricter bible set.
