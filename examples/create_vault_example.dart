// ignore_for_file: avoid_print

import 'dart:io';
import 'package:obsidian_vault_datasource/obsidian_vault_datasource.dart';

void main() async {
  final tempDir = Directory.systemTemp.createTempSync('example_vault_').path;
  print('Creating vault at: $tempDir');

  final vault = ObsidianVault.create(tempDir, 'My Project Vault');

  await vault.createFolder('projects').run();
  await vault.createFolder('notes').run();
  await vault.createFolder('archive').run();

  await vault.createNote(
    'projects/Project Phoenix',
    content: '''# Project Phoenix

A new mobile application.

## Goals
- Launch MVP by Q2
- 10k users

## Related
See [[notes/Meeting Notes]] for updates.
''',
  ).run();

  await vault.createNote(
    'notes/Meeting Notes',
    content: '''# Meeting Notes

## 2024-01-15

- Discussed Phoenix timeline
- Design review scheduled

## 2024-01-10
- Initial project kickoff
''',
  ).run();

  await vault.createNote(
    'projects/Project Phoenix/Weekly Update',
    content: '''# Weekly Update

## This Week
- Completed wireframes
- Started API design

## Next Week
- Begin implementation
- Review with team

## Links
- [[projects/Project Phoenix]] - Main project
- [[notes/Meeting Notes]] - Meeting notes
''',
  ).run();

  final refreshed = await vault.refresh().run();
  final loadedVault = refreshed.fold((_) => vault, (v) => v);

  print('\n=== Vault Contents ===');
  print('Total notes: ${loadedVault.allNotes.length}');
  for (final note in loadedVault.allNotes) {
    print('- ${note.title}');
    print('  Links: ${note.links.map((l) => l.target).join(', ')}');
  }

  final foundNote = loadedVault.findNote('Project Phoenix');
  print('\n=== Found Note ===');
  print('Title: ${foundNote?.title}');
  print('Properties: ${foundNote?.properties.length}');
  print('Links: ${foundNote?.links.map((l) => l.target).join(', ')}');

  print('\n=== Cleanup ===');
  print('Delete the vault directory when done: $tempDir');
}
