import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taskflow/controllers/task_controller.dart';
import 'package:taskflow/models/task_model.dart';
import 'package:taskflow/screens/profile_screen.dart';
import 'package:taskflow/screens/task_list_screen.dart';
import 'package:taskflow/screens/add_task_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TaskController taskController = Get.find<TaskController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('TaskFlow'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Get.to(() => ProfileScreen());
            },
          ),
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              Get.to(() => TaskListScreen());
            },
          ),
        ],
      ),
      body: Obx(() {
        if (taskController.tasks.isEmpty) {
          return const Center(
            child: Text(
              'No tasks yet!\nTap + to add a task.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: taskController.tasks.length,
          itemBuilder: (context, index) {
            final task = taskController.tasks[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Checkbox(
                  value: task.isCompleted,
                  onChanged: (value) {
                    if (task.id != null) taskController.toggleTaskCompletion(task.id!);
                  },
                ),
                title: Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    decoration: task.isCompleted 
                        ? TextDecoration.lineThrough 
                        : TextDecoration.none,
                    color: task.isCompleted ? Colors.grey : Colors.black,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (task.description.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          task.description,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          Chip(
                            label: Text(
                              task.category,
                              style: const TextStyle(fontSize: 12),
                            ),
                            backgroundColor: Colors.blue[50],
                          ),
                          const SizedBox(width: 8),
                          Chip(
                            label: Text(
                              task.priority.toUpperCase(),
                              style: TextStyle(
                                fontSize: 11,
                                color: _getPriorityColor(task.priority),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            backgroundColor: _getPriorityBackground(task.priority),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    if (task.id != null) taskController.deleteTask(task.id!);
                  },
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => const AddTaskScreen());
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
  
  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high': return Colors.red;
      case 'medium': return Colors.orange;
      case 'low': return Colors.green;
      default: return Colors.grey;
    }
  }
  
  Color _getPriorityBackground(String priority) {
    switch (priority) {
      case 'high': return Colors.red[50]!;
      case 'medium': return Colors.orange[50]!;
      case 'low': return Colors.green[50]!;
      default: return Colors.grey[50]!;
    }
  }
}