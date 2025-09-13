import 'package:flutter_riverpod/legacy.dart';
import 'package:hive/hive.dart';
import 'package:notes_app/models/note.dart';

class NoteNotifier extends StateNotifier<List<Note>> {
  late Box<Note> _box;

  NoteNotifier() : super([]) {
    _init();
  }

  // Async initialization
  Future<void> _init() async {
    // Open the box if not already open
    if (!Hive.isBoxOpen('notesBox')) {
      _box = await Hive.openBox<Note>('notesBox');
    } else {
      _box = Hive.box<Note>('notesBox');
    }

    // Load existing notes
    state = _box.values.toList();
  }

  void addNote(Note note) {
    _box.put(note.id, note);
    state = _box.values.toList();
  }

  void deleteNote(String id) {
    _box.delete(id);
    state = _box.values.toList();
  }

  void updateNote(Note updatedNote) {
    _box.put(updatedNote.id, updatedNote);
    state = _box.values.toList();
  }
}

final noteProvider = StateNotifierProvider<NoteNotifier, List<Note>>((ref) {
  return NoteNotifier();
});
