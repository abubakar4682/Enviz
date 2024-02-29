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

import '../data/exceptions/app_exceptions.dart';
import '../repository/register_view_repo.dart';
import '../widgets/bottom_navigation.dart';

class DataControllers extends GetxController {
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
  Map<String, double> dailySumMap = {};
  // Declare dailyItemSumsMap as a public property

  Map<String, Map<String, double>> dailyItemSumsMapforMonth = {};
  Map<String, double> nameAndSumMap = {};
  final int pakistaniTimeZoneOffset = 10;
 // RxList<String> result = <String>[].obs;
  RxString startDate = '2024-01-07'.obs;
  RxString endDate = '2024-01-07'.obs;
 RxList<String> result = <String>['0', '0', '0'].obs; // Initialize with zeroes
  void userRegister() {
    loading.value = true;
    final username = usernamenameController.text.toString();
    final password = passwordController.text;

    if (username.isNotEmpty && password.isNotEmpty) {
      repository.registerApi(username, password).timeout(Duration(seconds: 10)).then((value) async {
        loading.value = false;

        if (value != null && value['token'] != null) {
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
      Get.snackbar('Error', 'Username or password is empty.', backgroundColor: Colors.red.shade200, colorText: Colors.black);
    }
  }

  // void userRegister() {
  //   loading.value = true;
  //   final username = usernamenameController.text.toString();
  //   final password = passwordController.text;
  //
  //   if (username != null && password != null &&
  //       username.isNotEmpty && password.isNotEmpty) {
  //     repository.registerApi(username, password).timeout(Duration(seconds: 10)).then((value) async {
  //       loading.value = false;
  //
  //       if (value != null && value['token'] != null) {
  //         handleSuccessfulRegistration(value);
  //       } else if (value != null && value['error'] != null) {
  //         handleRegistrationError(value['error']);
  //       } else {
  //         handleUnexpectedResponse();
  //       }
  //     }).catchError((error, stackTrace) {
  //       handleError(error);
  //     });
  //   } else {
  //     loading.value = false;
  //     Get.snackbar('Error', 'Username or password is empty or null.',backgroundColor: Colors.red.shade200,colorText: Colors.black, );
  //   }
  // }

  Future<void> fetchDataforhistorical() async {
    final username = usernamenameController.text.toString();
    String appUrl =
        'http://203.135.63.22:8000/data?username=ppjiq&mode=hour&start=${startDate.value}&end=${endDate.value}';
    print(appUrl);
    final response = await http.get(Uri.parse(appUrl));

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = json.decode(response.body);
      processData(jsonData['data']);
    } else {
      print('Failed to load data');
      result.assignAll(['No matching keys found.', 'No matching keys found.', 'No matching keys found.']);
    }
  }

  void processData(Map<String, dynamic> jsonData) {
    if (jsonData.containsKey("Main_[kW]")) {
      showMainKwValues(jsonData["Main_[kW]"]);
    } else {
      showOtherKwValues(jsonData);
    }
  }

  void showMainKwValues(List<dynamic> mainKwValues) {
    if (mainKwValues is List && mainKwValues.isNotEmpty) {
      List<double> numericValues = mainKwValues
          .where((value) =>
      value is num || (value is String && double.tryParse(value) != null))
          .map((value) => value is num ? value.toDouble() : double.parse(value))
          .toList();

      if (numericValues.isNotEmpty) {
        double minValue = numericValues.reduce((value, element) => value < element ? value : element);
        double maxValue = numericValues.reduce((value, element) => value > element ? value : element);
        double averageValue = numericValues.reduce((a, b) => a + b) / numericValues.length;
        double totalValue = numericValues.reduce((a, b) => a + b);
        result.assignAll([
          '$minValue',
          '$maxValue',
          '$averageValue',
          'Total MainKW: $totalValue',
        ]);
      } else {
        result.assignAll(['No matching keys found.', 'No matching keys found.', 'No matching keys found.']);
      }
    } else {
      result.assignAll(['No matching keys found.', 'No matching keys found.', 'No matching keys found.']);
    }
  }

  void showOtherKwValues(Map<String, dynamic> jsonData) {
    Map<String, double> sumValuesMap = {};

    jsonData.forEach((key, value) {
      if (key.endsWith("[kW]") && value is List) {
        double sum = 0;

        for (var item in value) {
          if (item is num) {
            sum += item.toDouble();
          }
        }

        sumValuesMap[key] = sum;
      }
    });

    if (sumValuesMap.isNotEmpty) {
      result.assignAll(sumValuesMap.entries
          .map((entry) => '${entry.key}: Sum = ${entry.value}')
          .toList());
    } else {
      result.assignAll(['No matching keys found.', 'No matching keys found.', 'No matching keys found.']);
    }
  }

  Future<void> selectStartDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2025),
    );
    if (picked != null) startDate(picked.toLocal().toString().split(' ')[0]);
  }

  Future<void> selectEndDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2025),
    );
    if (picked != null) {
      endDate(picked.toLocal().toString().split(' ')[0]);
      await fetchDataforhistorical();
    }
  }
  // Future<void> fetchDataforhistorical() async {
  //   String appUrl='http://203.135.63.22:8000/data?username=ppjiq&mode=hour&start=${startDate.value}&end=${endDate.value}';
  //   print(appUrl);
  //   final response = await http.get(Uri.parse(appUrl
  //       ));
  //
  //   if (response.statusCode == 200) {
  //     Map<String, dynamic> jsonData = json.decode(response.body);
  //     processData(jsonData['data']);
  //   } else {
  //     print('Failed to load data');
  //   }
  // }
  //
  // void processData(Map<String, dynamic> jsonData) {
  //   if (jsonData.containsKey("Main_[kW]")) {
  //     showMainKwValues(jsonData["Main_[kW]"]);
  //   } else {
  //     showOtherKwValues(jsonData);
  //   }
  // }
  //
  // void showMainKwValues(List<dynamic> mainKwValues) {
  //   List<String> computedResultList = []; // Replace with your processing logic
  //
  //   updateResult(computedResultList);
  // }
  //
  // void showOtherKwValues(Map<String, dynamic> jsonData) {
  //   Map<String, double> sumValuesMap = {};
  //
  //   jsonData.forEach((key, value) {
  //     if (key.endsWith("[kW]") && value is List) {
  //       double sum = 0;
  //
  //       for (var item in value) {
  //         if (item is num) {
  //           sum += item.toDouble();
  //         }
  //       }
  //
  //       sumValuesMap[key] = sum;
  //     }
  //   });
  //
  //   if (sumValuesMap.isNotEmpty) {
  //     updateResult(
  //       sumValuesMap.entries.map((entry) => '${entry.key}: Sum = ${entry.value}').toList(),
  //     );
  //   } else {
  //     updateResult(['No matching keys found.']);
  //   }
  // }
  //
  // void updateResult(List<String> updatedResult) {
  //   result.assignAll(updatedResult);
  // }
  //
  // Future<void> selectStartDate(BuildContext context) async {
  //   DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: DateTime.now(),
  //     firstDate: DateTime(2024),
  //     lastDate: DateTime(2025),
  //   );
  //   if (picked != null) {
  //     startDate.value = picked.toLocal().toString().split(' ')[0];
  //     update(); // Trigger UI update
  //
  //     // Fetch data with the updated date
  //
  //   }
  // }
  //
  // Future<void> selectEndDate(BuildContext context) async {
  //   DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: DateTime.now(),
  //     firstDate: DateTime(2023),
  //     lastDate: DateTime(2025),
  //   );
  //   if (picked != null) {
  //     endDate.value = picked.toLocal().toString().split(' ')[0];
  //
  //     // Fetch data with the updated date
  //     await fetchDataforhistorical();
  //
  //     update(); // Trigger UI update
  //   }
  // }


  Future<void> fetchDataformonth() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUsername = prefs.getString('username');
    final username = usernamenameController.text.toString();
    if (storedUsername == null || storedUsername.isEmpty) {
      Get.to(() => Login());
      // Handle the case where the username is not available
      print('Username is not available');
      return;
    }

    Set<String> processedDates = Set();

    try {
      // Calculate the start date as the first day of the current month
      DateTime startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);

      // Calculate the end date as today
      DateTime endDate = DateTime.now();

      while (startDate.isBefore(endDate) || startDate.isAtSameMomentAs(endDate)) {
        // Calculate the date for the current iteration
        DateTime currentDate = startDate;
        DateTime pakistaniDateTime = currentDate.toUtc().add(Duration(hours: pakistaniTimeZoneOffset));
        String formattedDate = pakistaniDateTime.toString().split(' ')[0];

        // Skip fetching if the date has already been processed
        if (processedDates.contains(formattedDate)) {
          continue;
        }

        try {
          // Make an HTTP GET request
          final String apiUrl =
              "http://203.135.63.22:8000/data?username=$storedUsername&mode=hour&start=$formattedDate&end=$formattedDate";
          final response = await http.get(Uri.parse(apiUrl));
          print(apiUrl);

          // Check if the request was successful (status code 200)
          if (response.statusCode == 200) {
            // Parse the JSON response
            Map<String, dynamic> jsonData = json.decode(response.body);
            Map<String, dynamic> data = jsonData['data'];

            // Parse and process data logic
            Map<String, double> itemSums = {};
            data.forEach((itemName, values) {
              if (itemName.endsWith("[kW]")) {
                String prefixName = itemName.substring(0, itemName.length - 4);
                List<double> numericValues = (values as List<dynamic>).map((value) {
                  if (value is num) {
                    return value.toDouble();
                  } else if (value is String) {
                    return double.tryParse(value) ?? 0.0;
                  } else {
                    return 0.0;
                  }
                }).toList();

                numericValues = numericValues.where((value) => value.isFinite).toList();

                nameAndSumMap.update(prefixName, (existingSum) {
                  return existingSum + numericValues.reduce((a, b) => a + b);
                }, ifAbsent: () => numericValues.reduce((a, b) => a + b));

                dailySumMap.update(formattedDate, (existingSum) {
                  return existingSum + numericValues.reduce((a, b) => a + b);
                }, ifAbsent: () => numericValues.reduce((a, b) => a + b));

                itemSums[prefixName] = numericValues.reduce((a, b) => a + b);
              }
            });

            // Extract and process relevant data
            List<Map<String, dynamic>> newData = [];

            dailyItemSumsMapforMonth[formattedDate] = itemSums;
            processedDates.add(formattedDate);
            data.forEach((itemName, values) {
              if (itemName.endsWith("[kW]")) {
                String prefixName = itemName.substring(0, itemName.length - 4);
                List<double> numericValues =
                (values as List<dynamic>).map((value) {
                  if (value is num) {
                    return value.toDouble();
                  } else if (value is String) {
                    return double.tryParse(value) ?? 0.0;
                  } else {
                    return 0.0;
                  }
                }).toList();

                newData.add({
                  'prefixName': prefixName,
                  'values': numericValues,
                });
              }
            });

            // Update kwData with the new data
            kwData.add({'date': formattedDate, 'data': newData});

            // Update lastMainKWValue with the last value of "Main_[kW]"
            lastMainKWValue.value = newData
                .where((item) => item['prefixName'] == 'Main_')
                .map((item) => item['values'].last)
                .first;

            // Mark the date as processed to avoid duplicates
            processedDates.add(formattedDate);
          } else {
            // Handle unsuccessful response
            print(
                'Failed to fetch data for abubakar $formattedDate. Status code: ${response.statusCode}');
            print('Response body: ${response.body}');
          }
        } catch (error) {
          // Handle HTTP request error
          print('Error fetching data for $formattedDate: $error');
        }

        // Move to the next day
        startDate = startDate.add(Duration(days: 1));
      }
    } catch (error) {
      // Handle general error
      print('An unexpected error occurred: $error');
    }
  }



  Future<void> fetchDataforlive() async  {
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
        final String apiUrl =
            "http://203.135.63.22:8000/data?username=$storedUsername&mode=hour&start=$formattedStartDate&end=$formattedEndDate";
        final response = await http.get(Uri.parse(apiUrl));
        print(apiUrl);

        if (response.statusCode == 200) {
          Map<String, dynamic> jsonData = json.decode(response.body);
          Map<String, dynamic> data = jsonData['data'];

          List<Map<String, dynamic>> newData = [];
          data.forEach((itemName, values) {
            if (itemName.endsWith("[kW]")) {
              String prefixName = getMainPart(itemName);
              List<double> numericValues =
              (values as List<dynamic>).map((value) {
                if (value is num) {
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
          print(
              'Failed to fetch data for $formattedEndDate. Status code: ${response.statusCode}');
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


  Future<void> fetchData() async {
    final username = usernamenameController.text.toString();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUsername = prefs.getString('username');

    Set<String> processedDates = Set();

    try {
      // Loop through the last seven days
      for (int i = 6; i >= 0; i--) {
        // Calculate the date for the current iteration
        DateTime currentDate = DateTime.now().subtract(Duration(days: i));
        DateTime pakistaniDateTime = currentDate.toUtc().add(Duration(hours: pakistaniTimeZoneOffset));
        String formattedDate = pakistaniDateTime.toString().split(' ')[0];
        // Skip fetching if the date has already been processed
        if (processedDates.contains(formattedDate)) {
          continue;
        }

        try {
          // Make an HTTP GET request
          final String apiUrl =
              "http://203.135.63.22:8000/data?username=$storedUsername&mode=hour&start=$formattedDate&end=$formattedDate";
          final response = await http.get(
            Uri.parse(apiUrl),
          );
          print(apiUrl);
          // final response = await http.get(Uri.parse(apiUrl));

          // Check if the request was successful (status code 200)
          if (response.statusCode == 200) {
            // Parse the JSON response
            Map<String, dynamic> jsonData = json.decode(response.body);
            Map<String, dynamic> data = jsonData['data'];
            //  Map<String, dynamic> jsonData = json.decode(response.body);
            Map<String, double> itemSums = {};
            data.forEach((itemName, values) {
              if (itemName.endsWith("[kW]")) {
                String prefixName = itemName.substring(0, itemName.length - 4);
                List<double> numericValues = (values as List<dynamic>).map((value) {
                  if (value is num) {
                    return value.toDouble();
                  } else if (value is String) {
                    return double.tryParse(value) ?? 0.0;
                  } else {
                    return 0.0;
                  }
                }).toList();

                numericValues = numericValues.where((value) => value.isFinite).toList();

                nameAndSumMap.update(prefixName, (existingSum) {
                  return existingSum + numericValues.reduce((a, b) => a + b);
                }, ifAbsent: () => numericValues.reduce((a, b) => a + b));

                dailySumMap.update(formattedDate, (existingSum) {
                  return existingSum + numericValues.reduce((a, b) => a + b);
                }, ifAbsent: () => numericValues.reduce((a, b) => a + b));

                itemSums[prefixName] = numericValues.reduce((a, b) => a + b);
              }
            });

            // Extract and process relevant data
            List<Map<String, dynamic>> newData = [];

            dailyItemSumsMap[formattedDate] = itemSums;
            processedDates.add(formattedDate);
            data.forEach((itemName, values) {
              if (itemName.endsWith("[kW]")) {
                String prefixName = itemName.substring(0, itemName.length - 4);
                List<double> numericValues =
                (values as List<dynamic>).map((value) {
                  if (value is num) {
                    return value.toDouble();
                  } else if (value is String) {
                    return double.tryParse(value) ?? 0.0;
                  } else {
                    return 0.0;
                  }
                }).toList();

                newData.add({
                  'prefixName': prefixName,
                  'values': numericValues,
                });
              }
            });
            // Update kwData with the new data
            kwData.add({'date': formattedDate, 'data': newData});

            // Update lastMainKWValue with the last value of "Main_[kW]"
            lastMainKWValue.value = newData
                .where((item) => item['prefixName'] == 'Main_')
                .map((item) => item['values'].last)
                .first;

            // Mark the date as processed to avoid duplicates
            processedDates.add(formattedDate);
          } else {
            // Handle unsuccessful response
            print(
                'Failed to fetch data for abubakar $formattedDate. Status code: ${response.statusCode}');
            print('Response body: ${response.body}');
          }
        } catch (error) {
          // Handle HTTP request error
          print('Error fetching data for $formattedDate: $error');
        }
      }
    } catch (error) {
      // Handle general error
      print('An unexpected error occurred: $error');
    }
  }



  // Future<void> fetchDataformonth() async {
  //   final username = usernamenameController.text.toString();
  //
  //   Set<String> processedDates = Set();
  //
  //   try {
  //     // Get the first day of the current month
  //     DateTime firstDayOfMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  //
  //     // Get the current date
  //     DateTime currentDate = DateTime.now();
  //
  //     // Loop through the days of the current month
  //     for (DateTime date = firstDayOfMonth; date.isBefore(currentDate); date = date.add(Duration(days: 1))) {
  //       String formattedDate = date.toLocal().toString().split(' ')[0];
  //
  //       // Skip fetching if the date has already been processed
  //       if (processedDates.contains(formattedDate)) {
  //         continue;
  //       }
  //
  //       try {
  //         // Make an HTTP GET request
  //         final String apiUrl =
  //             "http://203.135.63.22:8000/data?username=$username&mode=hour&start=$formattedDate&end=$formattedDate";
  //         final response = await http.get(
  //           Uri.parse(apiUrl),
  //         );
  //         print(apiUrl);
  //         // final response = await http.get(Uri.parse(apiUrl));
  //
  //         // Check if the request was successful (status code 200)
  //         if (response.statusCode == 200) {
  //           // Parse the JSON response
  //           Map<String, dynamic> jsonData = json.decode(response.body);
  //           Map<String, dynamic> data = jsonData['data'];
  //
  //           // Extract and process relevant data
  //           List<Map<String, dynamic>> newData = [];
  //
  //           data.forEach((itemName, values) {
  //             if (itemName.endsWith("[kW]")) {
  //               String prefixName = itemName.substring(0, itemName.length - 4);
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
  //               newData.add({
  //                 'prefixName': prefixName,
  //                 'values': numericValues,
  //               });
  //             }
  //           });
  //           // Update kwData with the new data
  //           kwData.add({'date': formattedDate, 'data': newData});
  //
  //           // Update lastMainKWValue with the last value of "Main_[kW]"
  //           lastMainKWValue.value = newData
  //               .where((item) => item['prefixName'] == 'Main_')
  //               .map((item) => item['values'].last)
  //               .first;
  //
  //           // Mark the date as processed to avoid duplicates
  //           processedDates.add(formattedDate);
  //         } else {
  //           // Handle unsuccessful response
  //           print(
  //               'Failed to fetch data for $formattedDate. Status code: ${response.statusCode}');
  //           print('Response body: ${response.body}');
  //         }
  //       } catch (error) {
  //         // Handle HTTP request error
  //         print('Error fetching data for $formattedDate: $error');
  //       }
  //     }
  //   } catch (error) {
  //     // Handle general error
  //     print('An unexpected error occurred: $error');
  //   }
  // }


  /// live data
  Future<void> livedata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUsername = prefs.getString('username');
    final username = usernamenameController.text.toString();
   // Replace with your username

    try {
      // Get the current date
      DateTime currentDate = DateTime.now();
      DateTime pakistaniDateTime =
      currentDate.toUtc().add(Duration(hours: pakistaniTimeZoneOffset));
      String formattedDate = pakistaniDateTime.toString().split(' ')[0];

      try {
        // Make an HTTP GET request for today's data
        final String apiUrl =
            "http://203.135.63.22:8000/data?username=$storedUsername&mode=hour&start=2024-01-22&end=2024-01-22";
        final response = await http.get(
          Uri.parse(apiUrl),
        );

        // Check if the request was successful (status code 200)
        if (response.statusCode == 200) {
          // Parse the JSON response
          Map<String, dynamic> jsonData = json.decode(response.body);
          Map<String, dynamic> data = jsonData['data'];

          List<Map<String, dynamic>> newData = [];
          data.forEach((itemName, values) {
            if (itemName.endsWith("[kW]")) {
              String prefixName = itemName.substring(0, itemName.length - 4);
              List<double> numericValues = (values as List<dynamic>).map((value) {
                if (value is num) {
                  return value.toDouble();
                } else if (value is String) {
                  return double.tryParse(value) ?? 0.0;
                } else {
                  return 0.0;
                }
              }).toList();

              // Add the last index value for each key
              double lastIndexValue = numericValues.isNotEmpty
                  ? numericValues.last
                  : 0.0;

              newData.add({
                'prefixName': prefixName,
                'values': numericValues,
                'lastIndexValue': lastIndexValue,
              });
            }
          });

          // Update the state using the RxList
          kwData.add({'date': formattedDate, 'data': newData});

        } else {
          // Handle unsuccessful response
          print('Failed to fetch data for $formattedDate. Status code: ${response.statusCode}');
          print('Response body: ${response.body}');
        }
      } catch (error) {
        // Handle HTTP request error
        print('Error fetching data for $formattedDate: $error');
      }
    } catch (error) {
      // Handle general error
      print('An unexpected error occurred: $error');
    }
  }











  // void userRegister() {
  //   loading.value = true;
  //   final username = usernamenameController.text.toString();
  //   final password = passwordController.text;
  //
  //   if (username != null && password != null &&
  //       username.isNotEmpty && password.isNotEmpty) {
  //     repository.registerApi(username, password).timeout(Duration(seconds: 10)).then((value) async {
  //       loading.value = false;
  //
  //       if (value != null && value['token'] != null) {
  //         handleSuccessfulRegistration(value);
  //       } else if (value != null && value['error'] != null) {
  //         handleRegistrationError(value['error']);
  //       } else {
  //         handleUnexpectedResponse();
  //       }
  //     }).catchError((error, stackTrace) {
  //       handleError(error);
  //     });
  //   } else {
  //     loading.value = false;
  //     Get.snackbar('Error', 'Username or password is empty or null.',backgroundColor: Colors.red.shade200,colorText: Colors.black, );
  //   }
  // }
  void handleSuccessfulRegistration(Map<String, dynamic> value) async {
    Get.snackbar('Login Successfully', '',
      backgroundColor: Colors.blueGrey, colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
    String token = value['token'];
    String displayName = value['client']['displayName'];
    String username = usernamenameController.text.toString(); // Get username from controller

    print({
      'username': username,
      'password': password,
      'token': token,
      'displayName': displayName,
    });

    // Save username to local storage
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('username', username);

    fetchData();
    fetchDataforlive();

    Get.to(() => BottomPage());
  }
  // void handleSuccessfulRegistration(Map<String, dynamic> value) {
  //   Get.snackbar('Registration', 'Login Successfully',  backgroundColor: Colors.blueGrey,colorText: Colors.white,
  //     snackPosition: SnackPosition.TOP,
  //   );
  //   String token = value['token'];
  //   String displayName = value['client']['displayName'];
  //
  //   print({
  //     'username': username,
  //     'password': password,
  //     'token': token,
  //     'displayName': displayName,
  //   });
  //
  //   fetchData();
  //   fetchDataforlive();
  //
  //   Get.to(() => BottomPage());
  // }

  void handleRegistrationError(String errorMessage) {
    Get.snackbar('Registration Error', errorMessage,backgroundColor: Colors.red.shade200,colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void handleUnexpectedResponse() {
    Get.snackbar('Registration Error', 'Unexpected response from the server',backgroundColor: Colors.red.shade200,colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void handleError(dynamic error) {
    loading.value = false;

    if (error is TimeoutException) {
      Get.snackbar('Error', 'Request timed out. Please try again.',backgroundColor: Colors.red.shade200,colorText: Colors.white, );
    } else if (error is AppExceptions) {
      Get.snackbar('Error', error.message ?? '');
      print(error.message);
    } else {
      Get.snackbar('Error', 'Unexpected error occurred. Please try again.');
      print('Unexpected error: $error');
    }
  }


}
