import 'package:ai_smart_app/local_db/app_database.dart';
import 'package:ai_smart_app/provide/note_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ViewNotesScreen extends StatefulWidget {
  const ViewNotesScreen({super.key});

  @override
  State<ViewNotesScreen> createState() => _ViewNotesScreenState();
}

class _ViewNotesScreenState extends State<ViewNotesScreen> {
  String _searchQuery = '';
  late Future<List<Note>> _notesFuture;

  @override
  void initState() {
    super.initState();
    _fetchNotes();
  }

  void _fetchNotes() {
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    if (_searchQuery.trim().isEmpty) {
      _notesFuture = noteProvider.getLocalNotes();
    } else {
      _notesFuture = noteProvider.searchNotes(_searchQuery.trim());
    }
  }
  // void _fetchNotes() {
  //   final noteProvider = Provider.of<NoteProvider>(context, listen: false);
  //   if (_searchQuery.trim().isEmpty) {
  //     _notesFuture = noteProvider.getNotesBasedOnConnectivity();
  //   } else {
  //     _notesFuture = noteProvider.searchNotes(_searchQuery.trim());
  //   }
  // }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
      _fetchNotes();
    });
  }

  Color _getColorByIndex(int index) {
    final colors = [
      Colors.orange.shade100,
      Colors.green.shade100,
      Colors.blue.shade100,
      Colors.pink.shade100,
      Colors.teal.shade100,
      Colors.purple.shade100,
      Colors.amber.shade100,
    ];
    return colors[index % colors.length];
  }

  String _formatDate(DateTime timestamp) {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Notes')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Search bar
            TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search notes...',
                border: OutlineInputBorder(),
              ),
              onChanged: _onSearchChanged,
            ),
            const SizedBox(height: 12),

            // Notes list
            Expanded(
              child: FutureBuilder<List<Note>>(
                future: _notesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No notes found.'));
                  }

                  final notes = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.all(0),
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      final color = _getColorByIndex(index);
                      final lines = note.content.trim().split('\n');
                      final title =
                          lines.isNotEmpty && lines[0].trim().isNotEmpty
                              ? lines[0].trim()
                              : 'Untitled Note';

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ExpansionTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          tilePadding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          title: Text(
                            title,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          childrenPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                note.content,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Colors.black87,
                                    ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                _formatDate(note.timestamp),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: Colors.black54),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
