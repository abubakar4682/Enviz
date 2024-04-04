import 'dart:async';
import 'dart:convert';
import 'package:highcharts_demo/screens/login.dart';

import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SummaryysControllers extends GetxController {
  RxList<Map<String, dynamic>> kwData = <Map<String, dynamic>>[].obs;
  Map<String, Map<String, double>> dailyItemSumsMap = {};
  RxDouble lastMainKWValue = 0.0.obs;
  RxBool loading = false.obs;

  RxMap<String, dynamic>? firstApiData = <String, dynamic>{}.obs;
  RxMap<String, dynamic>? secondApiData = <String, dynamic>{}.obs;
  Map<String, double> dailySumMap = {};


  // Declare dailyItemSumsMap as a public property

  Map<String, Map<String, double>> dailyItemSumsMapforMonth = {};
  Map<String, double> nameAndSumMap = {};
  final int pakistaniTimeZoneOffset = 10;

  // RxList<String> result = <String>[].obs;

  RxList<String> result = <String>['0', '0', '0'].obs;
  // for week
  Future<void> fetchData() async {
    loading.value = true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUsername = prefs.getString('username');

    Set<String> processedDates = Set();

    try {
      // Loop through the last seven days
      for (int i = 6; i >= 0; i--) {
        // Calculate the date for the current iteration
        DateTime currentDate = DateTime.now().subtract(Duration(days: i));
        DateTime pakistaniDateTime =
        currentDate.toUtc().add(Duration(hours: pakistaniTimeZoneOffset));
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

                numericValues =
                    numericValues.where((value) => value.isFinite).toList();

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
    }
    finally {
      loading.value = false; // Indicate loading end, regardless of success or failure
    }

  }
  // for month
  Future<void> fetchDataformonth() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUsername = prefs.getString('username');
    if (storedUsername == null || storedUsername.isEmpty) {
      Get.to(() => Login());
      // Handle the case where the username is not available
      print('Username is not available');
      return;
    }

    Set<String> processedDates = Set();

    try {
      // Calculate the start date as the first day of the current month
      DateTime startDate =
      DateTime(DateTime.now().year, DateTime.now().month, 1);

      // Calculate the end date as today
      DateTime endDate = DateTime.now();

      while (
      startDate.isBefore(endDate) || startDate.isAtSameMomentAs(endDate)) {
        // Calculate the date for the current iteration
        DateTime currentDate = startDate;
        DateTime pakistaniDateTime =
        currentDate.toUtc().add(Duration(hours: pakistaniTimeZoneOffset));
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

                numericValues =
                    numericValues.where((value) => value.isFinite).toList();

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


  Future<void> fetchFirstApiData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUsername = prefs.getString('username');
    final response = await http.get(Uri.parse(
        'http://203.135.63.22:8000/buildingmap?username=$storedUsername'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      firstApiData!.value = responseData;
    } else {
      throw Exception('Failed to load data from the first API');
    }
  }

  Future<void> fetchSecondApiData() async {
    DateTime currentDate = DateTime.now();
    DateTime pakistaniDateTime =
    currentDate.toUtc().add(Duration(hours: pakistaniTimeZoneOffset));
    String formattedDate = pakistaniDateTime.toString().split(' ')[0];
    DateTime endDate = DateTime.now();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUsername = prefs.getString('username');
    final String appurl="http://203.135.63.22:8000/data?username=$storedUsername&mode=hour&start=$endDate&end=$endDate";
    final response = await http.get(Uri.parse(
        appurl));
    print(appurl);

    if (response.statusCode == 200) {
      print('abubakar');
      final Map<String, dynamic> secondApiResponse = json.decode(response.body);
      final Map<String, dynamic> filteredData = {};

      secondApiResponse['data'].forEach((key, value) {
        if (value is String) {
          // Handle the case where value is a String. Decide what to do in this case.
          // For example, you might want to log an error or assign a default value.
          print('Value for $key is a String, not a List. Handling accordingly.');
        } else if (value.isEmpty) {
          filteredData[key] = List<double>.filled(24, 0.0);
        } else if (value is List) {
          // Ensure value is treated as List<dynamic> to avoid static analysis issues.
          List<dynamic> listValue = value;
          filteredData[key] = listValue.map<double>((v) => parseDouble(v)).toList();
        } else {
          // Handle any other unexpected types.
          print('Value for $key is not a List. Handling accordingly.');
        }
      });

      secondApiData!.value = filteredData;
    } else {
      throw Exception('Failed to load data from the second API');
    }
  }
  double parseDouble(dynamic value) {
    if (value == null || value == "NA") {
      return 0.0;
    }
    return double.tryParse(value.toString()) ?? 0.0;
  }

  String formatValued(double value) => (value / 1000).toStringAsFixed(2); //

  double getLastIndexValue(List<double> values) {
    // Check if the list is empty to avoid errors
    if (values.isEmpty) {
      // Return 0.0 or an appropriate default value if the list is empty
      return 0.0;
    }

    // Calculate the start index for the last 5 elements
    int start = values.length - 5 >= 0 ? values.length - 5 : 0;

    // Calculate the sum of the last 5 (or fewer) elements
    double sum = 0.0;
    for (int i = start; i < values.length; i++) {
      sum += values[i];
    }

    // Calculate the mean by dividing the sum by the number of elements considered
    double mean = sum / (values.length - start);

    return mean;
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
      value is num ||
          (value is String && double.tryParse(value) != null))
          .map((value) => value is num ? value.toDouble() : double.parse(value))
          .toList();

      if (numericValues.isNotEmpty) {
        double minValue = numericValues
            .reduce((value, element) => value < element ? value : element);
        double maxValue = numericValues
            .reduce((value, element) => value > element ? value : element);
        double averageValue =
            numericValues.reduce((a, b) => a + b) / numericValues.length;
        double totalValue = numericValues.reduce((a, b) => a + b);
        result.assignAll([
          '$minValue',
          '$maxValue',
          '$averageValue',
          'Total MainKW: $totalValue',
        ]);
      } else {
        result.assignAll([
          'No matching keys found.',
          'No matching keys found.',
          'No matching keys found.'
        ]);
      }
    } else {
      result.assignAll([
        'No matching keys found.',
        'No matching keys found.',
        'No matching keys found.'
      ]);
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
      result.assignAll([
        'No matching keys found.',
        'No matching keys found.',
        'No matching keys found.'
      ]);
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
