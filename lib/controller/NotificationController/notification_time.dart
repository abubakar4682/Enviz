import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class LimitController extends GetxController {
  var limit = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadLimit();
  }

  Future<void> loadLimit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedLimit = prefs.getString('limit');
    if (savedLimit != null) {
      limit.value = savedLimit;
    }
  }

  Future<void> updateLimit(String newLimit) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    if (username != null) {
      var response = await http.post(
          Uri.parse('http://203.135.63.47:8000/setLimit'),
          body: {'username': username, 'limit': newLimit}
      );
      if (response.statusCode == 200) {
        await prefs.setString('limit', newLimit);
        limit.value = newLimit;
        showSnackBar('Success', 'Limit set to $newLimit kW has been updated successfully.');
      } else {
        showSnackBar('Error', 'Failed to update limit set to $newLimit kW.', isError: true);
      }
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
}
