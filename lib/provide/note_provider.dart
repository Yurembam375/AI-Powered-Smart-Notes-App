import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:ai_smart_app/local_db/app_database.dart';
import 'package:drift/drift.dart' as drift;
import 'package:connectivity_plus/connectivity_plus.dart';

final Set<String> stopwords = {
  'the', 'is', 'in', 'and', 'of', 'to', 'a', 'with', 'for', 'on', 'that',
  'this',
  'it', 'as', 'at', 'by', 'from', 'an', 'be', 'or', 'are', 'was', 'but', 'not',
  'have', 'has', 'had', 'they', 'you', 'we', 'he', 'she', 'him', 'her', 'his',
  // add more stopwords as needed
};

class NoteProvider extends ChangeNotifier {
  final quill.QuillController controller = quill.QuillController.basic();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool isListening = false;
  final _firestore = FirebaseFirestore.instance;
  final AppDatabase _db = AppDatabase();

  /// Request microphone permission
  Future<void> requestMicrophonePermission() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
    }
  }

  /// Initialize speech-to-text
  Future<void> initializeSpeech() async {
    await requestMicrophonePermission();
    await _speech.initialize(
      onStatus: (status) => debugPrint('Speech status: $status'),
      onError: (error) => debugPrint('Speech error: $error'),
    );
  }

  /// Start speech recognition
  void startListening() async {
    if (!isListening && await _speech.initialize()) {
      isListening = true;
      notifyListeners();
      _speech.listen(onResult: (val) {
        controller.replaceText(
          controller.selection.baseOffset,
          0,
          "${val.recognizedWords} ",
          TextSelection.collapsed(
            offset: controller.selection.baseOffset +
                val.recognizedWords.length +
                1,
          ),
        );
        notifyListeners();
      });
    }
  }

  /// Stop speech recognition
  void stopListening() {
    _speech.stop();
    isListening = false;
    notifyListeners();
  }

  /// Summarize the note using OpenAI
  Future<String?> summarizeNote(String apiKey) async {
    final text = controller.document.toPlainText();
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: json.encode({
        "model": "gpt-3.5-turbo",
        "messages": [
          {"role": "user", "content": "Summarize this: $text"}
        ]
      }),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body)["choices"][0]["message"]["content"];
    }
    return null;
  }

  /// Extract keywords (placeholder implementation)
  // Future<List<String>> extractKeywords() async {
  //   final text = controller.document.toPlainText();
  //   // You can later integrate a keyword extraction model/API
  //   return ['TODO: Extract', 'keywords', 'from', 'text'];
  // }
  Future<List<Note>> searchNotesByKeywords(String query) async {
    if (query.trim().isEmpty) {
      return await getLocalNotes();
    }
    final allNotes = await getLocalNotes();
    final lowerQuery = query.toLowerCase();

    List<Note> matchingNotes = [];

    for (final note in allNotes) {
      final keywords = extractKeywords(note.content, maxKeywords: 10);
      // Check if query word matches any extracted keyword
      if (keywords.any((kw) => kw.contains(lowerQuery))) {
        matchingNotes.add(note);
      }
    }

    final nonMatchingNotes =
        allNotes.where((note) => !matchingNotes.contains(note)).toList();

    return [...matchingNotes, ...nonMatchingNotes];
  }

  Future<List<Note>> searchNotes(String query) async {
    final allNotes = await getLocalNotes();
    final lowerQuery = query.toLowerCase();

    final matchingNotes = allNotes.where((note) {
      final content = note.content.toLowerCase();
      return content.contains(lowerQuery);
    }).toList();

    final nonMatchingNotes = allNotes.where((note) {
      final content = note.content.toLowerCase();
      return !content.contains(lowerQuery);
    }).toList();

    // Return matching notes first
    return [...matchingNotes, ...nonMatchingNotes];
  }

  List<String> extractKeywords(String text, {int maxKeywords = 5}) {
    final words = text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();

    final filteredWords =
        words.where((word) => !stopwords.contains(word)).toList();

    final frequencyMap = <String, int>{};
    for (final word in filteredWords) {
      frequencyMap[word] = (frequencyMap[word] ?? 0) + 1;
    }

    final sortedByFrequency = frequencyMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topKeywords =
        sortedByFrequency.take(maxKeywords).map((e) => e.key).toList();

    return topKeywords;
  }

  // Future helper to get keywords from current note content
  Future<List<String>> getKeywordsFromCurrentNote() async {
    final text = controller.document.toPlainText();
    return extractKeywords(text, maxKeywords: 7);
  }

  /// Save note locally with Drift
  Future<void> saveNoteLocally(NotesCompanion note) async {
    await _db.insertNote(note);
  }

  Future<List<Note>> getLocalNotes() async {
    final allNotes = await _db.getAllNotes(); // Your drift DAO method
    return allNotes;
  }

  /// Load the last saved note locally from Drift
  Future<void> loadNotesLocally() async {
    final notes = await _db.getAllNotes();
    if (notes.isNotEmpty) {
      final lastNote = notes.last.content;
      controller.document = quill.Document()..insert(0, lastNote);
      notifyListeners();
    }
  }

  Future<void> syncNotesToCloud() async {
    final text = controller.document.toPlainText().trim();
    if (text.isEmpty) return;

    await _firestore.collection('notes').add({
      'content': text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    debugPrint("Note synced to cloud");
  }

  Future<void> fetchNotesFromCloud() async {
    final snapshot = await _firestore
        .collection('notes')
        .orderBy('timestamp', descending: true)
        .get();

    for (var doc in snapshot.docs) {
      debugPrint("Fetched: ${doc.data()['content']}");
      // Optionally: set to controller or local database
    }

    debugPrint("Fetched ${snapshot.docs.length} notes from cloud");
  }

  Future<void> localToCloud() async {
    final localNotes = await getLocalNotes();

    for (final note in localNotes) {
      final query = await _firestore
          .collection('notes')
          .where('content', isEqualTo: note.content)
          .where('timestamp', isEqualTo: note.timestamp.toIso8601String())
          .get();

      if (query.docs.isEmpty) {
        await _firestore.collection('notes').add({
          'content': note.content,
          'timestamp': note.timestamp.toIso8601String(),
        });
        debugPrint("Uploaded note to cloud: ${note.content}");
      }
    }

    debugPrint("✅ localToCloud: All local notes synced to cloud");
  }

  Future<void> cloudToLocal() async {
    final snapshot = await _firestore.collection('notes').get();
    final localNotes = await getLocalNotes();

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final cloudContent = data['content'];
      final cloudTimestamp = DateTime.tryParse(data['timestamp'] ?? '');

      if (cloudTimestamp == null) continue;

      final alreadyExists = localNotes.any((note) =>
          note.content == cloudContent &&
          note.timestamp.isAtSameMomentAs(cloudTimestamp));

      if (!alreadyExists) {
        await saveNoteLocally(NotesCompanion(
          content: drift.Value(cloudContent),
          timestamp: drift.Value(cloudTimestamp),
        ));
        debugPrint("Downloaded cloud note to local DB: $cloudContent");
      }
    }

    debugPrint("✅ cloudToLocal: All cloud notes synced to local DB");
  }

  Future<void> syncBothWays() async {
    await localToCloud();
    await cloudToLocal();
  }

  Future<List<Note>> getNotesBasedOnConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      // Online: Fetch from Firebase
      try {
        final snapshot = await _firestore
            .collection('notes')
            .orderBy('timestamp', descending: true)
            .get();

        final existingNotes = await _db.getAllNotes();
        List<Note> cloudNotes = [];

        for (var doc in snapshot.docs) {
          final content = doc['content'] as String;

          final timestampField = doc['timestamp'];
          DateTime timestamp;
          if (timestampField == null) {
            timestamp = DateTime.now();
          } else if (timestampField is Timestamp) {
            timestamp = timestampField.toDate();
          } else if (timestampField is String) {
            timestamp = DateTime.tryParse(timestampField) ?? DateTime.now();
          } else {
            timestamp = DateTime.now();
          }

          bool exists = existingNotes.any((note) =>
              note.content == content &&
              note.timestamp.isAtSameMomentAs(timestamp));

          if (!exists) {
            await _db.insertNote(
              NotesCompanion.insert(
                content: content,
                timestamp: drift.Value(timestamp),
              ),
            );
          }

          cloudNotes.add(Note(
            id: -1,
            content: content,
            timestamp: timestamp,
          ));
        }

        return cloudNotes;
      } catch (e) {
        debugPrint("Error fetching from cloud: $e");
        return await _db.getAllNotes(); // fallback to local DB
      }
    } else {
      // Offline: Fetch from local DB
      return await _db.getAllNotes();
    }
  }
}
