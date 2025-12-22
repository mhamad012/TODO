// controllers/task_controller.dart
import 'package:get/get.dart';
import 'package:taskflow/models/task_model.dart';
import 'package:taskflow/data/database/database_operations_new.dart';

class TaskController extends GetxController {
  final DatabaseOperations _dbOps = DatabaseOperations();

  final RxList<Task> tasks = <Task>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = 'All'.obs;
  final RxString selectedPriority = 'All'.obs;

  @override
  void onInit() {
    super.onInit();
    loadTasks();
  }

  Future<void> loadTasks() async {
    final all = await _dbOps.getAllTasks();
    tasks.assignAll(all);
  }

  Future<void> addTask(Task task) async {
    final id = await _dbOps.insertTask(task);
    task.id = id;
    tasks.add(task);
  }

  Future<void> updateTask(Task task) async {
    await _dbOps.updateTask(task);
    final idx = tasks.indexWhere((t) => t.id == task.id);
    if (idx != -1) tasks[idx] = task;
    tasks.refresh();
  }

  Future<void> deleteTask(int id) async {
    await _dbOps.deleteTask(id);
    tasks.removeWhere((t) => t.id == id);
  }

  Future<void> toggleTaskCompletion(int id) async {
    final idx = tasks.indexWhere((t) => t.id == id);
    if (idx == -1) return;
    final task = tasks[idx];
    task.isCompleted = !task.isCompleted;
    await updateTask(task);
  }

  // Search & filters
  void setSearchQuery(String q) => searchQuery.value = q;

  void setCategory(String category) => selectedCategory.value = category;

  void setPriority(String priority) => selectedPriority.value = priority;

  List<String> getCategories() {
    final cats = tasks.map((t) => t.category).toSet().toList();
    cats.sort();
    return ['All', ...cats];
  }

  List<Task> get filteredTasks {
    return tasks.where((t) {
      final matchesQuery = searchQuery.value.isEmpty ||
          t.title.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          t.description.toLowerCase().contains(searchQuery.value.toLowerCase());

      final matchesCategory = selectedCategory.value == 'All' || t.category == selectedCategory.value;
      final matchesPriority = selectedPriority.value == 'All' || t.priority == selectedPriority.value;

      return matchesQuery && matchesCategory && matchesPriority;
    }).toList();
  }
}