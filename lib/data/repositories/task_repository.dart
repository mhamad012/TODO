import 'package:taskflow/data/database/database_operations_new.dart';
import 'package:taskflow/models/task_model.dart';

class TaskRepository {
  final DatabaseOperations _dbOps = DatabaseOperations();

  Future<List<Task>> getAllTasks() async {
    return await _dbOps.getAllTasks();
  }

  Future<int> addTask(Task task) async {
    return await _dbOps.insertTask(task);
  }

  Future<int> updateTask(Task task) async {
    return await _dbOps.updateTask(task);
  }

  Future<int> deleteTask(int id) async {
    return await _dbOps.deleteTask(id);
  }
}