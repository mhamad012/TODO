// app/bindings/initial_bindings.dart
import 'package:get/get.dart';
import 'package:taskflow/controllers/task_controller.dart';
import 'package:taskflow/controllers/theme_controller.dart';
import 'package:taskflow/controllers/profile_controller.dart';
import 'package:taskflow/data/database/database_helper.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DatabaseHelper(), fenix: true);
    Get.lazyPut(() => TaskController(), fenix: true);
    Get.lazyPut(() => ThemeController(), fenix: true);
    Get.lazyPut(() => ProfileController(), fenix: true);
  }
}