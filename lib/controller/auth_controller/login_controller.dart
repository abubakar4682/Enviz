import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Notifications/notification_services.dart';
import '../../data/exceptions/app_exceptions.dart';
import '../../repository/register_view_repo.dart';
import '../../widgets/bottom_navigation.dart';


class LoginControllers extends GetxController {

  NotificationServices notificationServices = NotificationServices();
  RxList<Map<String, dynamic>> kwData = <Map<String, dynamic>>[].obs;
  Map<String, Map<String, double>> dailyItemSumsMap = {};
  RxBool showPassword = false.obs;
  RxDouble lastMainKWValue = 0.0.obs;
  RxBool loading = false.obs;
  final usernamenameController = TextEditingController();
  final passwordController = TextEditingController();
  final repository = RegisterRepository();
  var username = ''.obs;
  var password = ''.obs;
  RxMap<String, dynamic>? firstApiData = <String, dynamic>{}.obs;
  RxMap<String, dynamic>? secondApiData = <String, dynamic>{}.obs;
  Map<String, double> dailySumMap = {};
  void resetloginController() {
    kwData.clear();
    dailyItemSumsMap.clear();
    showPassword(false); // Reset to default value
    lastMainKWValue(0.0); // Reset to default value
    loading(false); // Assuming you want to reset this as well
    usernamenameController.clear();
    passwordController.clear();
    username(''); // Reset to empty string
    password(''); // Reset to empty string
    dailySumMap.clear();

    // Reset any other fields or observables as needed
  }

  void userRegister() {
    loading.value = true;
    final username = usernamenameController.text.toString();
    final password = passwordController.text;

    if (username.isNotEmpty && password.isNotEmpty) {
      repository
          .registerApi(username, password)
          .timeout(Duration(seconds: 10))
          .then((value) async {
        loading.value = false;

        if (value != null && value['token'] != null) {
          String deviceToken = await notificationServices.getDeviceToken();
          print('abubakar');
          print(deviceToken);
          await sendDeviceToken(username, deviceToken);
          handleSuccessfulRegistration(value);
        } else if (value != null && value['error'] != null) {
          handleRegistrationError(value['error']);
        } else {
          handleUnexpectedResponse();
        }
      }).catchError((error, stackTrace) {
        handleError(error);
      });
    } else {
      loading.value = false;
      Get.snackbar('Error', 'Username or password is empty.',
          backgroundColor: Colors.red.shade200, colorText: Colors.black);
    }
  }
  Future<void> sendDeviceToken(String username, String deviceToken) async {
    try {
      var url = Uri.parse('http://203.135.63.47:8000/setDeviceToken');
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',  // Set content type to JSON
        },
        body: json.encode({
          'username': username,
          'token': deviceToken,
        }),
      );
      if (response.statusCode == 200) {
        print("Device token successfully sent to the server.");
      } else {
        print("Failed to send device token: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      print("An error occurred while sending the device token: $e");
    }
  }
  void handleSuccessfulRegistration(Map<String, dynamic> value) async {
    Get.snackbar(
      'Login Successfully',
      '',
      backgroundColor: Color(0xff009F8D),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
    String token = value['token'];
    String displayName = value['client']['displayName'];
    String email = value['client']['email']; // Extract email from response
    String username =
    usernamenameController.text.toString(); // Get username from controller

    // Debug print
    print({
      'username': username,
      'password': passwordController.text,
      // Assuming you have this variable for password
      'token': token,
      'displayName': displayName,
      'email': email,
      // Include email in debug print
    });

    // Save username, displayName, and email to local storage
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('username', username);
    prefs.setString('displayName', displayName); // Save displayName
    prefs.setString('email', email); // Save email



    Get.to(() => BottomPage());
  }
  void handleRegistrationError(String errorMessage) {
    Get.snackbar(
      'Registration Error',
      errorMessage,
      backgroundColor: Colors.red.shade200,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  void handleUnexpectedResponse() {
    Get.snackbar(
      'Registration Error',
      'Unexpected response from the server',
      backgroundColor: Colors.red.shade200,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void handleError(dynamic error) {
    loading.value = false;

    if (error is TimeoutException) {
      Get.snackbar(
        'Error',
        'Request timed out. Please try again.',
        backgroundColor: Colors.red.shade200,
        colorText: Colors.white,
      );
    } else if (error is AppExceptions) {
      Get.snackbar('Error', error.message ?? '');
      print(error.message);
    } else {
      Get.snackbar('Error', 'Unexpected error occurred. Please try again.');
      print('Unexpected error: $error');
    }
  }

}