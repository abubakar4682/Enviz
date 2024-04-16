import 'dart:async';
import 'dart:convert';
import 'package:highcharts_demo/screens/login.dart';

import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:shared_preferences/shared_preferences.dart';


class MinMaxAvgValueControllers extends GetxController {
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

  Future<void> fetchFirstApiData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUsername = prefs.getString('username');
    final response = await http.get(Uri.parse(
        'http://203.135.63.47:8000/buildingmap?username=$storedUsername'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      firstApiData!.value = responseData;

      // Extract keys dynamically and store them for later use
      List<String> floorKeys = responseData.keys.map((key) => '$key\_[kW]').toList();
      result.value = floorKeys; // Assuming `result` is an RxList<String> for storing the keys
    } else {
      throw Exception('Failed to load data from the first API');
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

  Future<void> fetchSecondApiData() async {
    DateTime currentDate = DateTime.now();
    DateTime pakistaniDateTime =
    currentDate.toUtc().add(Duration(hours: pakistaniTimeZoneOffset));
    String formattedDate = pakistaniDateTime.toString().split(' ')[0];
    DateTime endDate = DateTime.now();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUsername = prefs.getString('username');
    final String appurl="http://203.135.63.47:8000/data?username=$storedUsername&mode=hour&start=$endDate&end=$endDate";
    final response = await http.get(Uri.parse(
        appurl));
    print(appurl);

    if (response.statusCode == 200) {
      print('api works');
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
