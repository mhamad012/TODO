// data/database/database_operations.dart
import 'package:flutter/foundation.dart';
import 'package:taskflow/models/task_model.dart';
import 'database_helper.dart';

class DatabaseOperations {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // In-memory fallback for web
  static final List<Task> _inMemoryTasks = <Task>[];
  static final Map<String, dynamic> _inMemoryProfile = {
    'id': 1,
    'name': '',
    'email': '',
    'notificationEnabled': 1,
    'themeMode': 'system',
  };

  // Task Operations
  Future<int> insertTask(Task task) async {
    if (kIsWeb) {
      final newId = (_inMemoryTasks.isEmpty) ? 1 : (_inMemoryTasks.map((t) => t.id ?? 0).reduce((a, b) => a > b ? a : b) + 1);
      task.id = newId;
      _inMemoryTasks.add(task);
      return newId;
    }
    final db = await _dbHelper.database;
    return await db.insert('tasks', task.toMap());
  }

  Future<List<Task>> getAllTasks() async {
    if (kIsWeb) {
      return List<Task>.from(_inMemoryTasks);
    }
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('tasks');
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  Future<int> updateTask(Task task) async {
    if (kIsWeb) {
      final idx = _inMemoryTasks.indexWhere((t) => t.id == task.id);
      if (idx != -1) _inMemoryTasks[idx] = task;
      return 1;
    }
    final db = await _dbHelper.database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(int id) async {
    if (kIsWeb) {
      _inMemoryTasks.removeWhere((t) => t.id == id);
      return 1;
    }
    final db = await _dbHelper.database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Profile operations
  Future<Map<String, dynamic>> getProfile() async {
    if (kIsWeb) {
      return Map<String, dynamic>.from(_inMemoryProfile);
    }
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> result = await db.query('profile', limit: 1);
    if (result.isNotEmpty) {
      return result.first;
    }

    final defaultProfile = {
      'id': 1,
      'name': '',
      'email': '',
      'notificationEnabled': 1,
      'themeMode': 'system',
    };

    await db.insert('profile', defaultProfile);
    return defaultProfile;
  }

  Future<void> updateProfile(Map<String, dynamic> profile) async {
    if (kIsWeb) {
      _inMemoryProfile.clear();
      _inMemoryProfile.addAll(profile);
      _inMemoryProfile['id'] = 1;
      return;
    }
    final db = await _dbHelper.database;
    // Ensure single-row profile: delete existing and insert updated
    await db.delete('profile');
    final row = Map<String, dynamic>.from(profile);
    row['id'] = 1;
    await db.insert('profile', row);
  }
}
