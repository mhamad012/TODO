import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taskflow/controllers/task_controller.dart';
import 'package:taskflow/models/task_model.dart';
import 'package:taskflow/screens/add_task_screen.dart';

class TaskDetailsScreen extends StatelessWidget {
  final Task task;
  final TaskController taskController = Get.find();

  TaskDetailsScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editTask(context),
          ),
          IconButton(icon: const Icon(Icons.delete), onPressed: _deleteTask),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (task.description.isNotEmpty) ...[
                    Text(
                      task.description,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                  ],

                  _buildDetailRow(
                    Icons.calendar_today,
                    'Due Date',
                    '${task.dueDate.year}-${task.dueDate.month}-${task.dueDate.day}',
                  ),

                  _buildDetailRow(
                    Icons.priority_high,
                    'Priority',
                    task.priority.capitalizeFirst ?? task.priority,
                    color: _getPriorityColor(task.priority),
                  ),

                  _buildDetailRow(Icons.category, 'Category', task.category),

                  _buildDetailRow(
                    Icons.circle,
                    'Status',
                    task.isCompleted ? 'Completed' : 'Pending',
                    color: task.isCompleted ? Colors.green : Colors.orange,
                  ),

                  if (task.tags.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Tags',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: task.tags.map((tag) {
                        return Chip(label: Text(tag));
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          if (!task.isCompleted) ...[
            ElevatedButton(
              onPressed: _completeTask,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.green,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle),
                  SizedBox(width: 8),
                  Text('Mark as Complete'),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          ElevatedButton(
            onPressed: () => _editTask(context),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.edit),
                SizedBox(width: 8),
                Text('Edit Task'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _completeTask() async {
    await taskController.toggleTaskCompletion(task.id!);
    Get.back();
    Get.snackbar(
      'Task Completed',
      'Task marked as complete',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  void _deleteTask() {
    Get.defaultDialog(
      title: 'Delete Task',
      middleText: 'Are you sure you want to delete this task?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      onConfirm: () async {
        await taskController.deleteTask(task.id!);
        Get.back();
        Get.back();
        Get.snackbar(
          'Task Deleted',
          'Task has been deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      },
    );
  }

  void _editTask(BuildContext context) {
    // Navigate to the AddTaskScreen in edit mode
    Get.to(() => AddTaskScreen(existingTask: task));
  }
}
