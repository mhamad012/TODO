import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taskflow/controllers/profile_controller.dart';
import 'package:taskflow/controllers/theme_controller.dart';
import 'package:taskflow/screens/login_screen.dart';
import 'package:taskflow/controllers/task_controller.dart';

class ProfileScreen extends StatelessWidget {
  final ProfileController profileController = Get.find();
  final ThemeController themeController = Get.find();
  final TaskController taskController = Get.find();

  ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with Profile Info
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF4A5FD9), Color(0xFF8B7FDB)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
              child: Column(
                children: [
                  // Profile Avatar (gradient circle with white border)
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF6A7BE0), Color(0xFF8B7FDB)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _getInitials(),
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Name and Email
                  Text(
                    profileController.nameController.text,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profileController.emailController.text,
                    style: const TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Stats Cards (dynamic)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Obx(() {
                final total = taskController.tasks.length;
                final completed = taskController.tasks
                    .where((t) => t.isCompleted)
                    .length;
                final pending = total - completed;
                return Row(
                  children: [
                    _buildStatCard(total.toString(), 'Total Tasks', context),
                    const SizedBox(width: 12),
                    _buildStatCard(completed.toString(), 'Completed', context),
                    const SizedBox(width: 12),
                    _buildStatCard(pending.toString(), 'Pending', context),
                  ],
                );
              }),
            ),
            const SizedBox(height: 30),
            // Menu Items
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.person,
                    iconColor: Colors.grey,
                    title: 'Edit Profile',
                    context: context,
                    onTap: () {
                      Get.defaultDialog(
                        title: 'Edit Profile',
                        content: Column(
                          children: [
                            TextField(
                              controller: profileController.nameController,
                              decoration: InputDecoration(
                                labelText: 'Name',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: profileController.emailController,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              profileController.saveProfile();
                              Get.back();
                            },
                            child: const Text('Save'),
                          ),
                        ],
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.notifications,
                    iconColor: const Color(0xFFFFB74D),
                    title: 'Notifications',
                    context: context,
                    onTap: () {
                      Get.defaultDialog(
                        title: 'Notifications',
                        content: Obx(() {
                          return SwitchListTile(
                            title: const Text('Enable Notifications'),
                            value: profileController.notificationEnabled.value,
                            onChanged: (value) {
                              profileController.toggleNotifications(value);
                            },
                          );
                        }),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.palette,
                    iconColor: const Color(0xFFEF9A9A),
                    title: 'Theme & Display',
                    context: context,
                    onTap: _showThemeDialog,
                  ),
                  _buildMenuItem(
                    icon: Icons.bar_chart,
                    iconColor: const Color(0xFF81C784),
                    title: 'Task Statistics',
                    context: context,
                    onTap: () {
                      Get.defaultDialog(
                        title: 'Task Statistics',
                        content: Column(
                          children: [
                            _buildStatRow(
                              'Total Tasks',
                              taskController.tasks.length.toString(),
                            ),
                            _buildStatRow(
                              'Completed',
                              taskController.tasks
                                  .where((t) => t.isCompleted)
                                  .length
                                  .toString(),
                            ),
                            _buildStatRow(
                              'Pending',
                              taskController.tasks
                                  .where((t) => !t.isCompleted)
                                  .length
                                  .toString(),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.info,
                    iconColor: Colors.grey,
                    title: 'About TaskFlow',
                    context: context,
                    onTap: () {
                      Get.defaultDialog(
                        title: 'About TaskFlow',
                        content: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('TaskFlow - Todo List Application'),
                            SizedBox(height: 8),
                            Text('Version: 1.0.0'),
                            SizedBox(height: 8),
                            Text('Developed by: Mohammad Ghrayeb & Ali Alayan'),
                            SizedBox(height: 8),
                            Text(
                              'Course: CSC 415 - Mobile Application Development',
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: Get.back,
                            child: const Text('Close'),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _logout,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Theme.of(context).cardColor,
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                  child: const Text(
                    'Logout',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  String _getInitials() {
    final name = profileController.nameController.text;
    if (name.isEmpty) return 'AA';
    final parts = name.split(' ');
    return '${parts[0][0]}${parts.length > 1 ? parts[1][0] : parts[0][0]}';
  }

  Widget _buildStatCard(String value, String label, BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _logout() {
    Get.defaultDialog(
      title: 'Logout',
      middleText: 'Are you sure you want to logout?',
      textConfirm: 'Logout',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Theme.of(Get.context!).colorScheme.error,
      onConfirm: () {
        profileController.nameController.clear();
        profileController.emailController.clear();
        profileController.saveProfile();
        Get.offAll(() => const LoginScreen());
      },
    );
  }

  void _showThemeDialog() {
    Get.defaultDialog(
      title: 'Select Theme',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RadioListTile<ThemeMode>(
            title: const Text('System Default'),
            value: ThemeMode.system,
            groupValue: themeController.themeMode.value,
            onChanged: (value) {
              if (value != null) {
                themeController.toggleTheme(value);
                Get.back();
              }
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Light'),
            value: ThemeMode.light,
            groupValue: themeController.themeMode.value,
            onChanged: (value) {
              if (value != null) {
                themeController.toggleTheme(value);
                Get.back();
              }
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Dark'),
            value: ThemeMode.dark,
            groupValue: themeController.themeMode.value,
            onChanged: (value) {
              if (value != null) {
                themeController.toggleTheme(value);
                Get.back();
              }
            },
          ),
        ],
      ),
    );
  }
}
