import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app/models/note.dart';
import 'package:notes_app/providers/note_provider.dart';
import 'package:notes_app/screens/note_editor_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  bool _isFabExpanded = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  void _toggleFab() {
    setState(() {
      _isFabExpanded = !_isFabExpanded;
      _isFabExpanded ? _controller.forward() : _controller.reverse();
    });
  }

  void _openEditor({bool isChecklist = false}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NoteEditorScreen(isChecklist: isChecklist),
      ),
    );
  }

  void _deleteNote(Note note) {
    Hive.box<Note>('notes').delete(note.id);
    ref.read(noteProvider.notifier).deleteNote(note.id);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notes = ref.watch(noteProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        centerTitle: true,
      ),
      body: notes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/empty_bin.png', // your cute GIF/PNG here
                    width: 150,
                    height: 150,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "No notes yet!",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(8),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 0.8,
                ),
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final note = notes[index];

                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NoteEditorScreen(note: note),
                      ),
                    ),
                    onLongPress: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Delete Note"),
                          content: const Text(
                              "Are you sure you want to delete this note?"),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Cancel")),
                            TextButton(
                                onPressed: () {
                                  _deleteNote(note);
                                  Navigator.pop(context);
                                },
                                child: const Text("Delete")),
                          ],
                        ),
                      );
                    },
                    child: Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              note.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            if (note.type == NoteType.text)
                              Expanded(
                                child: Text(
                                  note.content,
                                  maxLines: 8,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                            else if (note.type == NoteType.checklist)
                              Expanded(
                                child: ListView(
                                  children: note.todos!
                                      .map(
                                        (todo) => Row(
                                          children: [
                                            Checkbox(
                                              value: todo.isDone,
                                              onChanged: (_) {},
                                            ),
                                            Expanded(
                                              child: Text(
                                                todo.text,
                                                style: TextStyle(
                                                  decoration: todo.isDone
                                                      ? TextDecoration.lineThrough
                                                      : TextDecoration.none,
                                                  color: todo.isDone
                                                      ? Colors.grey
                                                      : Colors.black,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizeTransition(
                  sizeFactor: _animation,
                  axisAlignment: -1.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      FloatingActionButton.extended(
                        heroTag: 'checklist',
                        onPressed: () {
                          _toggleFab();
                          _openEditor(isChecklist: true);
                        },
                        icon: const Icon(Icons.check_box, color: Colors.black),
                        label: const Text('Checklist',
                            style: TextStyle(color: Colors.black)),
                        backgroundColor: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton.extended(
                        backgroundColor: Colors.white,
                        heroTag: 'note',
                        onPressed: () {
                          _toggleFab();
                          _openEditor(isChecklist: false);
                        },
                        icon: const Icon(Icons.edit, color: Colors.black),
                        label: const Text('Note',
                            style: TextStyle(color: Colors.black)),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
                FloatingActionButton(
                  backgroundColor: Colors.black,
                  onPressed: _toggleFab,
                  child: AnimatedRotation(
                    turns: _isFabExpanded ? 0.125 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
