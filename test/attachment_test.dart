import 'dart:io';
import 'package:obsidian_vault_datasource/obsidian_vault_datasource.dart';
import 'package:shouldly/shouldly.dart';
import 'package:test/test.dart';
import 'package:path/path.dart' as p;

void main() {
  group('Given an ObsidianVault', () {
    group('when handling attachments', () {
      late String tempDir;
      late ObsidianVault vault;

      setUp(() async {
        tempDir = Directory.systemTemp.createTempSync('obsidian_test_').path;
        vault = ObsidianVault.create(tempDir, 'test_vault');
        await vault.createNote('Test Note').run();
      });

      tearDown(() async {
        await Directory(tempDir).delete(recursive: true);
      });

      test('should load attachments from vault', () async {
        final testPng = <int>[
          0x89,
          0x50,
          0x4E,
          0x47,
          0x0D,
          0x0A,
          0x1A,
          0x0A,
          0x00,
          0x00,
          0x00,
          0x0D,
          0x49,
          0x48,
          0x44,
          0x52
        ];
        final attachmentPath = p.join(tempDir, 'test_image.png');
        await File(attachmentPath).writeAsBytes(testPng);

        final result = await vault.loadAttachments().run();

        result.isRight().should.beTrue();
        final attachments = result.getOrElse((f) => <Attachment>[]);
        attachments.length.should.be(1);
        attachments.first.fileName.should.be('test_image.png');
        attachments.first.isImage.should.be(true);
      });

      test('should write attachment to vault', () async {
        final testBytes = <int>[0x00, 0x01, 0x02, 0x03];

        final result =
            await vault.writeAttachment('new_file.png', testBytes).run();

        result.isRight().should.beTrue();
        final file = File(p.join(tempDir, 'new_file.png'));
        file.existsSync().should.be(true);
        final bytes = await file.readAsBytes();
        bytes.should.be(testBytes);
      });

      test('should delete attachment from vault', () async {
        final testBytes = <int>[0x00, 0x01, 0x02, 0x03];
        final filePath = p.join(tempDir, 'to_delete.png');
        await File(filePath).writeAsBytes(testBytes);

        final deleteResult =
            await vault.deleteAttachment('to_delete.png').run();

        deleteResult.isRight().should.beTrue();
        File(filePath).existsSync().should.be(false);
      });

      test('should read attachment bytes from vault', () async {
        final testBytes = <int>[0x00, 0x01, 0x02, 0x03, 0x04];
        final filePath = p.join(tempDir, 'read_test.png');
        await File(filePath).writeAsBytes(testBytes);

        final result = await vault.readAttachmentBytes('read_test.png').run();

        result.isRight().should.beTrue();
        final bytes = result.getOrElse((f) => <int>[]);
        bytes.should.be(testBytes);
      });

      test('should get specific attachment', () async {
        final testBytes = <int>[0x00, 0x01, 0x02, 0x03];
        final filePath = p.join(tempDir, 'specific.png');
        await File(filePath).writeAsBytes(testBytes);

        final result = await vault.getAttachment('specific.png').run();

        result.isRight().should.beTrue();
        final attachment = result.getOrElse((f) => Attachment(
              fileName: '',
              path: '',
              fileType: '',
              size: 0,
            ));
        attachment.fileName.should.be('specific.png');
        attachment.isImage.should.be(true);
        attachment.size.should.be(4);
      });
    });
  });

  group('Given an Attachment entity', () {
    test('should correctly identify image types', () {
      const attachment = Attachment(
        fileName: 'test.png',
        path: '/vault/test.png',
        fileType: 'image',
        size: 1024,
      );

      attachment.isImage.should.be(true);
      attachment.isVideo.should.be(false);
      attachment.isAudio.should.be(false);
      attachment.isPdf.should.be(false);
    });

    test('should correctly identify video types', () {
      const attachment = Attachment(
        fileName: 'test.mp4',
        path: '/vault/test.mp4',
        fileType: 'video',
        size: 1024,
      );

      attachment.isImage.should.be(false);
      attachment.isVideo.should.be(true);
    });

    test('should correctly identify audio types', () {
      const attachment = Attachment(
        fileName: 'test.mp3',
        path: '/vault/test.mp3',
        fileType: 'audio',
        size: 1024,
      );

      attachment.isAudio.should.be(true);
    });

    test('should correctly identify PDF types', () {
      const attachment = Attachment(
        fileName: 'test.pdf',
        path: '/vault/test.pdf',
        fileType: 'pdf',
        size: 1024,
      );

      attachment.isPdf.should.be(true);
    });

    test('should extract extension correctly', () {
      const attachment = Attachment(
        fileName: 'document.pdf',
        path: '/vault/document.pdf',
        fileType: 'pdf',
        size: 1024,
      );

      attachment.extension.should.be('pdf');
    });
  });
}
