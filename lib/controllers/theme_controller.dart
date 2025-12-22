import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taskflow/data/database/database_operations_new.dart';

class ThemeController extends GetxController {
  final Rx<ThemeMode> themeMode = ThemeMode.light.obs;
  final DatabaseOperations _dbOps = DatabaseOperations();

  @override
  void onInit() async {
    super.onInit();
    await loadThemePreference();
  }

  Future<void> loadThemePreference() async {
    final profile = await _dbOps.getProfile();
    final themeModeStr = profile['themeMode'];
    if (themeModeStr == null) {
      // default to light when no preference is saved
      themeMode.value = ThemeMode.light;
    } else {
      switch (themeModeStr) {
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
    }
    // Apply an effective mode: treat `system` as light by default
    final effectiveMode = themeMode.value == ThemeMode.system ? ThemeMode.light : themeMode.value;
    Get.changeThemeMode(effectiveMode);
  }

  Future<void> toggleTheme(ThemeMode mode) async {
    // Save the user's selection (including 'system') but apply light when 'system' is chosen
    themeMode.value = mode;
    final applied = mode == ThemeMode.system ? ThemeMode.light : mode;
    Get.changeThemeMode(applied);
    
    final profile = await _dbOps.getProfile();
    profile['themeMode'] = mode.toString().split('.').last;
    await _dbOps.updateProfile(profile);
  }
}