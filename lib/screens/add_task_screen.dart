import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taskflow/controllers/task_controller.dart';
import 'package:taskflow/models/task_model.dart';
import 'package:taskflow/screens/home_screen.dart';

class AddTaskScreen extends StatefulWidget {
  final Task? task;
  const AddTaskScreen({super.key, this.task});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TaskController taskController = Get.find();
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  
  DateTime _dueDate = DateTime.now().add(const Duration(days: 1));
  String _priority = 'medium';
  List<String> _tags = [];

  bool get isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final t = widget.task!;
      _titleController.text = t.title;
      _descriptionController.text = t.description;
      _categoryController.text = t.category;
      _tags = List.from(t.tags);
      _dueDate = t.dueDate;
      _priority = t.priority;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Task'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            
            // Due Date Picker
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Due Date'),
              subtitle: Text('${_dueDate.year}-${_dueDate.month}-${_dueDate.day}'),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: _dueDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (selectedDate != null) {
                    setState(() {
                      _dueDate = selectedDate;
                    });
                  }
                },
              ),
            ),
            
            // Priority Picker
            ListTile(
              leading: const Icon(Icons.priority_high),
              title: const Text('Priority'),
              trailing: DropdownButton<String>(
                value: _priority,
                onChanged: (String? newValue) {
                  setState(() {
                    _priority = newValue!;
                  });
                },
                items: <String>['low', 'medium', 'high']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value.capitalizeFirst ?? value),
                  );
                }).toList(),
              ),
            ),
            
            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _tagsController,
              decoration: InputDecoration(
                labelText: 'Tags (comma separated)',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.tag),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    if (_tagsController.text.isNotEmpty) {
                      final newTags = _tagsController.text
                          .split(',')
                          .map((tag) => tag.trim())
                          .where((tag) => tag.isNotEmpty)
                          .toList();
                      setState(() {
                        _tags.addAll(newTags);
                        _tags = _tags.toSet().toList();
                      });
                      _tagsController.clear();
                    }
                  },
                ),
              ),
            ),
            
            // Display selected tags
            if (_tags.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: _tags.map((tag) {
                  return Chip(
                    label: Text(tag),
                    deleteIcon: const Icon(Icons.close),
                    onDeleted: () {
                      setState(() {
                        _tags.remove(tag);
                      });
                    },
                  );
                }).toList(),
              ),
            ],
            
            const SizedBox(height: 32),
            
            ElevatedButton(
              onPressed: _submitTask,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Add Task'),
            ),
          ],
        ),
      ),
    );
  }

  void _submitTask() async {
    if (_formKey.currentState!.validate()) {
      if (isEditing) {
        final edited = Task(
          id: widget.task!.id,
          title: _titleController.text,
          description: _descriptionController.text,
          dueDate: _dueDate,
          priority: _priority,
          category: _categoryController.text.isNotEmpty ? _categoryController.text : 'General',
          tags: _tags,
          createdAt: widget.task!.createdAt,
          isCompleted: widget.task!.isCompleted,
        );
        await taskController.updateTask(edited);
        Get.snackbar('Success', 'Task updated successfully', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        final task = Task(
          title: _titleController.text,
          description: _descriptionController.text,
          dueDate: _dueDate,
          priority: _priority,
          category: _categoryController.text.isNotEmpty ? _categoryController.text : 'General',
          tags: _tags,
          createdAt: DateTime.now(),
        );
        await taskController.addTask(task);
        Get.snackbar('Success', 'Task added successfully', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
      }

      Get.offAll(() => const HomeScreen());
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _tagsController.dispose();
    super.dispose();
  }
}