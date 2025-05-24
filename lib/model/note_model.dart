import 'package:ai_smart_app/local_db/app_database.dart';
import 'package:drift/drift.dart';

class NoteModel {
  final int? id;
  final String content;
  final DateTime timestamp;

  NoteModel({
    this.id,
    required this.content,
    required this.timestamp,
  });

  // Convert from Drift Note object
  factory NoteModel.fromDrift(Note note) {
    return NoteModel(
      id: note.id,
      content: note.content,
      timestamp: note.timestamp,
    );
  }

  // Convert to NotesCompanion for inserting
  NotesCompanion toCompanion() {
    return NotesCompanion(
      content: Value(content),
      timestamp: Value(timestamp),
    );
  }
}
