import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taskflow/app/bindings/initial_bindings.dart';
import 'package:taskflow/screens/home_screen.dart';
import 'package:taskflow/screens/login_screen.dart';
import 'package:taskflow/controllers/profile_controller.dart';
import 'package:taskflow/controllers/theme_controller.dart';
import 'package:taskflow/controllers/task_controller.dart';
import 'package:taskflow/utils/theme.dart';
//random comment
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Register initial bindings (controllers)
  InitialBindings().dependencies();

  // Try to restore user session
  final profileController = Get.find<ProfileController>();
  final bool sessionRestored = await profileController.restoreSession();

  if (sessionRestored) {
    // User session found, load their data
    final taskController = Get.find<TaskController>();
    await taskController.loadTasks();
    
    final themeController = Get.find<ThemeController>();
    await themeController.loadThemePreference();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController profileController = Get.find<ProfileController>();
    final ThemeController themeController = Get.find<ThemeController>();
    
    return Obx(() => GetMaterialApp(
      title: 'TaskFlow',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeController.themeMode.value == ThemeMode.system
          ? ThemeMode.light
          : themeController.themeMode.value,
      debugShowCheckedModeBanner: false,
      // Check if user is logged in by checking currentUserEmail
      home: profileController.currentUserEmail.value.isEmpty 
          ? const LoginScreen() 
          : const HomeScreen(),
    ));
  }
}