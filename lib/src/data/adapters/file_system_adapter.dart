import 'dart:io';
import 'package:fpdart/fpdart.dart';
import '../../domain/failures.dart';

/// Abstracts file system operations for cross-platform support and testability.
class FileSystemAdapter {
  FileSystemAdapter();

  Future<Either<Failure, List<String>>> listDirectory(String path) async {
    try {
      final dir = Directory(path);
      if (!await dir.exists()) {
        return Left(DirectoryNotFoundFailure(path));
      }
      final entities = await dir.list().toList();
      return Right(entities.map((e) => e.path).toList());
    } catch (e) {
      return Left(ListDirectoryFailure('$e'));
    }
  }

  Future<Either<Failure, bool>> fileExists(String path) async {
    try {
      final file = File(path);
      return Right(await file.exists());
    } catch (e) {
      return Left(CheckFileFailure('$e'));
    }
  }

  Future<Either<Failure, bool>> directoryExists(String path) async {
    try {
      final dir = Directory(path);
      return Right(await dir.exists());
    } catch (e) {
      return Left(CheckDirectoryFailure('$e'));
    }
  }

  Future<Either<Failure, String>> readFile(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) {
        return Left(FileNotFoundFailure(path));
      }
      return Right(await file.readAsString());
    } catch (e) {
      return Left(ReadFileFailure('$e'));
    }
  }

  Future<Either<Failure, Unit>> writeFile(String path, String content) async {
    try {
      final file = File(path);
      await file.parent.create(recursive: true);
      await file.writeAsString(content);
      return const Right(unit);
    } catch (e) {
      return Left(WriteFileFailure('$e'));
    }
  }

  Future<Either<Failure, Unit>> deleteFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
      return const Right(unit);
    } catch (e) {
      return Left(DeleteFileFailure('$e'));
    }
  }

  Future<Either<Failure, Unit>> createDirectory(String path) async {
    try {
      final dir = Directory(path);
      await dir.create(recursive: true);
      return const Right(unit);
    } catch (e) {
      return Left(CreateDirectoryFailure('$e'));
    }
  }

  Future<Either<Failure, Unit>> deleteDirectory(String path) async {
    try {
      final dir = Directory(path);
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
      return const Right(unit);
    } catch (e) {
      return Left(DeleteDirectoryFailure('$e'));
    }
  }

  Future<Either<Failure, List<int>>> readFileBytes(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) {
        return Left(FileNotFoundFailure(path));
      }
      return Right(await file.readAsBytes());
    } catch (e) {
      return Left(ReadFileBytesFailure('$e'));
    }
  }

  Future<Either<Failure, Unit>> writeFileBytes(
      String path, List<int> bytes) async {
    try {
      final file = File(path);
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes);
      return const Right(unit);
    } catch (e) {
      return Left(WriteFileBytesFailure('$e'));
    }
  }

  Future<Either<Failure, int>> getFileSize(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) {
        return Left(FileNotFoundFailure(path));
      }
      final stat = await file.stat();
      return Right(stat.size);
    } catch (e) {
      return Left(GetFileSizeFailure('$e'));
    }
  }

  String joinPaths(String path1, String path2) {
    return '$path1${path1.endsWith(Platform.pathSeparator) ? '' : Platform.pathSeparator}$path2';
  }

  String getFileName(String path) {
    return path.split(Platform.pathSeparator).last;
  }

  String getDirectoryName(String path) {
    return path
            .split(Platform.pathSeparator)
            .where((s) => s.isNotEmpty)
            .lastOrNull ??
        '';
  }
}
