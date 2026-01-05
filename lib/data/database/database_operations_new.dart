import 'package:flutter/foundation.dart';
import 'package:taskflow/models/task_model.dart';
import 'database_helper.dart';

class DatabaseOperations {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // In-memory fallback for web
  static final List<Task> _inMemoryTasks = <Task>[];
  static final List<Map<String, dynamic>> _inMemoryUsers = [];

  // ==================== TASK OPERATIONS ====================
  
  Future<int> insertTask(Task task) async {
    if (kIsWeb) {
      final newId = (_inMemoryTasks.isEmpty) 
          ? 1 
          : (_inMemoryTasks.map((t) => t.id ?? 0).reduce((a, b) => a > b ? a : b) + 1);
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

  // ==================== USER OPERATIONS ====================

  // Get user by email
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    if (kIsWeb) {
      try {
        return _inMemoryUsers.firstWhere((user) => user['email'] == email);
      } catch (e) {
        return null;
      }
    }
    
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    
    return result.isNotEmpty ? result.first : null;
  }

  // Register new user
  Future<int> registerUser({
    required String email,
    required String password,
    String name = '',
  }) async {
    if (kIsWeb) {
      final newUser = {
        'id': _inMemoryUsers.length + 1,
        'email': email,
        'password': password,
        'name': name,
        'notificationEnabled': 1,
        'themeMode': 'system',
        'createdAt': DateTime.now().toIso8601String(),
      };
      _inMemoryUsers.add(newUser);
      return newUser['id'] as int;
    }
    
    final db = await _dbHelper.database;
    return await db.insert('users', {
      'email': email,
      'password': password,
      'name': name,
      'notificationEnabled': 1,
      'themeMode': 'system',
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  // Update user information
  Future<int> updateUser(String email, Map<String, dynamic> updates) async {
    if (kIsWeb) {
      final idx = _inMemoryUsers.indexWhere((user) => user['email'] == email);
      if (idx != -1) {
        _inMemoryUsers[idx].addAll(updates);
        return 1;
      }
      return 0;
    }
    
    final db = await _dbHelper.database;
    return await db.update(
      'users',
      updates,
      where: 'email = ?',
      whereArgs: [email],
    );
  }

  // Authenticate user (login)
  Future<bool> authenticateUser(String email, String password) async {
    if (kIsWeb) {
      try {
        final user = _inMemoryUsers.firstWhere(
          (user) => user['email'] == email && user['password'] == password
        );
        return true;
      } catch (e) {
        return false;
      }
    }
    
    final db = await _dbHelper.database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
      limit: 1,
    );
    
    return result.isNotEmpty;
  }

  // Check if user exists (for registration validation)
  Future<bool> userExists(String email) async {
    if (kIsWeb) {
      return _inMemoryUsers.any((user) => user['email'] == email);
    }
    
    final db = await _dbHelper.database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    
    return result.isNotEmpty;
  }

  // Delete user account
  Future<int> deleteUser(String email) async {
    if (kIsWeb) {
      _inMemoryUsers.removeWhere((user) => user['email'] == email);
      // Also remove all tasks for this user
      _inMemoryTasks.removeWhere((task) => task.userId == email);
      return 1;
    }
    
    final db = await _dbHelper.database;
    
    // Delete user's tasks first
    await db.delete(
      'tasks',
      where: 'userId = ?',
      whereArgs: [email],
    );
    
    // Then delete the user
    return await db.delete(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
  }

  // Get all users (for admin purposes if needed)
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    if (kIsWeb) {
      return List<Map<String, dynamic>>.from(_inMemoryUsers);
    }
    
    final db = await _dbHelper.database;
    return await db.query('users');
  }
}