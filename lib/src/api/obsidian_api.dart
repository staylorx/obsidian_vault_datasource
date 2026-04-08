import 'dart:io';
import 'package:fpdart/fpdart.dart';
import '../domain/entities/entities.dart';
import '../domain/failures.dart';
import '../data/adapters/file_system_adapter.dart';
import '../data/repositories/note_repository.dart';
import '../data/repositories/attachment_repository.dart';
import '../core/usecases/vault_usecases.dart';

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

  factory ObsidianVault.create(String path, String name) {
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

  factory ObsidianVault.load(String path) {
    final fileSystemAdapter = FileSystemAdapter();
    final noteRepository = NoteRepository(fileSystemAdapter);
    final attachmentRepository = AttachmentRepository(fileSystemAdapter);
    final createNote = CreateNote(fileSystemAdapter, noteRepository);
    final createFolder = CreateFolder(fileSystemAdapter);
    final createLink = CreateLink(noteRepository);
    final saveVault = SaveVault(fileSystemAdapter, noteRepository);
    final loadVaultUseCase = LoadVault(fileSystemAdapter, noteRepository);

    final vault =
        Vault(name: path.split(Platform.pathSeparator).last, path: path);
    final obsidianVault = ObsidianVault._(
      vault,
      fileSystemAdapter,
      noteRepository,
      attachmentRepository,
      createNote,
      createFolder,
      createLink,
      saveVault,
      loadVaultUseCase,
    );

    return obsidianVault;
  }

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

  String get name => _vault.name;
  String get path => _vault.path;
  Vault get vault => _vault;

  Note? findNote(String title) => _vault.findNote(title);
  List<Note> searchNotes(String query) => _vault.searchNotes(query);
  List<Note> get allNotes => _vault.allNotes;

  TaskEither<Failure, ObsidianNote> createNote(String title,
      {String content = ''}) {
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

  TaskEither<Failure, Unit> createFolder(String name) {
    return _createFolder(_vault, name);
  }

  TaskEither<Failure, Unit> save() {
    return _saveVault(_vault);
  }

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

  List<Attachment> get attachments => _attachments;

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

  TaskEither<Failure, Attachment> getAttachment(String fileName) {
    return TaskEither(() async {
      final attachmentPath =
          _fileSystemAdapter.joinPaths(_vault.path, fileName);
      return _attachmentRepository.readAttachment(attachmentPath);
    });
  }

  TaskEither<Failure, Unit> writeAttachment(String fileName, List<int> bytes) {
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

  TaskEither<Failure, Unit> deleteAttachment(String fileName) {
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

  TaskEither<Failure, List<int>> readAttachmentBytes(String fileName) {
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

  String get name => _folder.name;
  List<Note> get notes => _folder.notes;
  List<Folder> get subfolders => _folder.subfolders;

  Note? findNote(String title) {
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

  TaskEither<Failure, ObsidianNote> createNote(String title,
      {String content = ''}) {
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

  String get title => _note.title;
  String get content => _note.content;
  List<Property> get properties => _note.properties;
  List<Link> get links => _note.links;

  Note get note => _note;
  Vault get vault => _vault;

  TaskEither<Failure, ObsidianNote> updateContent(String content) {
    final updatedNote = _note.copyWith(content: content);
    return _persistNote(updatedNote);
  }

  TaskEither<Failure, ObsidianNote> updateTitle(String title) {
    final updatedNote = _note.copyWith(title: title);
    return _persistNote(updatedNote);
  }

  TaskEither<Failure, ObsidianNote> createProperty(String key, dynamic value,
      {bool frontmatter = true}) {
    final property =
        Property(key: key, value: value, isFrontmatter: frontmatter);
    final updatedNote =
        _note.copyWith(properties: [..._note.properties, property]);
    return _persistNote(updatedNote);
  }

  TaskEither<Failure, ObsidianNote> updateProperty(String key, dynamic value) {
    final updatedProperties = _note.properties.map((p) {
      if (p.key == key) return p.copyWith(value: value);
      return p;
    }).toList();
    final updatedNote = _note.copyWith(properties: updatedProperties);
    return _persistNote(updatedNote);
  }

  TaskEither<Failure, ObsidianNote> removeProperty(String key) {
    final updatedProperties =
        _note.properties.where((p) => p.key != key).toList();
    final updatedNote = _note.copyWith(properties: updatedProperties);
    return _persistNote(updatedNote);
  }

  TaskEither<Failure, ObsidianNote> createLink(String targetTitle,
      {String? alias, bool createIfMissing = false}) {
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
