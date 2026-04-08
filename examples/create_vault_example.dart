// ignore_for_file: avoid_print

import 'dart:io';
import 'package:obsidian_vault_datasource/obsidian_vault_datasource.dart';

void main() async {
  final tempDir = Directory.systemTemp.createTempSync('example_vault_').path;
  print('Creating vault at: $tempDir');

  final vault = ObsidianVault.create(path: tempDir, name: 'My Project Vault');

  await vault.createFolder(name: 'projects').run();
  await vault.createFolder(name: 'notes').run();
  await vault.createFolder(name: 'archive').run();

  await vault.createNote(
    title: 'projects/Project Phoenix',
    content: '''# Project Phoenix

A new mobile application.

See [[../Reference/Tech Stack/Flutter]] for details.
''',
  ).run();

  await vault.createNote(
    title: 'notes/Meeting Notes 2024-01-15',
    content: '''# Daily Standup

## Attendees
- Alex
- Jordan
- Sam

## Updates
- Android app progressing nicely
- Design review scheduled for Friday

## Action Items
- [ ] Schedule design review
- [ ] Review PRs
''',
  ).run();

  await vault.createNote(
    title: 'notes/Feature List',
    content: '''# Feature List

## Core Features
- [ ] Note editing
- [ ] Folder organization
- [ ] Search

## Future
- [ ] Tags
- [ ] Graph view
- [ ] Backlinks
''',
  ).run();

  final createdVault = await vault.refresh().run();
  final finalVault =
      createdVault.fold((f) => throw Exception(f.toString()), (v) => v);

  print('Created ${finalVault.allNotes.length} notes:');
  for (final note in finalVault.allNotes) {
    print('- ${note.title}');
  }

  await vault.save().run();
  print('\nSaved vault to $tempDir');

  await Directory(tempDir).delete(recursive: true);
}
