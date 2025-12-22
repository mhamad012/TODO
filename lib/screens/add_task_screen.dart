import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taskflow/controllers/task_controller.dart';
import 'package:taskflow/models/task_model.dart';
import 'package:intl/intl.dart';

class AddTaskScreen extends StatefulWidget {
  final Task? existingTask;

  const AddTaskScreen({super.key, this.existingTask});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController dateTimeController;
  String selectedPriority = 'Medium';
  String selectedCategory = 'Work';
  late DateTime selectedDateTime;

  final List<String> priorities = ['Low', 'Medium', 'High'];
  final List<String> categories = ['Work', 'Personal', 'Shopping', 'Health', 'Other'];
  final TaskController taskController = Get.find();

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.existingTask?.title ?? '');
    descriptionController = TextEditingController(text: widget.existingTask?.description ?? '');
    
    if (widget.existingTask != null) {
      selectedDateTime = widget.existingTask!.dueDate;
    } else {
      selectedDateTime = DateTime.now().add(const Duration(days: 1));
    }
    
    _updateDateTimeDisplay();
    selectedPriority = widget.existingTask?.priority ?? 'Medium';
    selectedCategory = widget.existingTask?.category ?? 'Work';
  }

  void _updateDateTimeDisplay() {
    dateTimeController = TextEditingController(
      text: DateFormat('MMM dd, yyyy').format(selectedDateTime),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    dateTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    onTap: () => Get.back(),
                    child: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    widget.existingTask != null ? 'Edit Task' : 'New Task',
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
                    controller: titleController,
                    decoration: InputDecoration(
                      hintText: 'What needs to be done?',
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
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Description
                  _buildSectionLabel('Description'),
                  const SizedBox(height: 10),
                  TextField(
                    controller: descriptionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Add details about your task...',
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
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Due Date & Time (Combined)
                  _buildSectionLabel('Due Date & Time'),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => _selectDateTime(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[50],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, color: Colors.grey[600], size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              dateTimeController.text,
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.access_time, color: Colors.grey[600], size: 20),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('h:mm a').format(selectedDateTime),
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Priority
                  _buildSectionLabel('Priority Level'),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[50],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: DropdownButton<String>(
                      value: selectedPriority,
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: priorities.map((priority) {
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
                        setState(() {
                          selectedPriority = newValue!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Category
                  _buildSectionLabel('Category'),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[50],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: DropdownButton<String>(
                      value: selectedCategory,
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Row(
                            children: [
                              Icon(_getCategoryIcon(category), size: 18, color: Colors.grey[600]),
                              const SizedBox(width: 10),
                              Text(category),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedCategory = newValue!;
                        });
                      },
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
                        onPressed: _saveTask,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          widget.existingTask != null ? 'Save Changes' : 'Create Task',
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

  Future<void> _selectDateTime(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4A5FD9),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedDateTime),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF4A5FD9),
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        setState(() {
          selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          _updateDateTimeDisplay();
        });
      }
    }
  }

  void _saveTask() {
    if (titleController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter a task title');
      return;
    }

    if (widget.existingTask != null) {
      widget.existingTask!.title = titleController.text;
      widget.existingTask!.description = descriptionController.text;
      widget.existingTask!.dueDate = selectedDateTime;
      widget.existingTask!.priority = selectedPriority;
      widget.existingTask!.category = selectedCategory;
      
      taskController.updateTask(widget.existingTask!);
      Get.snackbar('Success', 'Task updated successfully');
    } else {
      final newTask = Task(
        id: DateTime.now().millisecondsSinceEpoch,
        title: titleController.text,
        description: descriptionController.text,
        dueDate: selectedDateTime,
        priority: selectedPriority,
        category: selectedCategory,
        isCompleted: false,
        createdAt: DateTime.now(),
      );
      
      taskController.addTask(newTask);
      Get.snackbar('Success', 'Task created successfully');
    }
    
    Get.back();
  }
}
