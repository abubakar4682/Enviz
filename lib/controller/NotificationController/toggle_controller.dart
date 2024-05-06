import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationController extends GetxController {
  var notificationsEnabled = false.obs;
  var selectedHour = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadSavedState();
    loadSavedHourState();
  }

  Future<void> loadSavedState() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      bool? savedValue = prefs.getBool('notificationsEnabled');
      if (savedValue != null) {
        notificationsEnabled.value = savedValue;
      } else {
        print('No saved notification state found, defaulting to disabled.');
      }
    } catch (e) {
      showSnackBar('Error', 'Failed to load saved settings.', isError: true);
    }
  }

  void toggleNotifications(bool value) async {
    notificationsEnabled.value = value;
    String? username = await getUsername();
    if (username != null) {
      if (await saveState(value)) {
        await postNotificationStatus(value, username);
      } else {
        notificationsEnabled.value = !value;  // Revert value on failure to save
        showSnackBar('Error', 'Failed to save settings locally.', isError: true);
      }
    } else {
      showSnackBar('Error', 'Username not found in SharedPreferences', isError: true);
    }
  }

  Future<bool> saveState(bool value) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notificationsEnabled', value);
      return true;
    } catch (e) {
      print('Failed to save state: $e');
      return false;
    }
  }

  Future<String?> getUsername() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString('username');
    } catch (e) {
      print('Error fetching username: $e');
      return null;
    }
  }

  Future<void> postNotificationStatus(bool status, String username) async {
    try {
      String notifStatus = status ? 'T' : 'F';
      var response = await http.post(
        Uri.parse('http://203.135.63.47:8000/setNotif?username=$username&notif=$notifStatus'),
      );
      if (response.statusCode == 200) {
        showSnackBar('Success', 'Notifications ${status ? "enabled" : "disabled"} successfully.', isError: false);
      } else {
        notificationsEnabled.value = !status; // Revert in case of failure
        showSnackBar('Error', 'Failed to update notifications.', isError: true);
      }
    } catch (e) {
      notificationsEnabled.value = !status; // Revert in case of exception
      showSnackBar('Error', 'Exception occurred: $e', isError: true);
    }
  }

  // Method to reset notification settings on logout
  Future<void> resetNotificationsOnLogout() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('notificationsEnabled');
      notificationsEnabled.value = false;
      showSnackBar('Notice', 'Notification settings reset.', isError: false);
    } catch (e) {
      showSnackBar('Error', 'Failed to reset settings on logout.', isError: true);
    }
  }

  void showSnackBar(String title, String message, {bool isError = false}) {
    Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: isError ? Colors.redAccent : Color(0xff009F8D),
        colorText: Colors.white,
        icon: Icon(isError ? Icons.error : Icons.check, color: Colors.white),
        duration: const Duration(seconds: 3)
    );
  }








  void updateHour(String hour) async {
    selectedHour.value = hour;
    String? username = await getUsername();
    if (username != null) {
      if (await saveHourState(hour)) {
        await postNotificationHour(username, hour);
      } else {
        selectedHour.value = '';  // Revert hour on failure to save
        showSnackBar('Error', 'Failed to save hour locally.', isError: true);
      }
    } else {
      showSnackBar('Error', 'Username not found in SharedPreferences', isError: true);
    }
  }

  Future<bool> saveHourState(String hour) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('selectedHour', hour);
      return true;
    } catch (e) {
      print('Failed to save hour state: $e');
      return false;
    }
  }

  Future<void> postNotificationHour(String username, String hour) async {
    try {
      var response = await http.post(
        Uri.parse('http://203.135.63.47:8000/setHour?username=$username&hour=$hour'),
      );
      if (response.statusCode == 200) {
        showSnackBar('Success', 'Notification hour set to $hour successfully.', isError: false);
      } else {
        showSnackBar('Error', 'Failed to set notification hour.', isError: true);
      }
    } catch (e) {
      showSnackBar('Error', 'Exception occurred: $e', isError: true);
    }
  }

  Future<void> loadSavedHourState() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? savedHour = prefs.getString('selectedHour');
      if (savedHour != null) {
        selectedHour.value = savedHour;
      } else {
        print('No saved notification hour found.');
      }
    } catch (e) {
      showSnackBar('Error', 'Failed to load saved hour.', isError: true);
    }
  }}
