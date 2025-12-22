// models/task_model.dart
class Task {
  int? id;
  String title;
  String description;
  DateTime dueDate;
  String priority;
  bool isCompleted;
  String category;
  List<String> tags;
  DateTime createdAt;

  Task({
    this.id,
    required this.title,
    this.description = '',
    required this.dueDate,
    this.priority = 'medium',
    this.isCompleted = false,
    this.category = 'General',
    this.tags = const [],
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'priority': priority,
      'isCompleted': isCompleted ? 1 : 0,
      'category': category,
      'tags': tags.join(','),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      dueDate: DateTime.parse(map['dueDate']),
      priority: map['priority'],
      isCompleted: map['isCompleted'] == 1,
      category: map['category'],
      tags: map['tags']?.split(',') ?? [],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}