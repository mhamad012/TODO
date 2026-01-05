import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskflow/data/database/database_operations_new.dart';

class ProfileController extends GetxController {
  final DatabaseOperations _dbOps = DatabaseOperations();
  
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final RxBool notificationEnabled = true.obs;
  final RxString themeMode = 'system'.obs;
  
  // Current logged-in user email
  final RxString currentUserEmail = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Don't load profile automatically - wait for login or session restore
  }

  // Load user profile by email (called after login)
  Future<void> loadUserProfile(String email) async {
    final user = await _dbOps.getUserByEmail(email);
    
    if (user != null) {
      nameController.text = user['name'] ?? '';
      emailController.text = user['email'] ?? '';
      passwordController.text = user['password'] ?? '';
      currentUserEmail.value = user['email'] ?? '';
      
      final notif = user['notificationEnabled'];
      notificationEnabled.value = (notif is int) ? (notif == 1) : (notif ?? true);
      
      themeMode.value = user['themeMode'] ?? 'system';
    }
  }

  // Save/update current user's profile
  Future<void> saveProfile() async {
    if (currentUserEmail.value.isEmpty) {
      Get.snackbar('Error', 'No user logged in');
      return;
    }

    final updates = {
      'name': nameController.text,
      'email': emailController.text,
      'password': passwordController.text,
      'notificationEnabled': notificationEnabled.value ? 1 : 0,
      'themeMode': themeMode.value,
    };
    
    await _dbOps.updateUser(currentUserEmail.value, updates);
    
    // If email changed, update session
    if (emailController.text != currentUserEmail.value) {
      currentUserEmail.value = emailController.text;
      await _saveSession(emailController.text);
    }
    
    Get.snackbar('Success', 'Profile updated successfully');
  }

  // Toggle notifications
  void toggleNotifications(bool value) {
    notificationEnabled.value = value;
    saveProfile();
  }

  // Change theme
  void setThemeMode(String mode) {
    themeMode.value = mode;
    saveProfile();
  }

  // Authentication - Login
  Future<bool> authenticate(String email, String password) async {
    bool authenticated = await _dbOps.authenticateUser(email, password);
    
    if (authenticated) {
      currentUserEmail.value = email;
      await loadUserProfile(email); // Load user data after successful login
      await _saveSession(email); // Save session for auto-login
      return true;
    }
    
    return false;
  }

  // Registration - Create new user
  Future<bool> register(String name, String email, String password) async {
    // Check if user already exists
    bool exists = await _dbOps.userExists(email);
    if (exists) {
      Get.snackbar('Error', 'User with this email already exists');
      return false;
    }

    // Create new user in database
    try {
      await _dbOps.registerUser(
        email: email,
        password: password,
        name: name,
      );
      
      // Auto-login after registration
      currentUserEmail.value = email;
      nameController.text = name;
      emailController.text = email;
      passwordController.text = password;
      
      await _saveSession(email); // Save session for auto-login
      
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to create account: ${e.toString()}');
      return false;
    }
  }

  // Logout - Clear current user
  Future<void> logout() async {
    clearControllers();
    currentUserEmail.value = '';
    await _clearSession(); // Clear saved session
    Get.snackbar('Logged Out', 'You have been logged out successfully');
  }

  // Clear all controllers
  void clearControllers() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    notificationEnabled.value = true;
    themeMode.value = 'system';
  }

  // Delete current user account
  Future<bool> deleteAccount() async {
    if (currentUserEmail.value.isEmpty) {
      Get.snackbar('Error', 'No user logged in');
      return false;
    }

    try {
      await _dbOps.deleteUser(currentUserEmail.value);
      await logout(); // This will also clear the session
      Get.snackbar('Success', 'Account deleted successfully');
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete account: ${e.toString()}');
      return false;
    }
  }

  // ==================== SESSION MANAGEMENT ====================

  // Save user session (for auto-login)
  Future<void> _saveSession(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_user_email', email);
    } catch (e) {
      // Session save failed, but don't break the flow
      debugPrint('Failed to save session: $e');
    }
  }

  // Clear user session (on logout)
  Future<void> _clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_user_email');
    } catch (e) {
      // Session clear failed, but don't break the flow
      debugPrint('Failed to clear session: $e');
    }
  }

  // Restore user session (called on app start)
  Future<bool> restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('current_user_email');
      
      if (savedEmail != null && savedEmail.isNotEmpty) {
        // Verify user still exists in database
        final user = await _dbOps.getUserByEmail(savedEmail);
        if (user != null) {
          currentUserEmail.value = savedEmail;
          await loadUserProfile(savedEmail);
          return true; // Session restored successfully
        } else {
          // User deleted, clear invalid session
          await _clearSession();
        }
      }
      
      return false; // No valid session
    } catch (e) {
      debugPrint('Failed to restore session: $e');
      return false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}