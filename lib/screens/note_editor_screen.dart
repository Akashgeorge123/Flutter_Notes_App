import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app/models/note.dart';
import 'package:notes_app/providers/note_provider.dart';
import 'package:uuid/uuid.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  final Note? note;
  final bool isChecklist;

  const NoteEditorScreen({super.key, this.note, this.isChecklist = false});

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

// Helper class to store Todo and its TextEditingController
class TodoController {
  final TodoItem todo;
  final TextEditingController controller;

  TodoController({required this.todo})
      : controller = TextEditingController(text: todo.text);
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final List<TodoController> _todoControllers = [];

  Note? _currentNote; // Track the note being created/edited

  @override
  void initState() {
    super.initState();

    if (widget.note != null) {
      _currentNote = widget.note;
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;

      if (widget.note!.todos != null) {
        for (var t in widget.note!.todos!) {
          _todoControllers.add(TodoController(todo: t));
        }
      }
    }

    _titleController.addListener(_autoSave);
    _contentController.addListener(_autoSave);
  }

  void _addTodo() {
    final todo = TodoItem(id: const Uuid().v4(), text: "");
    final todoController = TodoController(todo: todo);
    setState(() {
      _todoControllers.add(todoController);
    });
  }

  void _toggleTodoDone(int index, bool? val) {
    setState(() {
      final oldTodo = _todoControllers[index].todo;
      final updatedTodo =
          oldTodo.copyWith(isDone: val ?? false); // create new TodoItem
      _todoControllers[index] = TodoController(todo: updatedTodo);
      _todoControllers.sort((a, b) {
        if (a.todo.isDone == b.todo.isDone) return 0;
        return a.todo.isDone ? 1 : -1;
      });
    });
    _autoSave();
  }

  void _autoSave() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    final isChecklist =
        widget.isChecklist || widget.note?.type == NoteType.checklist;

    // Remove empty todos before saving
    final todosToSave = _todoControllers
        .map((e) => e.todo)
        .where((t) => t.text.trim().isNotEmpty)
        .toList();

    if (title.isEmpty && content.isEmpty && todosToSave.isEmpty) return;

    if (_currentNote == null) {
      // Create once
      final newNote = Note(
        id: const Uuid().v4(),
        title: title,
        content: isChecklist ? '' : content,
        type: isChecklist ? NoteType.checklist : NoteType.text,
        todos: isChecklist ? todosToSave : null,
      );
      ref.read(noteProvider.notifier).addNote(newNote);
      _currentNote = newNote; // store reference for future updates
    } else {
      // Update existing note
      final updatedNote = _currentNote!.copyWith(
        title: title,
        content: isChecklist ? '' : content,
        todos: isChecklist ? todosToSave : null,
      );
      ref.read(noteProvider.notifier).updateNote(updatedNote);
      _currentNote = updatedNote; // update local reference
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    for (var t in _todoControllers) {
      t.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isChecklist =
        widget.isChecklist || widget.note?.type == NoteType.checklist;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? "Add Note" : "Edit Note"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    hintText: "Title",
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (isChecklist)
                  Column(
                    children: [
                      for (int i = 0; i < _todoControllers.length; i++)
                        Row(
                          children: [
                            Checkbox(
                              value: _todoControllers[i].todo.isDone,
                              onChanged: (val) => _toggleTodoDone(i, val),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _todoControllers[i].controller,
                                decoration: const InputDecoration(
                                  hintText: "List item",
                                  border: InputBorder.none,
                                ),
                                style: TextStyle(
                                  decoration: _todoControllers[i].todo.isDone
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                  color: _todoControllers[i].todo.isDone
                                      ? Colors.grey
                                      : Colors.black,
                                ),
                                onChanged: (val) {
                                  final oldTodo = _todoControllers[i].todo;
                                  final updatedTodo =
                                      oldTodo.copyWith(text: val);
                                  _todoControllers[i] =
                                      TodoController(todo: updatedTodo);
                                  _autoSave();
                                },
                              ),
                            ),
                          ],
                        ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: _addTodo,
                          icon: const Icon(Icons.add, color: Colors.black),
                          label: const Text(
                            "Add item",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  TextField(
                    controller: _contentController,
                    decoration: const InputDecoration(
                      hintText: "Note...",
                      border: InputBorder.none,
                    ),
                    maxLines: null,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
