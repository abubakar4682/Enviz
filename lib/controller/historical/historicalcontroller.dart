import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';



class HistoricalController extends GetxController {

  RxString startDate = '2024-01-07'.obs;
  RxString endDate = '2024-01-10'.obs;
  RxMap<String, dynamic>? firstApiData = <String, dynamic>{}.obs;
  RxMap<String, dynamic>? secondApiData = <String, dynamic>{}.obs;

  RxList<String> result = <String>['0', '0', '0'].obs;
  RxList<Map<String, dynamic>> kwData = <Map<String, dynamic>>[].obs;
  @override
  void onInit() {
    fetchFirstApiData();
    fetchSecondApiData();
    fetchData();
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
      endDate(picked.toLocal().toString().split(' ')[0]);
      await fetchSecondApiData();
      kwData.clear();
      await fetchData();
    }
  }
  Future<void> selectStartDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2025),
    );
    if (picked != null) {startDate(picked.toLocal().toString().split(' ')[0]);
    kwData.clear();
    };
  }

  Future<void> fetchData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? storedUsername = prefs.getString('username');
      final String appuril= 'http://203.135.63.22:8000/data?username=$storedUsername&mode=hour&start=${startDate.value}&end=${endDate.value}';
      final response = await http.get(Uri.parse(appuril));

print(appuril);

      try {
        if (response.statusCode == 200) {
          Map<String, dynamic> jsonData = json.decode(response.body);
          Map<String, dynamic> data = jsonData['data'];

          data.forEach((itemName, values) {
            if (itemName.endsWith("[kW]")) {
              String prefixName = itemName.substring(0, itemName.length - 4);
              List<double> numericValues = (values as List<dynamic>).map((value) {
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


  Future<void> fetchFirstApiData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUsername = prefs.getString('username');
    final response = await http.get(Uri.parse('http://203.135.63.22:8000/buildingmap?username=$storedUsername'));

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
    final response = await http.get(Uri.parse('http://203.135.63.22:8000/data?username=$storedUsername&mode=hour&start=${startDate.value}&end=${endDate.value}'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> secondApiResponse = json.decode(response.body);
      final Map<String, dynamic> filteredData = {};

      secondApiResponse['data'].forEach((key, value) {
        if (value.isEmpty) {
          filteredData[key] = List<double>.filled(24, 0.0);
        } else {
          filteredData[key] =
              value.map<double>((v) => parseDouble(v)).toList();
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

  double calculateTotalSum(List<double> sums) =>
      sums.reduce((total, current) => total + current);

  double calculateMin(List<double> sums) =>
      sums.reduce((min, current) => min < current ? min : current);

  double calculateMax(List<double> sums) =>
      sums.reduce((max, current) => max > current ? max : current);

  double calculateAverage(List<double> sums) =>
      sums.isEmpty ? 0.0 : sums.reduce((sum, current) => sum + current) / sums.length;

  String formatValue(double value) =>
      value >= 1000 ? '${(value / 1000).toStringAsFixed(2)}kW' : '${(value / 1000).toStringAsFixed(2)}kW';
  String formatValued(double value) => (value / 1000).toStringAsFixed(2); //







}

















