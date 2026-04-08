// ignore_for_file: avoid_print

import 'dart:io';
import 'package:obsidian_vault_datasource/obsidian_vault_datasource.dart';

void main() async {
  final vaultPath = 'examples/example_vault';
  print('Loading vault from: $vaultPath');

  final vaultResult = await ObsidianVault.load(vaultPath).run();
  final loadedVault = vaultResult.fold((failure) {
    print('Failed to load: $failure');
    exit(1);
  }, (v) => v);

  print('\n=== Loading Attachments ===');
  final attachmentsResult = await loadedVault.loadAttachments().run();
  final attachments = attachmentsResult.fold(
    (failure) {
      print('Failed to load attachments: $failure');
      exit(1);
    },
    (attachments) => attachments,
  );

  print('Found ${attachments.length} attachments:');
  for (final attachment in attachments) {
    print('\n--- ${attachment.fileName} ---');
    print('Type: ${attachment.fileType}');
    print('Size: ${attachment.size} bytes');
    print('Is image: ${attachment.isImage}');
    print('Is video: ${attachment.isVideo}');
    print('Is audio: ${attachment.isAudio}');
    print('Is PDF: ${attachment.isPdf}');
    print('Extension: ${attachment.extension}');
  }

  print('\n=== Reading Attachment Bytes ===');
  final firstAttachment = attachments.firstOrNull;
  if (firstAttachment != null) {
    final bytesResult =
        await loadedVault.readAttachmentBytes(firstAttachment.fileName).run();
    final bytes = bytesResult.fold(
      (failure) {
        print('Failed to read bytes: $failure');
        exit(1);
      },
      (bytes) => bytes,
    );
    print('Read ${bytes.length} bytes from ${firstAttachment.fileName}');
  }

  print('\n=== Writing New Attachment ===');
  final newPng = <int>[
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
    0x52,
    0x00,
    0x00,
    0x00,
    0x01,
    0x00,
    0x00,
    0x00,
    0x01,
    0x08,
    0x02,
    0x00,
    0x00,
    0x00,
    0x90,
    0x77,
    0x53,
    0xDE,
    0x00,
    0x00,
    0x00,
    0x0C,
    0x49,
    0x44,
    0x41,
    0x54,
    0x08,
    0xD7,
    0x63,
    0x60,
    0x60,
    0x60,
    0x00,
    0x00,
    0x00,
    0x04,
    0x00,
    0x01,
    0x27,
    0x04,
    0xBA,
    0x4E,
    0x00,
    0x00,
    0x00,
    0x00,
    0x49,
    0x45,
    0x4E,
    0x44,
    0xAE,
    0x42,
    0x60,
    0x82
  ];

  final writeResult =
      await loadedVault.writeAttachment('new_screenshot.png', newPng).run();

  writeResult.fold(
    (failure) => print('Failed to write: $failure'),
    (_) => print('Successfully wrote new_screenshot.png'),
  );

  print('\n=== Reloading to Verify ===');
  final reloadResult = await loadedVault.loadAttachments().run();
  final updatedAttachments = reloadResult.fold(
    (failure) {
      print('Failed to reload: $failure');
      exit(1);
    },
    (attachments) => attachments,
  );

  print('Now has ${updatedAttachments.length} attachments');
  for (final att in updatedAttachments) {
    print('- ${att.fileName}');
  }

  print('\n=== Deleting Attachment ===');
  final deleteResult =
      await loadedVault.deleteAttachment('new_screenshot.png').run();

  deleteResult.fold(
    (failure) => print('Failed to delete: $failure'),
    (_) => print('Successfully deleted new_screenshot.png'),
  );

  print('\n=== Example Complete ===');
}
