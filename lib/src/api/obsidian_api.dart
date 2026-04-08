import 'dart:io';
import 'package:fpdart/fpdart.dart';
import '../domain/entities/entities.dart';
import '../domain/failures.dart';
import '../data/adapters/file_system_adapter.dart';
import '../data/repositories/note_repository.dart';
import '../data/repositories/attachment_repository.dart';
import '../core/usecases/vault_usecases.dart';

/// Main API class for interacting with an Obsidian vault.
///
/// Use [ObsidianVault.create] to create a new vault, or [ObsidianVault.load] to load an existing one.
/// All operations return [TaskEither] - call [TaskEither.run] to get a [Future].
class ObsidianVault {
  final Vault _vault;
  final FileSystemAdapter _fileSystemAdapter;
  final NoteRepository _noteRepository;
  final AttachmentRepository _attachmentRepository;
  final CreateNote _createNote;
  final CreateFolder _createFolder;
  final CreateLink _createLink;
  final SaveVault _saveVault;
  final LoadVault? _loadVault;
  List<Attachment> _attachments;

  ObsidianVault._(
    this._vault,
    this._fileSystemAdapter,
    this._noteRepository,
    this._attachmentRepository,
    this._createNote,
    this._createFolder,
    this._createLink,
    this._saveVault, [
    this._loadVault,
  ]) : _attachments = [];

  /// Creates a new vault at the given path.
  ///
  /// [path] is the directory path. [name] is the vault name.
  factory ObsidianVault.create({required String path, required String name}) {
    final fileSystemAdapter = FileSystemAdapter();
    final noteRepository = NoteRepository(fileSystemAdapter);
    final attachmentRepository = AttachmentRepository(fileSystemAdapter);
    final createNote = CreateNote(fileSystemAdapter, noteRepository);
    final createFolder = CreateFolder(fileSystemAdapter);
    final createLink = CreateLink(noteRepository);
    final saveVault = SaveVault(fileSystemAdapter, noteRepository);

    final vault = Vault(name: name, path: path);
    return ObsidianVault._(
      vault,
      fileSystemAdapter,
      noteRepository,
      attachmentRepository,
      createNote,
      createFolder,
      createLink,
      saveVault,
    );
  }

  /// Loads an existing vault from disk.
  ///
  /// Returns a [TaskEither] that yields an [ObsidianVault] on success,
  /// or a [Failure] on error. The vault contents are automatically loaded.
  ///
  /// [path] is the vault directory path.
  static TaskEither<Failure, ObsidianVault> load({required String path}) {
    final fileSystemAdapter = FileSystemAdapter();
    final noteRepository = NoteRepository(fileSystemAdapter);
    final attachmentRepository = AttachmentRepository(fileSystemAdapter);
    final createNote = CreateNote(fileSystemAdapter, noteRepository);
    final createFolder = CreateFolder(fileSystemAdapter);
    final createLink = CreateLink(noteRepository);
    final saveVault = SaveVault(fileSystemAdapter, noteRepository);
    final loadVaultUseCase = LoadVault(fileSystemAdapter, noteRepository);

    return loadVaultUseCase(path).map((loadedVault) => ObsidianVault._(
          loadedVault,
          fileSystemAdapter,
          noteRepository,
          attachmentRepository,
          createNote,
          createFolder,
          createLink,
          saveVault,
          loadVaultUseCase,
        ));
  }

  /// Reloads the vault from disk.
  ///
  /// Use after external changes to refresh vault state.
  TaskEither<Failure, ObsidianVault> reload() {
    final loadVaultUseCase = _loadVault;
    if (loadVaultUseCase == null) {
      return TaskEither(() async =>
          Left(const Failure('Cannot reload: vault was not loaded')));
    }

    return loadVaultUseCase(_vault.path).map((loadedVault) {
      return ObsidianVault._(
        loadedVault,
        _fileSystemAdapter,
        _noteRepository,
        _attachmentRepository,
        _createNote,
        _createFolder,
        _createLink,
        _saveVault,
        _loadVault,
      );
    });
  }

  /// The vault name.
  String get name => _vault.name;

  /// The vault path on disk.
  String get path => _vault.path;

  /// The underlying Vault entity.
  Vault get vault => _vault;

  /// Finds a note by title.
  ///
  /// [title] is the note title to search for.
  Note? findNote({required String title}) => _vault.findNote(title);

  /// Searches notes by title or content.
  ///
  /// [query] is the search term.
  List<Note> searchNotes({required String query}) => _vault.searchNotes(query);

  /// All notes in the vault.
  List<Note> get allNotes => _vault.allNotes;

  /// Creates a new note in the vault.
  ///
  /// [title] is the note title. [content] is optional initial content.
  TaskEither<Failure, ObsidianNote> createNote({
    required String title,
    String content = '',
  }) {
    return _createNote(_vault, title, content: content).map((note) {
      final updatedFolder = _vault.rootFolder.copyWith(
        notes: [..._vault.rootFolder.notes, note],
      );
      final updatedVault = _vault.copyWith(rootFolder: updatedFolder);
      return ObsidianNote._(
        note,
        updatedVault,
        _fileSystemAdapter,
        _noteRepository,
        _createLink,
      );
    });
  }

  /// Creates a new folder in the vault.
  ///
  /// [name] is the folder name.
  TaskEither<Failure, Unit> createFolder({required String name}) {
    return _createFolder(_vault, name);
  }

  /// Saves all vault notes to disk.
  TaskEither<Failure, Unit> save() {
    return _saveVault(_vault);
  }

  /// Refreshes the vault by re-reading from disk.
  TaskEither<Failure, ObsidianVault> refresh() {
    return TaskEither(() async {
      final rootFolderResult =
          await _noteRepository.loadFolder(_vault.path, '');

      return rootFolderResult.fold(
        (failure) => Left(failure),
        (rootFolder) {
          final updatedVault = _vault.copyWith(rootFolder: rootFolder);
          return Right(ObsidianVault._(
            updatedVault,
            _fileSystemAdapter,
            _noteRepository,
            _attachmentRepository,
            _createNote,
            _createFolder,
            _createLink,
            _saveVault,
            _loadVault,
          ));
        },
      );
    });
  }

  /// Returns the list of loaded attachments.
  List<Attachment> get attachments => _attachments;

  /// Loads all attachments from the vault directory.
  TaskEither<Failure, List<Attachment>> loadAttachments() {
    return TaskEither(() async {
      final result =
          await _attachmentRepository.readAttachmentsFromDirectory(_vault.path);
      return result.fold(
        (failure) => Left(failure),
        (attachments) {
          _attachments = attachments;
          return Right(attachments);
        },
      );
    });
  }

  /// Gets a specific attachment by filename.
  ///
  /// [fileName] is the name of the attachment.
  TaskEither<Failure, Attachment> getAttachment({required String fileName}) {
    return TaskEither(() async {
      final attachmentPath =
          _fileSystemAdapter.joinPaths(_vault.path, fileName);
      return _attachmentRepository.readAttachment(attachmentPath);
    });
  }

  /// Writes an attachment to the vault.
  ///
  /// [fileName] is the target filename. [bytes] is the binary content.
  TaskEither<Failure, Unit> writeAttachment({
    required String fileName,
    required List<int> bytes,
  }) {
    return TaskEither(() async {
      final attachmentPath =
          _fileSystemAdapter.joinPaths(_vault.path, fileName);
      final result =
          await _attachmentRepository.writeAttachment(attachmentPath, bytes);
      return result.fold(
        (failure) => Left(failure),
        (_) async {
          _attachments = [
            ..._attachments,
            Attachment(
              fileName: fileName,
              path: attachmentPath,
              fileType: _getFileType(fileName),
              size: bytes.length,
            ),
          ];
          return const Right(unit);
        },
      );
    });
  }

  /// Deletes an attachment from the vault.
  ///
  /// [fileName] is the name of the attachment to delete.
  TaskEither<Failure, Unit> deleteAttachment({required String fileName}) {
    return TaskEither(() async {
      final attachmentPath =
          _fileSystemAdapter.joinPaths(_vault.path, fileName);
      final result = await _fileSystemAdapter.deleteFile(attachmentPath);
      return result.fold(
        (failure) => Left(failure),
        (_) {
          _attachments =
              _attachments.where((a) => a.fileName != fileName).toList();
          return const Right(unit);
        },
      );
    });
  }

  /// Reads raw bytes from an attachment.
  ///
  /// [fileName] is the name of the attachment.
  TaskEither<Failure, List<int>> readAttachmentBytes(
      {required String fileName}) {
    return TaskEither(() async {
      final attachmentPath =
          _fileSystemAdapter.joinPaths(_vault.path, fileName);
      return _fileSystemAdapter.readFileBytes(attachmentPath);
    });
  }

  String _getFileType(String fileName) {
    final extension =
        fileName.contains('.') ? fileName.split('.').last.toLowerCase() : '';
    if (['png', 'jpg', 'jpeg', 'gif', 'webp', 'svg', 'bmp']
        .contains(extension)) {
      return 'image';
    }
    if (['mp4', 'mov', 'webm', 'avi', 'mkv'].contains(extension)) {
      return 'video';
    }
    if (['mp3', 'wav', 'ogg', 'm4a', 'flac'].contains(extension)) {
      return 'audio';
    }
    if (extension == 'pdf') return 'pdf';
    return 'file';
  }
}

/// Represents a folder within an Obsidian vault with notes and subfolders.
class ObsidianFolder {
  final Folder _folder;
  final Vault _vault;
  final FileSystemAdapter _fileSystemAdapter;
  final NoteRepository _noteRepository;
  final CreateLink _createLink;

  ObsidianFolder._(
    this._folder,
    this._vault,
    this._fileSystemAdapter,
    this._noteRepository,
    this._createLink,
  );

  /// The folder name.
  String get name => _folder.name;

  /// Notes in this folder.
  List<Note> get notes => _folder.notes;

  /// Subfolders in this folder.
  List<Folder> get subfolders => _folder.subfolders;

  /// Finds a note by title in this folder or subfolders.
  ///
  /// [title] is the note title to search for.
  Note? findNote({required String title}) {
    for (final note in _folder.notes) {
      if (note.title == title) return note;
    }
    for (final subfolder in _folder.subfolders) {
      final found =
          subfolder.allNotes.where((n) => n.title == title).firstOrNull;
      if (found != null) return found;
    }
    return null;
  }

  /// Creates a note in this folder.
  ///
  /// [title] is the note title. [content] is optional initial content.
  TaskEither<Failure, ObsidianNote> createNote({
    required String title,
    String content = '',
  }) {
    final notePath = _fileSystemAdapter.joinPaths(_vault.path,
        '${_folder.name.isNotEmpty ? _folder.name + Platform.pathSeparator : ''}$title.md');
    final note = Note(title: title, content: content, path: notePath);

    return TaskEither(() async {
      final result = await _noteRepository.writeNote(notePath, note);
      return result.map((_) {
        final updatedFolder = _folder.copyWith(notes: [..._folder.notes, note]);
        return ObsidianNote._(
          note,
          _vault.copyWith(rootFolder: updatedFolder),
          _fileSystemAdapter,
          _noteRepository,
          _createLink,
        );
      });
    });
  }
}

/// Represents a note within an Obsidian vault with fluent mutation API.
class ObsidianNote {
  final Note _note;
  final Vault _vault;
  final FileSystemAdapter _fileSystemAdapter;
  final NoteRepository _noteRepository;
  final CreateLink _createLink;

  ObsidianNote._(
    this._note,
    this._vault,
    this._fileSystemAdapter,
    this._noteRepository,
    this._createLink,
  );

  /// The note title.
  String get title => _note.title;

  /// The note content.
  String get content => _note.content;

  /// Frontmatter properties.
  List<Property> get properties => _note.properties;

  /// Wiki-style links from this note.
  List<Link> get links => _note.links;

  /// The underlying Note entity.
  Note get note => _note;

  /// The vault this note belongs to.
  Vault get vault => _vault;

  /// Updates the note content.
  ///
  /// [content] is the new content.
  TaskEither<Failure, ObsidianNote> updateContent({required String content}) {
    final updatedNote = _note.copyWith(content: content);
    return _persistNote(updatedNote);
  }

  /// Updates the note title.
  ///
  /// [title] is the new title.
  TaskEither<Failure, ObsidianNote> updateTitle({required String title}) {
    final updatedNote = _note.copyWith(title: title);
    return _persistNote(updatedNote);
  }

  /// Creates a new property on the note.
  ///
  /// [key] is the property key. [value] is the property value.
  /// [frontmatter] if true, writes to YAML frontmatter.
  TaskEither<Failure, ObsidianNote> createProperty({
    required String key,
    required dynamic value,
    bool frontmatter = true,
  }) {
    final property =
        Property(key: key, value: value, isFrontmatter: frontmatter);
    final updatedNote =
        _note.copyWith(properties: [..._note.properties, property]);
    return _persistNote(updatedNote);
  }

  /// Updates an existing property.
  ///
  /// [key] is the property to update. [value] is the new value.
  TaskEither<Failure, ObsidianNote> updateProperty({
    required String key,
    required dynamic value,
  }) {
    final updatedProperties = _note.properties.map((p) {
      if (p.key == key) return p.copyWith(value: value);
      return p;
    }).toList();
    final updatedNote = _note.copyWith(properties: updatedProperties);
    return _persistNote(updatedNote);
  }

  /// Removes a property from the note.
  ///
  /// [key] is the property key to remove.
  TaskEither<Failure, ObsidianNote> removeProperty({required String key}) {
    final updatedProperties =
        _note.properties.where((p) => p.key != key).toList();
    final updatedNote = _note.copyWith(properties: updatedProperties);
    return _persistNote(updatedNote);
  }

  /// Creates a wiki-style link to another note.
  ///
  /// [targetTitle] is the title of the note to link to.
  /// [alias] is optional display text for the link.
  /// [createIfMissing] creates target note if it doesn't exist.
  TaskEither<Failure, ObsidianNote> createLink({
    required String targetTitle,
    String? alias,
    bool createIfMissing = false,
  }) {
    return _createLink(_note, targetTitle,
            alias: alias, createIfMissing: createIfMissing)
        .map((updatedNote) {
      final updatedNotes = _vault.rootFolder.notes
          .map((n) => n.title == _note.title ? updatedNote : n)
          .toList();
      final updatedFolder = _vault.rootFolder.copyWith(notes: updatedNotes);
      final updatedVault = _vault.copyWith(rootFolder: updatedFolder);
      return ObsidianNote._(
        updatedNote,
        updatedVault,
        _fileSystemAdapter,
        _noteRepository,
        _createLink,
      );
    });
  }

  TaskEither<Failure, ObsidianNote> _persistNote(Note note) {
    return TaskEither(() async {
      if (_note.path != null) {
        final result = await _noteRepository.writeNote(_note.path!, note);
        return result.map((_) {
          final updatedNotes = _vault.rootFolder.notes
              .map((n) => n.title == _note.title ? note : n)
              .toList();
          final updatedFolder = _vault.rootFolder.copyWith(notes: updatedNotes);
          final updatedVault = _vault.copyWith(rootFolder: updatedFolder);
          return ObsidianNote._(
            note,
            updatedVault,
            _fileSystemAdapter,
            _noteRepository,
            _createLink,
          );
        });
      }
      return Right(ObsidianNote._(
        note,
        _vault,
        _fileSystemAdapter,
        _noteRepository,
        _createLink,
      ));
    });
  }
}
