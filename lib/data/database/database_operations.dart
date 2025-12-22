// data/database/database_operations.dart
import 'package:sqflite/sqflite.dart';
import 'package:taskflow/models/task_model.dart';
import 'database_helper.dart';

class DatabaseOperations {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Task Operations
  Future<int> insertTask(Task task) async {
    final db = await _dbHelper.database;
    return await db.insert('tasks', task.toMap());
  }

  Future<List<Task>> getAllTasks() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('tasks');
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  Future<int> updateTask(Task task) async {
    final db = await _dbHelper.database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Profile operations
  Future<Map<String, dynamic>> getProfile() async {
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
    final db = await _dbHelper.database;
    // Ensure single-row profile: delete existing and insert updated
    await db.delete('profile');
    final row = Map<String, dynamic>.from(profile);
    row['id'] = 1;
    await db.insert('profile', row);
  }
}