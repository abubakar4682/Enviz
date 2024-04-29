import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:highcharts_demo/screens/login.dart';
import 'package:highcharts_demo/screens/summary.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LiveDataControllers extends GetxController {
  RxList<Map<String, dynamic>> kwData = <Map<String, dynamic>>[].obs;
  Map<String, Map<String, double>> dailyItemSumsMap = {};
  RxBool showPassword = false.obs;
  RxDouble lastMainKWValue = 0.0.obs;
  RxBool loading = false.obs;
  final usernamenameController = TextEditingController();
  final passwordController = TextEditingController();

  var username = ''.obs;
  var password = ''.obs;

  Map<String, double> nameAndSumMap = {};
  final int pakistaniTimeZoneOffset = 10;

  RxString startDate = '2024-01-07'.obs;
  RxString endDate = '2024-01-07'.obs;
  RxList<String> result = <String>['0', '0', '0'].obs; // Initialize with zeroes

  Future<void> fetchDataforlive() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUsername = prefs.getString('username');
    kwData.clear();
    final username = usernamenameController.text.toString();

    try {
      // Get current date in Pakistani time
      DateTime currentDate = DateTime.now();
      DateTime pakistaniDateTime = currentDate.toUtc().add(Duration(hours: pakistaniTimeZoneOffset));

      // Calculate starting date (last 24 hours)
      DateTime startDate = pakistaniDateTime.subtract(Duration(hours: 24));

      // Format dates for the API request
      String formattedStartDate = startDate.toIso8601String().split('T')[0];
      String formattedEndDate = pakistaniDateTime.toIso8601String().split('T')[0];

      try {
        final String apiUrl = "http://203.135.63.47:8000/data?username=$storedUsername&mode=hour&start=$formattedStartDate&end=$formattedEndDate";
        final response = await http.get(Uri.parse(apiUrl));

        if (response.statusCode == 200) {
          Map<String, dynamic> jsonData = json.decode(response.body);
          Map<String, dynamic> data = jsonData['data'];

          List<Map<String, dynamic>> newData = [];
          data.forEach((itemName, values) {
            if (itemName.endsWith("[kW]")) {
              String prefixName = getMainPart(itemName);
              List<double> numericValues = (values as List<dynamic>).map((value) {
                if (value == null || value.toString().isEmpty || value.toString().toUpperCase() == 'NA') {
                  return 0.0;
                } else if (value is num) {
                  return value.toDouble();
                } else if (value is String) {
                  return double.tryParse(value) ?? 0.0;
                } else {
                  return 0.0;
                }
              }).toList();

              // Take the mean of the last 5 values
              double meanValue = 0.0;
              int count = 0;
              for (int i = numericValues.length - 1; i >= 0 && count < 5; i--) {
                meanValue += numericValues[i];
                count++;
              }
              meanValue /= count;

              newData.add({
                'prefixName': prefixName,
                'values': numericValues,
                'lastIndexValue': meanValue,
              });
            }
          });

          kwData.add({'date': formattedEndDate, 'data': newData});
        } else {
          print('Failed to fetch data for $formattedEndDate. Status code: ${response.statusCode}');
          print('Response body: ${response.body}');
        }
      } catch (error) {
        print('Error fetching data for $formattedEndDate: $error');
      }
    } catch (error) {
      print('An unexpected error occurred: $error');
    }
  }

  String formatToKW(double value) {
    double valueInKW = value / 1000.0;
    return valueInKW.toStringAsFixed(3) + ' k';
  }

  String getMainPart(String fullName) {
    List<String> parts = fullName.split('_');
    if (parts.isNotEmpty) {
      return parts.first;
    }
    return fullName;
  }
}











// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:highcharts_demo/screens/login.dart';
// import 'package:highcharts_demo/screens/summary.dart';
// import 'package:http/http.dart' as http;
// import 'package:get/get.dart';
// import 'package:get/get_state_manager/src/simple/get_controllers.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
//
//
// class LiveDataControllers extends GetxController {
//   RxList<Map<String, dynamic>> kwData = <Map<String, dynamic>>[].obs;
//   Map<String, Map<String, double>> dailyItemSumsMap = {};
//   RxBool showPassword = false.obs;
//   RxDouble lastMainKWValue = 0.0.obs;
//   RxBool loading = false.obs;
//   final usernamenameController = TextEditingController();
//   final passwordController = TextEditingController();
//
//   var username = ''.obs;
//   var password = ''.obs;
//
//   Map<String, double> nameAndSumMap = {};
//   final int pakistaniTimeZoneOffset = 10;
//
//   RxString startDate = '2024-01-07'.obs;
//   RxString endDate = '2024-01-07'.obs;
//   RxList<String> result = <String>['0', '0', '0'].obs; // Initialize with zeroes
//
//
//
//
//
//
//   Future<void> fetchDataforlive() async  {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? storedUsername = prefs.getString('username');
//     kwData.clear();
//     final username = usernamenameController.text.toString();
//
//     try {
//       // Get current date in Pakistani time
//       DateTime currentDate = DateTime.now();
//       DateTime pakistaniDateTime = currentDate.toUtc().add(Duration(hours: pakistaniTimeZoneOffset));
//
//       // Calculate starting date (last 24 hours)
//       DateTime startDate = pakistaniDateTime.subtract(Duration(hours: 24));
//
//       // Format dates for the API request
//       String formattedStartDate = startDate.toIso8601String().split('T')[0];
//       String formattedEndDate = pakistaniDateTime.toIso8601String().split('T')[0];
//
//       try {
//         final String apiUrl =
//             "http://203.135.63.47:8000/data?username=$storedUsername&mode=hour&start=$formattedStartDate&end=$formattedEndDate";
//         final response = await http.get(Uri.parse(apiUrl));
//         print(apiUrl);
//
//         if (response.statusCode == 200) {
//           Map<String, dynamic> jsonData = json.decode(response.body);
//           Map<String, dynamic> data = jsonData['data'];
//
//           List<Map<String, dynamic>> newData = [];
//           data.forEach((itemName, values) {
//             if (itemName.endsWith("[kW]")) {
//               String prefixName = getMainPart(itemName);
//               List<double> numericValues =
//               (values as List<dynamic>).map((value) {
//                 if (value is num) {
//                   return value.toDouble();
//                 } else if (value is String) {
//                   return double.tryParse(value) ?? 0.0;
//                 } else {
//                   return 0.0;
//                 }
//               }).toList();
//
//               // Take the mean of the last 5 values
//               double meanValue = 0.0;
//               int count = 0;
//               for (int i = numericValues.length - 1; i >= 0 && count < 5; i--) {
//                 meanValue += numericValues[i];
//                 count++;
//               }
//               meanValue /= count;
//
//               newData.add({
//                 'prefixName': prefixName,
//                 'values': numericValues,
//                 'lastIndexValue': meanValue,
//               });
//             }
//           });
//
//           kwData.add({'date': formattedEndDate, 'data': newData});
//         } else {
//           print(
//               'Failed to fetch data for $formattedEndDate. Status code: ${response.statusCode}');
//           print('Response body: ${response.body}');
//         }
//       } catch (error) {
//         print('Error fetching data for $formattedEndDate: $error');
//       }
//     } catch (error) {
//       print('An unexpected error occurred: $error');
//     }
//   }
//
//
//
//   String formatToKW(double value) {
//     double valueInKW = value / 1000.0;
//     return valueInKW.toStringAsFixed(3) + ' k';
//   }
//
//
//   String getMainPart(String fullName) {
//     List<String> parts = fullName.split('_');
//     if (parts.isNotEmpty) {
//       return parts.first;
//     }
//     return fullName;
//   }
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
// }
