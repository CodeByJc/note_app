import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'footer.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NotesApp());
}

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: const NotesHome(),
    );
  }
}

class NotesHome extends StatefulWidget {
  const NotesHome({super.key});

  @override
  State<NotesHome> createState() => _NotesHomeState();
}

class _NotesHomeState extends State<NotesHome> {
  static const _storeKey = 'notes_list_v1';
  List<String> _notes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storeKey);
    setState(() {
      _notes = raw == null ? [] : List<String>.from(jsonDecode(raw));
      _loading = false;
    });
  }

  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storeKey, jsonEncode(_notes));
  }

  Future<void> _addNote() async {
    final text = await _promptNote(context, title: 'Add Note');
    if (text == null || text.trim().isEmpty) return;
    setState(() => _notes.insert(0, text.trim()));
    await _saveNotes();
  }

  Future<void> _editNote(int index) async {
    final text = await _promptNote(
      context,
      title: 'Edit Note',
      initial: _notes[index],
    );
    if (text == null) return;
    setState(() => _notes[index] = text.trim());
    await _saveNotes();
  }

  Future<void> _deleteNote(int index) async {
    final confirm = await _confirm(context, 'Delete this note?');
    if (confirm != true) return;
    setState(() => _notes.removeAt(index));
    await _saveNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          IconButton(
            onPressed: _addNote,
            icon: const Icon(Icons.add),
            tooltip: 'Add',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _notes.isEmpty
          ? const Center(child: Text('No notes yet. Tap + to add one.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _notes.length,
              itemBuilder: (context, i) {
                final note = _notes[i];
                return Dismissible(
                  key: ValueKey('$note-$i'),
                  background: Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 16),
                    child: const Icon(Icons.delete),
                  ),
                  secondaryBackground: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    child: const Icon(Icons.delete),
                  ),
                  onDismissed: (_) async => _deleteNote(i),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Card(
                        child: ListTile(
                          title: Text(
                            note,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => _editNote(i),
                          trailing: IconButton(
                            icon: const Icon(Icons.more_vert),
                            onPressed: () async {
                              final choice = await showMenu<String>(
                                context: context,
                                position: const RelativeRect.fromLTRB(
                                  1000,
                                  80,
                                  8,
                                  0,
                                ),
                                items: const [
                                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Delete'),
                                  ),
                                ],
                              );
                              if (choice == 'edit') _editNote(i);
                              if (choice == 'delete') _deleteNote(i);
                            },
                          ),
                        ),
                      ),
                      const FooterText(),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNote,
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
    );
  }
}

Future<String?> _promptNote(
  BuildContext context, {
  required String title,
  String initial = '',
}) async {
  final controller = TextEditingController(text: initial);
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        maxLines: null,
        decoration: const InputDecoration(hintText: 'Type your note'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, controller.text),
          child: const Text('Save'),
        ),
      ],
    ),
  );
}

Future<bool?> _confirm(BuildContext context, String message) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('No'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Yes'),
        ),
      ],
    ),
  );
}
