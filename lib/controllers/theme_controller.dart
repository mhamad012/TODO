import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taskflow/data/database/database_operations_new.dart';

class ThemeController extends GetxController {
  final Rx<ThemeMode> themeMode = ThemeMode.system.obs;
  final DatabaseOperations _dbOps = DatabaseOperations();

  @override
  void onInit() async {
    super.onInit();
    await loadThemePreference();
  }

  Future<void> loadThemePreference() async {
    final profile = await _dbOps.getProfile();
    final themeModeStr = profile['themeMode'] ?? 'system';
    
    switch (themeModeStr) {
      case 'light':
        themeMode.value = ThemeMode.light;
        break;
      case 'dark':
        themeMode.value = ThemeMode.dark;
        break;
      default:
        themeMode.value = ThemeMode.system;
    }
    
    Get.changeThemeMode(themeMode.value);
  }

  Future<void> toggleTheme(ThemeMode mode) async {
    themeMode.value = mode;
    Get.changeThemeMode(mode);
    
    final profile = await _dbOps.getProfile();
    profile['themeMode'] = mode.toString().split('.').last;
    await _dbOps.updateProfile(profile);
  }
}