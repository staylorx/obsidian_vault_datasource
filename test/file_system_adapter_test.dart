import 'package:obsidian_vault_datasource/obsidian_vault_datasource.dart';
import 'package:test/test.dart';
import 'dart:io';

void main() {
  group('Given a FileSystemAdapter', () {
    late FileSystemAdapter adapter;
    late String tempDir;

    setUp(() async {
      adapter = FileSystemAdapter();
      tempDir = Directory.systemTemp.createTempSync('obsidian_test_').path;
    });

    tearDown(() async {
      await adapter.deleteDirectory(tempDir);
    });

    test('should create and verify directory exists', () async {
      final subDir = '$tempDir${Platform.pathSeparator}subfolder';

      final result = await adapter.createDirectory(subDir);
      expect(result.isRight(), true);

      final exists = await adapter.directoryExists(subDir);
      expect(exists.fold((_) => false, (v) => v), true);
    });

    test('should write and read file', () async {
      final filePath = '$tempDir${Platform.pathSeparator}test.txt';
      const content = 'Hello, World!';

      await adapter.writeFile(filePath, content);
      final result = await adapter.readFile(filePath);

      expect(result.fold((_) => '', (v) => v), content);
    });

    test('should return failure for non-existent file', () async {
      final result = await adapter
          .readFile('$tempDir${Platform.pathSeparator}nonexistent.txt');
      expect(result.isLeft(), true);
    });

    test('should join paths correctly', () {
      final result = adapter.joinPaths('/base', 'sub');
      expect(result, '/base${Platform.pathSeparator}sub');
    });

    test('should delete directory recursively', () async {
      final subDir = '$tempDir${Platform.pathSeparator}to_delete';
      await adapter.createDirectory(subDir);

      final result = await adapter.deleteDirectory(subDir);
      expect(result.isRight(), true);

      final exists = await adapter.directoryExists(subDir);
      expect(exists.fold((_) => true, (v) => v), false);
    });
  });
}
