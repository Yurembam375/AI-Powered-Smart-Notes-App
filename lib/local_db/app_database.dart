import 'package:ai_smart_app/local_db/note_table.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

part 'app_database.g.dart'; // Generates the _$AppDatabase class

@DriftDatabase(tables: [Notes])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  /// Insert a new note into the local DB
  Future<int> insertNote(NotesCompanion note) => into(notes).insert(note);

  /// Fetch all notes
  Future<List<Note>> getAllNotes() => select(notes).get();

  /// Delete a note by ID (optional utility)
  Future<int> deleteNoteById(int id) =>
      (delete(notes)..where((tbl) => tbl.id.equals(id))).go();

  /// Clear all notes (optional)
  Future<int> clearAllNotes() => delete(notes).go();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}
