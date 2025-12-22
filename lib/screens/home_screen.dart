import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:taskflow/controllers/task_controller.dart';
import 'package:taskflow/screens/profile_screen.dart';
import 'package:taskflow/screens/add_task_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedTab = 'All';

  @override
  Widget build(BuildContext context) {
    final TaskController taskController = Get.find<TaskController>();

    return Scaffold(
      body: Container(
        color: const Color(0xFFF5F5F5),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header Section with Gradient
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF4A5FD9), Color(0xFF8B7FDB)],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'My Tasks',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Monday, December 16, 2025',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => Get.to(() => ProfileScreen()),
                          child: Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white24,
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Content area
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Search Bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search tasks...',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          icon: Icon(Icons.search, color: Colors.grey[600]),
                          border: InputBorder.none,
                        ),
                        onChanged: (value) {
                          taskController.setSearchQuery(value);
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Tab Navigation
                    Row(
                      children: [
                        _buildTab('All', _selectedTab == 'All', () {
                          setState(() => _selectedTab = 'All');
                        }),
                        const SizedBox(width: 40),
                        _buildTab('Today', _selectedTab == 'Today', () {
                          setState(() => _selectedTab = 'Today');
                        }),
                        const SizedBox(width: 40),
                        _buildTab('Completed', _selectedTab == 'Completed', () {
                          setState(() => _selectedTab = 'Completed');
                        }),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Task List
                    Obx(() {
                      List<dynamic> displayedTasks = taskController.filteredTasks;

                      if (_selectedTab == 'Today') {
                        displayedTasks = taskController.filteredTasks
                            .where((task) {
                              final today = DateTime.now();
                              return task.dueDate.day == today.day &&
                                  task.dueDate.month == today.month &&
                                  task.dueDate.year == today.year;
                            })
                            .toList();
                      } else if (_selectedTab == 'Completed') {
                        displayedTasks = taskController.filteredTasks
                            .where((task) => task.isCompleted)
                            .toList();
                      }

                      if (displayedTasks.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Column(
                            children: [
                              Icon(Icons.check_circle_outline, size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                'No tasks yet',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return Column(
                        children: displayedTasks.map((task) {
                          return _buildTaskCard(task, taskController);
                        }).toList(),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const AddTaskScreen()),
        backgroundColor: const Color(0xFF4A5FD9),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildTab(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive ? const Color(0xFF4A5FD9) : Colors.grey[500],
            ),
          ),
          if (isActive)
            Container(
              height: 3,
              width: 35,
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E88E5),
                borderRadius: BorderRadius.circular(2),
              ),
            )
          else
            const SizedBox(height: 11),
        ],
      ),
    );
  }

  Widget _buildTaskCard(dynamic task, TaskController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left Border
          Container(
            width: 5,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFF1E88E5),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (task.id != null) controller.toggleTaskCompletion(task.id!);
                        },
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: task.isCompleted
                                ? const Color(0xFF4A5FD9)
                                : Colors.white,
                            border: Border.all(
                              color: task.isCompleted
                                  ? const Color(0xFF4A5FD9)
                                  : const Color(0xFF1E88E5),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: task.isCompleted
                              ? const Icon(Icons.check,
                                  size: 16, color: Colors.white)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: task.isCompleted
                                    ? Colors.grey[400]
                                    : Colors.black87,
                                decoration: task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.calendar_today,
                                    size: 14, color: Colors.grey[500]),
                                const SizedBox(width: 4),
                                Text(
                                  DateFormat('MMM dd, yyyy').format(task.dueDate),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _getPriorityColor(task.priority)
                                        .withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    task.priority,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _getPriorityColor(task.priority),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text('Delete'),
                onTap: () {
                  if (task.id != null) controller.deleteTask(task.id!);
                },
              ),
            ],
            child: Icon(Icons.more_vert, color: Colors.grey[400], size: 20),
          ),
        ],
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
}
