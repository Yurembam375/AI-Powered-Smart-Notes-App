import 'dart:convert';
import 'package:ai_smart_app/local_db/app_database.dart';
import 'package:ai_smart_app/provide/note_provider.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:provider/provider.dart';

class EditorScreen extends StatelessWidget {
  const EditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NoteProvider>(context);
    final openAiApiKey = dotenv.env['OPENAI_API_KEY'];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Note'),
        actions: [
          IconButton(
            icon: Icon(provider.isListening ? Icons.mic_off : Icons.mic),
            onPressed: provider.isListening
                ? provider.stopListening
                : provider.startListening,
          ),
          IconButton(
            icon: const Icon(Icons.summarize),
            onPressed: () async {
              final summary = await provider.summarizeNote(openAiApiKey!);
              if (summary != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Summary: $summary")),
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            quill.QuillToolbar.simple(
              configurations: quill.QuillSimpleToolbarConfigurations(
                controller: provider.controller,
                showUndo: true,
                showRedo: true,
                showBoldButton: true,
                showItalicButton: true,
                showUnderLineButton: true,
                showColorButton: true,
                multiRowsDisplay: false,
              ),
            ),

            const SizedBox(height: 8),

            // Keywords display as horizontal scroll chips
            FutureBuilder<List<String>>(
              future: provider.getKeywordsFromCurrentNote(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 40,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: snapshot.data!
                          .map((keyword) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: Chip(
                                  label: Text(keyword),
                                  backgroundColor: Colors.blueGrey.shade700,
                                ),
                              ))
                          .toList(),
                    ),
                  );
                }
                return const SizedBox(height: 40);
              },
            ),

            const SizedBox(height: 8),

            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(8),
                child: quill.QuillEditor.basic(
                  configurations: quill.QuillEditorConfigurations(
                    controller: provider.controller,
                    autoFocus: true,
                    scrollable: true,
                    expands: true,
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Save and Load buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () =>
                      context.read<NoteProvider>().syncNotesToCloud(),
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    textStyle: const TextStyle(fontSize: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.blueAccent,
                  ),
                  child: const Text("Local ➜ Cloud"),
                ),
                ElevatedButton(
                  onPressed: () => context.read<NoteProvider>().cloudToLocal(),
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    textStyle: const TextStyle(fontSize: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.green,
                  ),
                  child: const Text("Cloud ➜ Local"),
                ),
                ElevatedButton(
                  onPressed: () => context.read<NoteProvider>().syncBothWays(),
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    textStyle: const TextStyle(fontSize: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.orange,
                  ),
                  child: const Text("🔁 Sync"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
