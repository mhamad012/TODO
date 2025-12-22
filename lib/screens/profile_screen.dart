import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taskflow/controllers/profile_controller.dart';
import 'package:taskflow/controllers/theme_controller.dart';
import 'package:taskflow/screens/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  final ProfileController profileController = Get.find();
  final ThemeController themeController = Get.find();

  ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
            // Profile Picture
            CircleAvatar(
              radius: 50,
              child: Icon(
                Icons.person,
                size: 50,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              backgroundColor: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 16),
            
            // User Info Form
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: profileController.nameController,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: profileController.emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Settings
            Card(
              child: Column(
                children: [
                  Obx(() {
                    return SwitchListTile(
                      title: const Text('Enable Notifications'),
                      subtitle: const Text('Receive task reminders'),
                      value: profileController.notificationEnabled.value,
                      onChanged: (value) {
                        profileController.toggleNotifications(value);
                      },
                      secondary: const Icon(Icons.notifications),
                    );
                  }),
                  
                  Obx(() {
                    return ListTile(
                      leading: const Icon(Icons.color_lens),
                      title: const Text('Theme'),
                      subtitle: Text(themeController.themeMode.value.toString().split('.').last.capitalizeFirst!),
                      onTap: _showThemeDialog,
                    );
                  }),
                  
                  ListTile(
                    leading: const Icon(Icons.info),
                    title: const Text('About'),
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
                            Text('Course: CSC 415 - Mobile Application Development'),
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
            
            const SizedBox(height: 32),
            
            ElevatedButton(
              onPressed: () {
                profileController.saveProfile();
                Get.snackbar(
                  'Profile Updated',
                  'Your profile has been updated successfully',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Save Profile'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue,
              ),
              child: const Text('Logout'),
            ),
          ],
          ),
        ),
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
      buttonColor: Colors.red,
      onConfirm: () {
        profileController.nameController.clear();
        profileController.emailController.clear();
        profileController.saveProfile();
        Get.offAll(() => const LoginScreen());
        Get.snackbar('Logged Out', 'You have been logged out',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.blue,
            colorText: Colors.white);
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