import 'package:obsidian_vault_datasource/obsidian_vault_datasource.dart';
import 'package:shouldly/shouldly.dart';
import 'package:test/test.dart';

void main() {
  group('Given a Vault entity', () {
    test('should find note by title in root folder', () {
      final vault = Vault(
        name: 'Test Vault',
        path: '/test/path',
        rootFolder: const Folder(
          name: '',
          notes: [
            Note(title: 'Note1', content: ''),
            Note(title: 'Note2', content: ''),
          ],
        ),
      );

      vault.findNote('Note1')!.title.should.be('Note1');
      vault.findNote('Note3').should.beNull();
    });

    test('should find note in nested folders', () {
      final vault = Vault(
        name: 'Test Vault',
        path: '/test/path',
        rootFolder: Folder(
          name: '',
          notes: [],
          subfolders: [
            const Folder(
              name: 'subfolder',
              notes: [Note(title: 'Nested Note', content: '')],
            ),
          ],
        ),
      );

      vault.findNote('Nested Note')!.title.should.be('Nested Note');
    });

    test('should search notes by title and content', () {
      final vault = Vault(
        name: 'Test Vault',
        path: '/test/path',
        rootFolder: const Folder(
          name: '',
          notes: [
            Note(
                title: 'Flutter App',
                content: 'This is about mobile development'),
            Note(title: 'Dart Guide', content: 'Learn the Dart language'),
          ],
        ),
      );

      final results = vault.searchNotes('dart');
      results.length.should.be(1);
      results[0].title.should.be('Dart Guide');
    });

    test('should return all notes including nested', () {
      final vault = Vault(
        name: 'Test Vault',
        path: '/test/path',
        rootFolder: const Folder(
          name: '',
          notes: [Note(title: 'Root Note', content: '')],
          subfolders: [
            Folder(
              name: 'sub',
              notes: [Note(title: 'Sub Note', content: '')],
            ),
          ],
        ),
      );

      vault.allNotes.length.should.be(2);
      vault.allNotes.map((n) => n.title).should.contain('Root Note');
      vault.allNotes.map((n) => n.title).should.contain('Sub Note');
    });
  });

  group('Given a Folder entity', () {
    test('should get all notes recursively', () {
      final folder = Folder(
        name: 'root',
        notes: [const Note(title: 'Note1', content: '')],
        subfolders: [
          const Folder(
              name: 'sub1', notes: [Note(title: 'Note2', content: '')]),
          Folder(
            name: 'sub2',
            notes: [const Note(title: 'Note3', content: '')],
            subfolders: [
              const Folder(
                  name: 'nested', notes: [Note(title: 'Note4', content: '')]),
            ],
          ),
        ],
      );

      folder.allNotes.length.should.be(4);
    });
  });
}
