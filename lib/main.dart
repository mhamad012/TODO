// main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taskflow/app/bindings/initial_bindings.dart';
import 'package:taskflow/screens/home_screen.dart';
import 'package:taskflow/screens/login_screen.dart';
import 'package:taskflow/controllers/profile_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Register initial bindings and ensure profile is loaded before building UI
  InitialBindings().dependencies();
  final profileController = Get.find<ProfileController>();
  await profileController.loadProfile();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController profileController = Get.find();

    return GetMaterialApp(
      title: 'TaskFlow',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      // initial bindings are registered in main() above
      debugShowCheckedModeBanner: false,
      home: profileController.emailController.text.isEmpty ? const LoginScreen() : const HomeScreen(),
    );
  }
}