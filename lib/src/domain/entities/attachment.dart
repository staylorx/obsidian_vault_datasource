import 'package:equatable/equatable.dart';

/// Represents a file attachment in an Obsidian vault.
class Attachment with EquatableMixin {
  const Attachment({
    required this.fileName,
    required this.path,
    required this.fileType,
    required this.size,
  });

  final String fileName;
  final String? path;
  final String fileType;
  final int size;

  String get extension =>
      fileName.contains('.') ? fileName.split('.').last : '';

  bool get isImage => ['png', 'jpg', 'jpeg', 'gif', 'webp', 'svg', 'bmp']
      .contains(extension.toLowerCase());

  bool get isVideo =>
      ['mp4', 'mov', 'webm', 'avi', 'mkv'].contains(extension.toLowerCase());

  bool get isAudio =>
      ['mp3', 'wav', 'ogg', 'm4a', 'flac'].contains(extension.toLowerCase());

  bool get isPdf => extension.toLowerCase() == 'pdf';

  Attachment copyWith({
    String? fileName,
    String? path,
    String? fileType,
    int? size,
  }) {
    return Attachment(
      fileName: fileName ?? this.fileName,
      path: path ?? this.path,
      fileType: fileType ?? this.fileType,
      size: size ?? this.size,
    );
  }

  @override
  List<Object?> get props => [fileName, path, fileType, size];
}
