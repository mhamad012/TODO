import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taskflow/data/database/database_operations_new.dart';
import 'package:taskflow/controllers/profile_controller.dart';

class ThemeController extends GetxController {
  final Rx<ThemeMode> themeMode = ThemeMode.light.obs;
  final DatabaseOperations _dbOps = DatabaseOperations();

  @override
  void onInit() {
    super.onInit();
    // Don't load automatically - wait for user login
  }

  // Load theme preference for specific user
  Future<void> loadThemePreference() async {
    try {
      final ProfileController profileController = Get.find<ProfileController>();
      final currentEmail = profileController.currentUserEmail.value;
      
      if (currentEmail.isEmpty) {
        // No user logged in - use default light theme
        themeMode.value = ThemeMode.light;
        Get.changeThemeMode(ThemeMode.light);
        return;
      }

      final user = await _dbOps.getUserByEmail(currentEmail);
      
      if (user == null) {
        themeMode.value = ThemeMode.light;
        Get.changeThemeMode(ThemeMode.light);
        return;
      }

      final themeModeStr = user['themeMode'] ?? 'light';
      
      switch (themeModeStr.toLowerCase()) {
        case 'light':
          themeMode.value = ThemeMode.light;
          break;
        case 'dark':
          themeMode.value = ThemeMode.dark;
          break;
        case 'system':
          themeMode.value = ThemeMode.system;
          break;
        default:
          themeMode.value = ThemeMode.light;
      }
      
      // Apply the theme
      final effectiveMode = themeMode.value == ThemeMode.system 
          ? ThemeMode.light 
          : themeMode.value;
      Get.changeThemeMode(effectiveMode);
      
    } catch (e) {
      // If profile controller not found, use default
      themeMode.value = ThemeMode.light;
      Get.changeThemeMode(ThemeMode.light);
    }
  }

  // Toggle theme and save for current user
  Future<void> toggleTheme(ThemeMode mode) async {
    try {
      final ProfileController profileController = Get.find<ProfileController>();
      final currentEmail = profileController.currentUserEmail.value;
      
      if (currentEmail.isEmpty) {
        Get.snackbar('Error', 'No user logged in');
        return;
      }

      // Update theme mode
      themeMode.value = mode;
      final applied = mode == ThemeMode.system ? ThemeMode.light : mode;
      Get.changeThemeMode(applied);
      
      // Save to database
      final themeModeStr = mode.toString().split('.').last.toLowerCase();
      await _dbOps.updateUser(currentEmail, {
        'themeMode': themeModeStr,
      });
      
    } catch (e) {
      Get.snackbar('Error', 'Failed to save theme preference: ${e.toString()}');
    }
  }

  // Set theme directly (used by ProfileController)
  void setTheme(String themeModeStr) {
    switch (themeModeStr.toLowerCase()) {
      case 'light':
        toggleTheme(ThemeMode.light);
        break;
      case 'dark':
        toggleTheme(ThemeMode.dark);
        break;
      case 'system':
        toggleTheme(ThemeMode.system);
        break;
      default:
        toggleTheme(ThemeMode.light);
    }
  }

  // Reset to default theme (used on logout)
  void resetTheme() {
    themeMode.value = ThemeMode.light;
    Get.changeThemeMode(ThemeMode.light);
  }
}