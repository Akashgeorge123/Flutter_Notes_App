// lib/models/note.dart
import 'package:hive/hive.dart';

part 'note.g.dart';

@HiveType(typeId: 0)
enum NoteType {
  @HiveField(0)
  text,
  @HiveField(1)
  checklist,
}

@HiveType(typeId: 1)
class TodoItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String text;

  @HiveField(2)
  final bool isDone;

  TodoItem({
    required this.id,
    required this.text,
    this.isDone = false,
  });

  TodoItem copyWith({String? id, String? text, bool? isDone}) {
    return TodoItem(
      id: id ?? this.id,
      text: text ?? this.text,
      isDone: isDone ?? this.isDone,
    );
  }
}

@HiveType(typeId: 2)
class Note extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String content;

  @HiveField(3)
  final NoteType type;

  @HiveField(4)
  final List<TodoItem>? todos;

  Note({
    required this.id,
    required this.title,
    this.content = '',
    this.type = NoteType.text,
    this.todos,
  });

  Note copyWith({
    String? id,
    String? title,
    String? content,
    NoteType? type,
    List<TodoItem>? todos,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      type: type ?? this.type,
      todos: todos ?? this.todos,
    );
  }
}
