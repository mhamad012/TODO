import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taskflow/controllers/profile_controller.dart';
import 'package:taskflow/controllers/task_controller.dart';
import 'package:taskflow/controllers/task_form_controller.dart';
import 'package:taskflow/models/task_model.dart';
import 'package:intl/intl.dart';
import 'package:taskflow/screens/home_screen.dart';

class AddTaskScreen extends StatelessWidget {
  final Task? existingTask;

  const AddTaskScreen({super.key, this.existingTask});

  @override
  Widget build(BuildContext context) {
    // Initialize form controller and task controller
    final formController = Get.put(TaskFormController());
    formController.initializeForEdit(existingTask);

    final taskController = Get.find<TaskController>();

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with back button and title
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF4A5FD9), Color(0xFF8B7FDB)],
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Get.delete<TaskFormController>();
                      Get.back();
                    },
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    existingTask != null ? 'Edit Task' : 'New Task',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            // Form content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Task Title
                  _buildSectionLabel('Task Title *'),
                  const SizedBox(height: 10),
                  TextField(
                    controller: formController.titleController,
                    decoration: _buildInputDecoration(
                      context,
                      hintText: 'What needs to be done?',
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Description
                  _buildSectionLabel('Description'),
                  const SizedBox(height: 10),
                  TextField(
                    controller: formController.descriptionController,
                    maxLines: 4,
                    decoration: _buildInputDecoration(
                      context,
                      hintText: 'Add details about your task...',
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Due Date & Time (Combined)
                  _buildSectionLabel('Due Date & Time'),
                  const SizedBox(height: 10),
                  Obx(
                    () => GestureDetector(
                      onTap: () => _selectDateTime(context, formController),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[50],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: Colors.grey[600],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                formController.dateTimeController.text,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.access_time,
                              color: Colors.grey[600],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              DateFormat(
                                'h:mm a',
                              ).format(formController.selectedDateTime.value),
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Priority
                  _buildSectionLabel('Priority Level'),
                  const SizedBox(height: 10),
                  Obx(
                    () => Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[50],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: DropdownButton<String>(
                        value: formController.selectedPriority.value,
                        isExpanded: true,
                        underline: const SizedBox(),
                        items: formController.priorities.map((priority) {
                          return DropdownMenuItem(
                            value: priority,
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _getPriorityColor(priority),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text('$priority Priority'),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          formController.setPriority(newValue!);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Category
                  _buildSectionLabel('Category'),
                  const SizedBox(height: 10),
                  Obx(
                    () => Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[50],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: DropdownButton<String>(
                        value: formController.selectedCategory.value,
                        isExpanded: true,
                        underline: const SizedBox(),
                        items: formController.categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Row(
                              children: [
                                Icon(
                                  _getCategoryIcon(category),
                                  size: 18,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 10),
                                Text(category),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          formController.setCategory(newValue!);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Create/Save Button
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF4A5FD9), Color(0xFF8B7FDB)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton(
                        onPressed: () =>
                            _saveTask(formController, taskController),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          existingTask != null ? 'Save Changes' : 'Create Task',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  InputDecoration _buildInputDecoration(
    BuildContext context, {
    required String hintText,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey[400]),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 2),
      ),
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return const Color(0xFFE53935);
      case 'Medium':
        return const Color(0xFFFB8C00);
      case 'Low':
        return const Color(0xFF43A047);
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Work':
        return Icons.work;
      case 'Personal':
        return Icons.library_books;
      case 'Shopping':
        return Icons.shopping_bag;
      case 'Health':
        return Icons.health_and_safety;
      default:
        return Icons.tag;
    }
  }

  Future<void> _selectDateTime(
    BuildContext context,
    TaskFormController formController,
  ) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: formController.selectedDateTime.value,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF4A5FD9)),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          formController.selectedDateTime.value,
        ),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(primary: Color(0xFF4A5FD9)),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        final newDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        formController.setDateTime(newDateTime);
      }
    }
  }

  void _saveTask(
  TaskFormController formController,
  TaskController taskController,
) {
  // Validate form
  if (!formController.validateForm()) {
    return;
  }

  final profileController = Get.find<ProfileController>();
  final currentEmail = profileController.currentUserEmail.value;

  if (existingTask != null) {
    existingTask!.title = formController.titleController.text;
    existingTask!.description = formController.descriptionController.text;
    existingTask!.dueDate = formController.selectedDateTime.value;
    existingTask!.priority = formController.selectedPriority.value;
    existingTask!.category = formController.selectedCategory.value;

    taskController.updateTask(existingTask!);
    Get.snackbar('Success', 'Task updated successfully');
  } else {
    final newTask = Task(
      id: DateTime.now().millisecondsSinceEpoch,
      title: formController.titleController.text,
      description: formController.descriptionController.text,
      dueDate: formController.selectedDateTime.value,
      priority: formController.selectedPriority.value,
      category: formController.selectedCategory.value,
      isCompleted: false,
      createdAt: DateTime.now(),
      userId: currentEmail,
    );

    taskController.addTask(newTask);
    Get.snackbar('Success', 'Task created successfully');
  }

  // FIXED: Navigate first, then clean up
  Get.offAll(() => const HomeScreen());
  
  // Clean up after navigation (with small delay)
  Future.delayed(const Duration(milliseconds: 100), () {
    Get.delete<TaskFormController>();
  });
}
}
