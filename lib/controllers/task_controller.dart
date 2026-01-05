// controllers/task_controller.dart
import 'package:get/get.dart';
import 'package:taskflow/models/task_model.dart';
import 'package:taskflow/data/database/database_operations_new.dart';
import 'package:taskflow/controllers/profile_controller.dart';

class TaskController extends GetxController {
  final DatabaseOperations _dbOps = DatabaseOperations();

  final RxList<Task> tasks = <Task>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = 'All'.obs;
  final RxString selectedPriority = 'All'.obs;
  final RxString selectedTab = 'All'.obs;

  @override
  void onInit() {
    super.onInit();
    loadTasks();
  }

  // Load ALL tasks from database
  Future<void> loadTasks() async {
    final all = await _dbOps.getAllTasks();
    tasks.assignAll(all);
  }

  // Add task with current user's userId
  Future<void> addTask(Task task) async {
    final ProfileController profileController = Get.find<ProfileController>();
    
    // Set the userId to current user's email
    task.userId = profileController.currentUserEmail.value;
    
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

  void setSelectedTab(String tab) => selectedTab.value = tab;

  // ADDED: Get only current user's tasks
  List<Task> get userTasks {
    final ProfileController profileController = Get.find<ProfileController>();
    final currentEmail = profileController.currentUserEmail.value;
    
    if (currentEmail.isEmpty) return [];
    
    return tasks.where((task) => task.userId == currentEmail).toList();
  }

  List<Task> get todayTasks {
    final today = DateTime.now();
    return filteredTasks.where((task) {
      return task.dueDate.day == today.day &&
          task.dueDate.month == today.month &&
          task.dueDate.year == today.year;
    }).toList();
  }

  List<Task> get completedTasks {
    return filteredTasks.where((task) => task.isCompleted).toList();
  }

  List<String> getCategories() {
    // CHANGED: Use userTasks instead of tasks
    final cats = userTasks.map((t) => t.category).toSet().toList();
    cats.sort();
    return ['All', ...cats];
  }

  List<Task> get filteredTasks {
    // CHANGED: Filter from userTasks instead of tasks
    return userTasks.where((t) {
      final matchesQuery = searchQuery.value.isEmpty ||
          t.title.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          t.description.toLowerCase().contains(searchQuery.value.toLowerCase());

      final matchesCategory = selectedCategory.value == 'All' || t.category == selectedCategory.value;
      final matchesPriority = selectedPriority.value == 'All' || t.priority == selectedPriority.value;

      return matchesQuery && matchesCategory && matchesPriority;
    }).toList();
  }
}