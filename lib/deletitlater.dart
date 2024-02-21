import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyViewModel extends GetxController {
  RxList<String> result = <String>['0', '0', '0'].obs; // Initialize with zeroes
  RxString startDate = '2023-12-07'.obs;
  RxString endDate = '2023-12-07'.obs;

  Future<void> fetchData() async {
    String appUrl =
        'http://203.135.63.22:8000/data?username=ahmad&mode=hour&start=${startDate.value}&end=${endDate.value}';
    print(appUrl);
    final response = await http.get(Uri.parse(appUrl));

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = json.decode(response.body);
      processData(jsonData['data']);
    } else {
      print('Failed to load data');
      result.assignAll([
        'No matching keys found.',
        'No matching keys found.',
        'No matching keys found.'
      ]);
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

        result.assignAll([
          'Min Value: $minValue',
          'Max Value: $maxValue',
          'Average Value: $averageValue',
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
      await fetchData();
    }
  }
}

class MyHomePageMVVM extends StatelessWidget {
  final MyViewModel viewModel = Get.put(MyViewModel());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MVVM with GetX Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() => Row(
                  children: [
                    Text('Start Date: ${viewModel.startDate.value}'),
                    IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: () => viewModel.selectStartDate(context),
                    ),
                  ],
                )),
            Obx(() => Row(
                  children: [
                    Text('End Date: ${viewModel.endDate.value}'),
                    IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: () => viewModel.selectEndDate(context),
                    ),
                  ],
                )),
            SizedBox(height: 16),
            SizedBox(height: 16),
            Obx(() {
              if (viewModel.result.isNotEmpty) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildBox('Min Value:', viewModel.result[0]),
                    _buildBox('Max Value:', viewModel.result[1]),
                    _buildBox('Average Value:', viewModel.result[2]),
                  ],
                );
              } else {
                return Center(
                  child: Text('No matching keys found.'),
                );
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildBox(String label, String value) {
    return Container(
      width: 100,
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(label),
          SizedBox(height: 4),
          Text(value),
        ],
      ),
    );
  }
}
