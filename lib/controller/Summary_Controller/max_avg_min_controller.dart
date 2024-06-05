import 'dart:async';
import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:highcharts_demo/screens/login.dart';

import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../database/current_value_helper_db.dart';

class MinMaxAvgValueControllers extends GetxController {
  RxList<Map<String, dynamic>> kwData = <Map<String, dynamic>>[].obs;
  Map<String, Map<String, double>> dailyItemSumsMap = {};
  RxDouble lastMainKWValue = 0.0.obs;
  RxBool loading = false.obs;
  RxString errorMessage = ''.obs;
  RxMap<String, dynamic>? firstApiData = <String, dynamic>{}.obs;
  RxMap<String, dynamic>? secondApiData = <String, dynamic>{}.obs;
  Map<String, double> dailySumMap = {};

  // Declare dailyItemSumsMap as a public property

  Map<String, Map<String, double>> dailyItemSumsMapforMonth = {};
  Map<String, double> nameAndSumMap = {};
  final int pakistaniTimeZoneOffset = 10;
  final DatabaseHelper _dbHelper = DatabaseHelper();
  // RxList<String> result = <String>[].obs;

  RxList<String> result = <String>['0', '0', '0'].obs;
  Future<void> fetchData() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      print('No internet connection. Loading data from local DB.');
      await _loadDataFromLocalDb();
      errorMessage.value = "No internet connection available.";
    } else {
      print('Internet connection available. Fetching data from API.');
      await fetchFirstApiData();
      await fetchSecondApiData();
    }
  }
  Future<void> fetchFirstApiData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUsername = prefs.getString('username');
    final response = await http.get(Uri.parse('http://203.135.63.47:8000/buildingmap?username=$storedUsername'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      firstApiData!.value = responseData;

      // Extract keys dynamically and store them for later use
      List<String> floorKeys = responseData.keys.map((key) => '$key\_[kW]').toList();
      result.value = floorKeys;

      // Store data in local DB
      await _dbHelper.insertFirstApiData(json.encode(responseData));
      print('First API data fetched and stored locally.');
    } else {
      errorMessage.value = 'Failed to load data from the first API';
      firstApiData!.value = {};
      print('Error fetching first API data: ${response.statusCode}');
    }
  }
  // before local db changes
  // Future<void> fetchFirstApiData() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? storedUsername = prefs.getString('username');
  //   final response = await http.get(Uri.parse(
  //       'http://203.135.63.47:8000/buildingmap?username=$storedUsername'));
  //
  //   if (response.statusCode == 200) {
  //     final Map<String, dynamic> responseData = json.decode(response.body);
  //     firstApiData!.value = responseData;
  //
  //     // Extract keys dynamically and store them for later use
  //     List<String> floorKeys =
  //         responseData.keys.map((key) => '$key\_[kW]').toList();
  //     result.value =
  //         floorKeys; // Assuming `result` is an RxList<String> for storing the keys
  //   } else {
  //     throw Exception('Failed to load data from the first API');
  //     firstApiData!.value = {};
  //   }
  // }
  Future<void> fetchSecondApiData() async {
    try {
      DateTime currentDate = DateTime.now();
      DateTime pakistaniDateTime = currentDate.toUtc().add(Duration(hours: 5));
      String formattedDate = pakistaniDateTime.toLocal().toString().split(' ')[0];
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? storedUsername = prefs.getString('username');
      final String appurl = "http://203.135.63.47:8000/data?username=$storedUsername&mode=hour&start=$formattedDate&end=$formattedDate";

      final response = await http.get(Uri.parse(appurl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> secondApiResponse = json.decode(response.body);
        final Map<String, dynamic> filteredData = {};
        int currentHour = DateTime.now().hour;

        if (secondApiResponse.containsKey('data') && secondApiResponse['data'] is Map) {
          secondApiResponse['data'].forEach((key, value) {
            if (value is List) {
              List<dynamic> hourValues = value;
              List<double> parsedValues = hourValues.take(currentHour + 1)
                  .map((v) => double.tryParse(v.toString()) ?? 0.0).toList();
              filteredData[key] = parsedValues;
            }
          });

          secondApiData!.value = filteredData;

          // Store data in local DB
          await _dbHelper.insertSecondApiData(json.encode(filteredData));
          print('Second API data fetched and stored locally.');
        } else {
          errorMessage.value = 'Unexpected data structure from the second API';
          print('Error: Unexpected data structure from the second API');
        }
      } else {
        errorMessage.value = 'Failed to load data from the second API';
        print('Error fetching second API data: ${response.statusCode}');
      }
    } catch (e) {
      errorMessage.value = 'Error fetching second API data: $e';
      print('Exception: Error fetching second API data: $e');
    }
  }
// before local db
//   Future<void> fetchSecondApiData() async {
//     try {
//       DateTime currentDate = DateTime.now();
//       DateTime pakistaniDateTime = currentDate.toUtc().add(Duration(hours: 5)); // assuming pakistaniTimeZoneOffset is 5
//       String formattedDate = pakistaniDateTime.toLocal().toString().split(' ')[0];
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       String? storedUsername = prefs.getString('username');
//       final String appurl = "http://203.135.63.47:8000/data?username=$storedUsername&mode=hour&start=$formattedDate&end=$formattedDate";
// print(appurl);
//       final response = await http.get(Uri.parse(appurl));
//
//       if (response.statusCode == 200) {
//         print('API response is successful.');
//         final Map<String, dynamic> secondApiResponse = json.decode(response.body);
//         final Map<String, dynamic> filteredData = {};
//         int currentHour = DateTime.now().hour;
//
//         if (secondApiResponse.containsKey('data') && secondApiResponse['data'] is Map) {
//           secondApiResponse['data'].forEach((key, value) {
//             if (value is List) {
//               List<dynamic> hourValues = value;
//               List<double> parsedValues = hourValues.take(currentHour + 1)
//                   .map((v) => double.tryParse(v.toString()) ?? 0.0).toList();
//               filteredData[key] = parsedValues;
//             } else {
//               print('Unexpected data type for $key: ${value.runtimeType}');
//             }
//           });
//
//           secondApiData!.value = filteredData;
//         } else {
//           print('Unexpected data structure: ${secondApiResponse['data'].runtimeType}');
//           throw Exception('Unexpected data structure from the second API');
//         }
//       } else {
//         print('Failed to fetch data from 2nd API. Status code: ${response.statusCode}');
//         throw Exception('Failed to load data from the second API');
//       }
//     } catch (e) {
//       print('Error fetching second API data: $e');
//     }
//   }
  Future<void> _loadDataFromLocalDb() async {
    try {
      String? storedFirstApiData = await _dbHelper.getFirstApiData();
      if (storedFirstApiData != null) {
        firstApiData!.value = json.decode(storedFirstApiData);
        print('First API data loaded from local DB.');
      } else {
        errorMessage.value = "No data available locally.";
        print('No first API data available locally.');
      }

      String? storedSecondApiData = await _dbHelper.getSecondApiData();
      if (storedSecondApiData != null) {
        secondApiData!.value = json.decode(storedSecondApiData);
        print('Second API data loaded from local DB.');
      } else {
        errorMessage.value = "No data available locally.";
        print('No second API data available locally.');
      }
    } catch (e) {
      errorMessage.value = 'Failed to load data from local DB: $e';
      print('Exception: Failed to load data from local DB: $e');
    }
  }


  double parseDouble(dynamic value) {
    if (value == null || value == "NA") {
      return 0.0;  // Convert "NA" to 0.0 as no data available
    }
    return double.tryParse(value.toString()) ?? 0.0;
  }

  String formatValued(double value) => (value / 1000).toStringAsFixed(2); //
  double getCurrentHourValue(List<double> values) {
    DateTime currentDate = DateTime.now();
    int currentHour = currentDate.hour;

    // Check if the values list is empty or if the current hour index is out of range
    if (values.isEmpty || currentHour >= values.length) {
      return 0.0;  // Return 0.0 as a default value if there's no data for the current hour
    }

    // Return the value corresponding to the current hour
    return values[currentHour];
  }

  // double getLastIndexValue(List<double> values) {
  //   // Check if the list is empty to avoid errors
  //   if (values.isEmpty) {
  //     // Return 0.0 or an appropriate default value if the list is empty
  //     return 0.0;
  //   }
  //
  //   // Calculate the start index for the last 5 elements
  //   int start = values.length - 5 >= 0 ? values.length - 5 : 0;
  //
  //   // Calculate the sum of the last 5 (or fewer) elements
  //   double sum = 0.0;
  //   for (int i = start; i < values.length; i++) {
  //     sum += values[i];
  //   }
  //
  //   // Calculate the mean by dividing the sum by the number of elements considered
  //   double mean = sum / (values.length - start);
  //
  //   return mean;
  // }

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

//
// Future<void> fetchFirstApiData() async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   String? storedUsername = prefs.getString('username');
//   final response = await http.get(Uri.parse(
//       'http://203.135.63.47:8000/buildingmap?username=$storedUsername'));
//
//   if (response.statusCode == 200) {
//     final Map<String, dynamic> responseData = json.decode(response.body);
//     firstApiData!.value = responseData;
//   } else {
//     throw Exception('Failed to load data from the first API');
//   }
// }
