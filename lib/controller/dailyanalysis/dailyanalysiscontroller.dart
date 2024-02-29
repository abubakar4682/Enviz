import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';


class DailyAnalysisController extends GetxController {
  RxString startDate = '2024-01-07'.obs;
  RxString endDate = '2024-02-20'.obs;
  RxList<Map<String, dynamic>> kwData = <Map<String, dynamic>>[].obs;
  Future<void> selectStartDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2025),
    );
    if (picked != null)  {startDate(picked.toLocal().toString().split(' ')[0]);
    kwData.clear();
     fetchFirstApiData();
    };
  }


  void fetchSecondApiData(List<String> keys) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUsername = prefs.getString('username');
    final response = await http.get(Uri.parse('http://203.135.63.22:8000/data?username=$storedUsername&mode=hour&start=${endDate.value}&end=${endDate.value}'));
    if (response.statusCode == 200) {
      Map<String, dynamic> secondApiResponseData = json.decode(response.body);
      Map<String, dynamic> filteredData = {};

      keys.forEach((key) {
        if (secondApiResponseData['data'].containsKey(key)) {
          if (secondApiResponseData['data'][key].isEmpty) {
            filteredData[key] = List<double>.filled(24, 0.0);
          } else {
            List<dynamic> dataList = secondApiResponseData['data'][key];
            List<double> sanitizedDataList = dataList.map((value) {
              if (value == null || value == "NA") {
                return 0.0;
              }
              return double.tryParse(value.toString()) ?? 0.0;
            }).toList();

            filteredData[key] = sanitizedDataList;
          }
        }
      });

      secondApiResponse.value = filteredData;
    } else {
      throw Exception('Failed to load data from the second API');
    }
  }

  final firstApiResponse = Rxn<Map<String, dynamic>>();
  final secondApiResponse = Rxn<Map<String, dynamic>>();

  void fetchFirstApiData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUsername = prefs.getString('username');
    final response = await http.get(Uri.parse('http://203.135.63.22:8000/buildingmap?username=$storedUsername'));


    if (response.statusCode == 200) {
      firstApiResponse.value = json.decode(response.body);
    } else {
      throw Exception('Failed to load data from the first API');
    }
  }



  double parseDouble(dynamic value) {
    if (value == null || value == "NA") {
      return 0.0;
    }
    return double.tryParse(value.toString()) ?? 0.0;
  }
}