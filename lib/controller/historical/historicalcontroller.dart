import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoricalController extends GetxController {
  RxString startDate = '2024-03-18'.obs;
  RxString endDate = '2024-03-25'.obs;
  var chartData = ''.obs;
  var isLoading = true.obs;
  RxMap<String, dynamic>? firstApiData = <String, dynamic>{}.obs;
  RxMap<String, dynamic>? secondApiData = <String, dynamic>{}.obs;

  RxList<String> result = <String>['0', '0', '0'].obs;
  RxList<Map<String, dynamic>> kwData = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {

    super.onInit();
  }

  Future<void> selectEndDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2025),
    );
    if (picked != null) {
      checkDataAvailability();
      endDate(picked.toLocal().toString().split(' ')[0]);
      await fetchSecondApiData();
      kwData.clear();
       fetchData();
    }
  }

  Future<void> selectStartDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2025),
    );
    if (picked != null) {
      startDate(picked.toLocal().toString().split(' ')[0]);
      kwData.clear();
    }
  }
  void checkDataAvailability() async {
    isLoading(true);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? storedUsername = prefs.getString('username');
      // Assuming you have a user or a mechanism to select the current username dynamically
      final String username = 'ahmad'; // Replace with actual dynamic username if needed
      final url = Uri.parse('http://203.135.63.47:8000/buildingmap?username=$storedUsername');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        fetchMainKWData();
      } else {
        print('Failed to check data availability. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('An error occurred while checking data availability: $e');
    } finally {
      isLoading(false);
    }
  }

  // Method to fetch and process data for heatmap chart visualization
  void fetchMainKWData() async {
    isLoading(true);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? storedUsername = prefs.getString('username');
      // Replace with dynamic dates or parameters as necessary
      final url = Uri.parse('http://203.135.63.47:8000/data?username=$storedUsername&mode=hour&start=${startDate.value}&end=${endDate.value}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        List<dynamic> mainKWList;

        if (data.containsKey('Main_[kW]')) {
          mainKWList = data['Main_[kW]'];
        } else {
          List<dynamic> firstFloorList = data['1st Floor_[kW]'];
          List<dynamic> groundFloorList = data['Ground Floor_[kW]'];
          mainKWList = List.generate(firstFloorList.length, (index) => 0.0); // Initialize with zeroes

          for (int i = 0; i < firstFloorList.length; i++) {
            // Sum the values index-wise from both keys
            double firstFloorValue = double.tryParse(firstFloorList[i].toString()) ?? 0.0;
            double groundFloorValue = double.tryParse(groundFloorList[i].toString()) ?? 0.0;
            mainKWList[i] = firstFloorValue + groundFloorValue;
          }
        }

        // Process the data for visualization
        List<List<dynamic>> chunks = [];
        for (int i = 0; i < mainKWList.length; i += 24) {
          chunks.add(mainKWList.sublist(i, i + 24 > mainKWList.length ? mainKWList.length : i + 24));
        }

        List<String> xyValues = [];
        for (int day = 0; day < chunks.length; day++) {
          for (int hour = 0; hour < chunks[day].length; hour++) {
            double value = (chunks[day][hour] == null || chunks[day][hour] == "NA") ? 0.0 : double.parse(chunks[day][hour].toString());
            xyValues.add('{"x": $day, "y": $hour, "value": $value}');
          }
        }

        chartData('[${xyValues.join(",")}]');
      } else {
        throw Exception('Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('An error occurred while fetching and processing data: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchFirstApiData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUsername = prefs.getString('username');
    final response = await http.get(Uri.parse(
        'http://203.135.63.47:8000/buildingmap?username=$storedUsername'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      firstApiData!.value = responseData;
    } else {
      throw Exception('Failed to load data from the first API');
    }
  }

  Future<void> fetchSecondApiData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUsername = prefs.getString('username');
    final response = await http.get(Uri.parse(
        'http://203.135.63.47:8000/data?username=$storedUsername&mode=hour&start=${startDate.value}&end=${endDate.value}'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> secondApiResponse = json.decode(response.body);
      final Map<String, dynamic> filteredData = {};

      secondApiResponse['data'].forEach((key, value) {
        if (value.isEmpty) {
          filteredData[key] = List<double>.filled(24, 0.0);
        } else {
          filteredData[key] = value.map<double>((v) => parseDouble(v)).toList();
        }
      });

      secondApiData!.value = filteredData;
    } else {
      throw Exception('Failed to load data from the second API');
    }
  }





  Future<void> fetchData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? storedUsername = prefs.getString('username');
      final String appuril =
          'http://203.135.63.47:8000/data?username=$storedUsername&mode=hour&start=${startDate.value}&end=${endDate.value}';
      final response = await http.get(Uri.parse(appuril));

      print(appuril);

      try {
        if (response.statusCode == 200) {
          Map<String, dynamic> jsonData = json.decode(response.body);
          Map<String, dynamic> data = jsonData['data'];

          data.forEach((itemName, values) {
            if (itemName.endsWith("[kW]")) {
              String prefixName = itemName.substring(0, itemName.length - 4);
              List<double> numericValues =
                  (values as List<dynamic>).map((value) {
                if (value is num) {
                  // Convert to kW (divide by 1000)
                  return value.toDouble() / 1000.0;
                } else if (value is String) {
                  // Convert to double and then to kW (divide by 1000)
                  return (double.tryParse(value) ?? 0.0) / 1000.0;
                } else {
                  return 0.0;
                }
              }).toList();

              kwData.add({'prefixName': prefixName, 'values': numericValues});
            }
          });
        } else {
          print('Failed to fetch data. Status code: ${response.statusCode}');
        }
      } catch (error) {
        print('Error fetching data: $error');
      }
    } catch (error) {
      print('An unexpected error occurred: $error');
    }
  }
  void resetController() {
    // Reset to initial end date
    firstApiData!.value = <String, dynamic>{}; // Clear the data
    secondApiData!.value = <String, dynamic>{}; // Clear the data
    result.value = <String>['0', '0', '0']; // Reset the result
    kwData.clear(); // Clear the kW data list
  }


  double parseDouble(dynamic value) {
    if (value == null || value == "NA") {
      return 0.0;
    }
    return double.tryParse(value.toString()) ?? 0.0;
  }

  double calculateTotalSum(List<double> sums) =>
      sums.reduce((total, current) => total + current);

  double calculateMin(List<double> sums) =>
      sums.reduce((min, current) => min < current ? min : current);

  double calculateMax(List<double> sums) =>
      sums.reduce((max, current) => max > current ? max : current);

  double calculateAverage(List<double> sums) => sums.isEmpty
      ? 0.0
      : sums.reduce((sum, current) => sum + current) / sums.length;

  String formatValue(double value) => value >= 1000
      ? '${(value / 1000).toStringAsFixed(2)}kW'
      : '${(value / 1000).toStringAsFixed(2)}kW';

  String formatValued(double value) => (value / 1000).toStringAsFixed(2); //
  // Add this method in HistoricalController
  double getLastIndexValue(List<double> values) {
    // Check if the list is empty to avoid errors
    if (values.isNotEmpty) {
      return values.last;
    }
    // Return 0.0 or an appropriate default value if the list is empty
    return 0.0;
  }

}
