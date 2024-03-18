import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:high_chart/high_chart.dart';
import 'package:timezone/timezone.dart' as tz;

import 'controller/datacontroller.dart';

class DataDisplayScreen extends StatefulWidget {
  @override
  _DataDisplayScreenState createState() => _DataDisplayScreenState();
}

class _DataDisplayScreenState extends State<DataDisplayScreen> {
  // Assuming you have a DataController instance
  Controllers _dataController = Controllers();

  @override
  void initState() {
    super.initState();
    fetchDataAndUpdateUI();
  }

  Future<void> fetchDataAndUpdateUI() async {
    // Call the fetchData method to populate data
    await _dataController.fetchData();
    // Update the UI after fetching data
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _dataController.loading.value
          ? CircularProgressIndicator()
          : _buildDataList(),
    );
  }

  Widget _buildDataList() {
    // Extract the data from the DataController
    Map<String, Map<String, double>> dailyItemSumsMap =
        _dataController.dailyItemSumsMap;
    return ListView.builder(
      itemCount: dailyItemSumsMap.length,
      itemBuilder: (context, dateIndex) {
        String date = dailyItemSumsMap.keys.elementAt(dateIndex);
        Map<String, double>? itemSums = dailyItemSumsMap[date];
        return Card(
          margin: EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //   StockColumns(controllers: _dataController),
              ListTile(
                title: Text('Date: $date'),
              ),
              Divider(),
              ...itemSums!.entries.map((entry) {
                String itemName = entry.key;
                double sum = entry.value;

                return ListTile(
                  title: Text('$itemName: $sum'),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }
}



class Controllers extends GetxController {
  // RxList<Map<String, dynamic>> kwData = <Map<String, dynamic>>[].obs;
  RxDouble lastMainKWValue = 0.0.obs;
  RxBool loading = false.obs;

  // Declare nameAndSumMap as a public property
  Map<String, double> nameAndSumMap = {};

  // Declare dailySumMap as a public property
  Map<String, double> dailySumMap = {};

  // Declare dailyItemSumsMap as a public property
  Map<String, Map<String, double>> dailyItemSumsMap = {};

  // Specify the Pakistani time zone
  final int pakistaniTimeZoneOffset = 10;

  Future<void> fetchData() async {
    loading.value = true;

    Set<String> processedDates = Set();
    try {
      // Loop through the last seven days
      for (int i = 6; i >= 0; i--) {
        // Calculate the date for the current iteration in the Pakistani time zone
        DateTime currentDate = DateTime.now().subtract(Duration(days: i));
        DateTime pakistaniDateTime = currentDate.toUtc().add(Duration(hours: pakistaniTimeZoneOffset));
        String formattedDate = pakistaniDateTime.toString().split(' ')[0];
        // Skip fetching if the date has already been processed
        if (processedDates.contains(formattedDate)) {
          continue;
        }

        try {
          // Make an HTTP GET request
          final String apiUrl = "http://203.135.63.22:8000/data?username=ahmad&mode=hour&start=$formattedDate&end=$formattedDate";
          final response = await http.get(Uri.parse(apiUrl));

          // Check if the request was successful (status code 200)
          if (response.statusCode == 200) {
            // Parse the JSON response
            Map<String, dynamic> jsonData = json.decode(response.body);
            Map<String, dynamic> data = jsonData['data'];

            // Extract and process relevant data
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

            dailyItemSumsMap[formattedDate] = itemSums;
            processedDates.add(formattedDate);
          } else {
            // Handle unsuccessful response
            print('Failed to fetch data for $formattedDate. Status code: ${response.statusCode}');
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
    } finally {
      loading.value = false;
    }
  }
}