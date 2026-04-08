import 'dart:io';
import 'package:fpdart/fpdart.dart';
import '../../domain/entities/entities.dart';
import '../../domain/failures.dart';
import '../adapters/file_system_adapter.dart';

/// Repository for persisting and retrieving attachments.
class AttachmentRepository {
  AttachmentRepository(this._fileSystemAdapter);

  final FileSystemAdapter _fileSystemAdapter;

  static const _imageExtensions = [
    '.png',
    '.jpg',
    '.jpeg',
    '.gif',
    '.webp',
    '.svg',
    '.bmp'
  ];
  static const _videoExtensions = ['.mp4', '.mov', '.webm', '.avi', '.mkv'];
  static const _audioExtensions = ['.mp3', '.wav', '.ogg', '.m4a', '.flac'];

  Future<Either<Failure, Attachment>> readAttachment(String path) async {
    final fileName = _fileSystemAdapter.getFileName(path);
    final extension =
        fileName.contains('.') ? fileName.split('.').last.toLowerCase() : '';

    final sizeResult = await _fileSystemAdapter.getFileSize(path);
    return sizeResult.fold(
      (failure) => Left(failure),
      (size) => Right(Attachment(
        fileName: fileName,
        path: path,
        fileType: _getFileType(extension),
        size: size,
      )),
    );
  }

  Future<Either<Failure, Unit>> writeAttachment(
      String path, List<int> bytes) async {
    return _fileSystemAdapter.writeFileBytes(path, bytes);
  }

  Future<Either<Failure, List<Attachment>>> readAttachmentsFromDirectory(
      String dirPath) async {
    final listResult = await _fileSystemAdapter.listDirectory(dirPath);

    return listResult.fold(
      (failure) => Left(failure),
      (paths) async {
        final attachments = <Attachment>[];

        for (final filePath in paths) {
          final isFile = await File(filePath).exists();
          if (!isFile) continue;

          final fileName = _fileSystemAdapter.getFileName(filePath);
          if (fileName.endsWith('.md')) continue;
          if (fileName.startsWith('.')) continue;
          if (fileName.endsWith('.canvas')) continue;

          final attachmentResult = await readAttachment(filePath);
          attachmentResult.fold(
            (failure) => null,
            (attachment) => attachments.add(attachment),
          );
        }

        return Right(attachments);
      },
    );
  }

  String _getFileType(String extension) {
    if (_imageExtensions.contains('.$extension')) return 'image';
    if (_videoExtensions.contains('.$extension')) return 'video';
    if (_audioExtensions.contains('.$extension')) return 'audio';
    if (extension == 'pdf') return 'pdf';
    return 'file';
  }
}
