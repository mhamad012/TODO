// controllers/task_form_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:taskflow/models/task_model.dart';

/// Controller for managing task form state (Add/Edit Task)
/// Separate from TaskController to follow Single Responsibility Principle
/// This demonstrates "lifting state up" - form state is centralized here
class TaskFormController extends GetxController {
  // Text editing controllers for form fields
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final dateTimeController = TextEditingController();

  // Observable form state - lifted up from widget
  final selectedPriority = 'Medium'.obs;
  final selectedCategory = 'Work'.obs;
  final selectedDateTime = Rx<DateTime>(
    DateTime.now().add(const Duration(days: 1)),
  );

  // Static lists for dropdowns (could also come from TaskController if needed)
  final List<String> priorities = ['Low', 'Medium', 'High'];
  final List<String> categories = [
    'Work',
    'Personal',
    'Shopping',
    'Health',
    'Other',
  ];

  /// Initialize form for editing an existing task
  void initializeForEdit(Task? task) {
    if (task != null) {
      titleController.text = task.title;
      descriptionController.text = task.description;
      selectedDateTime.value = task.dueDate;
      selectedPriority.value = task.priority;
      selectedCategory.value = task.category;
    } else {
      // Reset for new task
      clearForm();
    }
    updateDateTimeDisplay();
  }

  /// Update the date/time display text
  void updateDateTimeDisplay() {
    dateTimeController.text = DateFormat(
      'MMM dd, yyyy',
    ).format(selectedDateTime.value);
  }

  /// Update selected priority
  void setPriority(String priority) {
    selectedPriority.value = priority;
  }

  /// Update selected category
  void setCategory(String category) {
    selectedCategory.value = category;
  }

  /// Update selected date and time
  void setDateTime(DateTime dateTime) {
    selectedDateTime.value = dateTime;
    updateDateTimeDisplay();
  }

  /// Clear form data
  void clearForm() {
    titleController.clear();
    descriptionController.clear();
    selectedPriority.value = 'Medium';
    selectedCategory.value = 'Work';
    selectedDateTime.value = DateTime.now().add(const Duration(days: 1));
    updateDateTimeDisplay();
  }

  /// Validate form data
  bool validateForm() {
    if (titleController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter a task title');
      return false;
    }
    return true;
  }

  @override
  void onClose() {
    // Clean up controllers when not needed
    titleController.dispose();
    descriptionController.dispose();
    dateTimeController.dispose();
    super.onClose();
  }
}
