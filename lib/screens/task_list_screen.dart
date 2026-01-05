import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taskflow/controllers/task_controller.dart';
import 'package:taskflow/widgets/task_tile.dart';

class TaskListScreen extends StatelessWidget {
  final TaskController taskController = Get.find();

  TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                taskController.setSearchQuery(value);
              },
            ),
          ),
          Expanded(
            child: Obx(() {
              final tasks = taskController.filteredTasks;
              if (tasks.isEmpty) {
                return const Center(child: Text('No tasks found'));
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return TaskTile(task: task);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    Get.defaultDialog(
      title: 'Filter Tasks',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Category Filter
          Obx(() {
            final categories = taskController.getCategories();
            return DropdownButtonFormField<String>(
              value: taskController.selectedCategory.value,
              items: categories.map((category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  taskController.setCategory(value);
                }
              },
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
            );
          }),
          const SizedBox(height: 16),

          // Priority Filter
          Obx(() {
            return DropdownButtonFormField<String>(
              value: taskController.selectedPriority.value,
              items: ['All', 'low', 'medium', 'high'].map((priority) {
                return DropdownMenuItem(
                  value: priority,
                  child: Text(priority.capitalizeFirst ?? priority),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  taskController.setPriority(value);
                }
              },
              decoration: const InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(),
              ),
            );
          }),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            taskController.setCategory('All');
            taskController.setPriority('All');
            Get.back();
          },
          child: const Text('Reset'),
        ),
        TextButton(onPressed: Get.back, child: const Text('Close')),
      ],
    );
  }
}
