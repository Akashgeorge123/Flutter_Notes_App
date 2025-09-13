import 'package:hive/hive.dart';
part 'note_hive.g.dart';

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
  String id;

  @HiveField(1)
  String text;

  @HiveField(2)
  bool isDone;

  TodoItem({required this.id, required this.text, this.isDone = false});

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
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String content;

  @HiveField(3)
  NoteType type;

  @HiveField(4)
  List<TodoItem>? todos;

  Note({
    required this.id,
    required this.title,
    required this.content,
    this.type = NoteType.text,
    this.todos,
  });

  Note copyWith({
    String? title,
    String? content,
    List<TodoItem>? todos,
    NoteType? type,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      type: type ?? this.type,
      todos: todos ?? this.todos,
    );
  }
}
