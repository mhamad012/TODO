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
  String userId; // ADDED: to track which user owns this task

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
    required this.userId, // ADDED: required field
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
      'userId': userId, // ADDED
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'] ?? '',
      dueDate: DateTime.parse(map['dueDate']),
      priority: map['priority'] ?? 'medium',
      isCompleted: map['isCompleted'] == 1,
      category: map['category'] ?? 'General',
      tags: (map['tags'] != null && map['tags'].toString().isNotEmpty) 
          ? map['tags'].split(',') 
          : [],
      createdAt: DateTime.parse(map['createdAt']),
      userId: map['userId'] ?? '', // ADDED with fallback
    );
  }
}