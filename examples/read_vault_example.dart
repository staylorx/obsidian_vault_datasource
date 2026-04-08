// ignore_for_file: avoid_print

import 'dart:io';
import 'package:obsidian_vault_datasource/obsidian_vault_datasource.dart';

void main() async {
  final vaultPath = 'examples/example_vault';
  print('Loading vault from: $vaultPath');

  final vaultResult = await ObsidianVault.load(path: vaultPath).run();
  final loadedVault = vaultResult.fold((failure) {
    print('Failed to load: $failure');
    exit(1);
  }, (v) => v);

  print('\n=== Vault Info ===');
  print('Name: ${loadedVault.name}');
  print('Path: ${loadedVault.path}');
  print('Total notes: ${loadedVault.allNotes.length}');

  print('\n=== All Notes ===');
  for (final note in loadedVault.allNotes) {
    print('\n--- ${note.title} ---');
    print('Path: ${note.path}');
    if (note.properties.isNotEmpty) {
      print('Properties:');
      for (final prop in note.properties) {
        print('  - ${prop.key}: ${prop.value}');
      }
    }
    if (note.links.isNotEmpty) {
      print('Links:');
      for (final link in note.links) {
        final alias = link.alias != null ? '|${link.alias}' : '';
        print('  - [[${link.target}$alias]]');
      }
    }
    if (note.content.length > 100) {
      print('Content preview: ${note.content.substring(0, 100)}...');
    } else {
      print('Content: ${note.content}');
    }
  }

  print('\n=== Search Notes ===');
  final searchResults = loadedVault.searchNotes(query: 'Dart');
  print('Found ${searchResults.length} notes matching "Dart":');
  for (final note in searchResults) {
    print('- ${note.title}');
  }

  print('\n=== Find Specific Note ===');
  final welcomeNote = loadedVault.findNote(title: 'Welcome to Your Vault');
  if (welcomeNote != null) {
    print('Found: ${welcomeNote.title}');
    print(
        'Tags: ${welcomeNote.properties.where((p) => p.key == 'tags').firstOrNull?.value}');
  }
}
