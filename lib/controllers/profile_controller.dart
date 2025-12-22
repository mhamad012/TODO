import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taskflow/data/database/database_operations_new.dart';

class ProfileController extends GetxController {
  final DatabaseOperations _dbOps = DatabaseOperations();
  
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final RxBool notificationEnabled = true.obs;

  @override
  void onInit() async {
    super.onInit();
    await loadProfile();
  }

  Future<void> loadProfile() async {
    final profile = await _dbOps.getProfile();
    nameController.text = profile['name'] ?? '';
    emailController.text = profile['email'] ?? '';
    final notif = profile['notificationEnabled'];
    notificationEnabled.value = (notif is int) ? (notif == 1) : (notif ?? true);
  }

  Future<void> saveProfile() async {
    final profile = {
      'name': nameController.text,
      'email': emailController.text,
      'notificationEnabled': notificationEnabled.value ? 1 : 0,
    };
    await _dbOps.updateProfile(profile);
  }

  void toggleNotifications(bool value) {
    notificationEnabled.value = value;
    saveProfile();
  }
}