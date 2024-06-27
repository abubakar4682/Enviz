import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

class DataController extends GetxController {
  final String firstApiUrl =
      'http://203.135.63.22:8000/buildingmap?username=ppjp7isl';
  final String secondApiUrl =
      'http://203.135.63.22:8000/data?username=ppjp7isl&mode=hour&start=2024-01-11&end=2024-02-14';

  var firstApiResponse = {}.obs;
  var secondApiResponse = {}.obs;

  Future<void> fetchData() async {
    try {
      final response1 = await http.get(Uri.parse(firstApiUrl));
      final response2 = await http.get(Uri.parse(secondApiUrl));

      if (response1.statusCode == 200) {
        firstApiResponse.value = json.decode(response1.body);
      } else {
        throw Exception('Failed to load data from the first API');
      }

      if (response2.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response2.body);
        secondApiResponse.value = processData(data);
      } else {
        throw Exception('Failed to load data from the second API');
      }
    } catch (e) {
      throw Exception('Error fetching data: $e');
    }
  }

  Map<String, dynamic> processData(Map<String, dynamic> data) {
    Map<String, dynamic> filteredData = {};
    data.forEach((key, value) {
      if (value is List) {
        List<double> sanitizedDataList = value
            .map((item) => item == null || item == "NA" ? 0.0 : double.tryParse(item.toString()) ?? 0.0)
            .toList();
        filteredData[key] = sanitizedDataList;
      }
    });

    return filteredData;
  }
}

class MyHomePageone extends StatelessWidget {
  final DataController dataController = Get.put(DataController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Response'),
      ),
      body: Obx(() {
        if (dataController.firstApiResponse.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        } else if (dataController.firstApiResponse.containsKey("Main")) {
          return _buildUiForMain(dataController.firstApiResponse as Map<String, dynamic>);
        } else {
          List<String> modifiedKeys =
          dataController.firstApiResponse.keys.map((key) => '$key\_[kW]').toList();
          return _buildUiForOther(modifiedKeys);
        }
      }),
    );
  }

  Widget _buildUiForMain(Map<String, dynamic> firstApiResponse) {
    return Obx(() {
      if (dataController.secondApiResponse.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      } else {
        List<double> sumsList = [];
        RxMap mainApiData = dataController.secondApiResponse;

        for (int i = 0; i < mainApiData["Main_[kW]"].length; i++) {
          double sum = _parseDouble(mainApiData["Main_[kW]"][i]);
          sumsList.add(sum);
        }

        double totalSum = _calculateTotalSum(sumsList);
        double minSum = _calculateMin(sumsList);
        double maxSum = _calculateMax(sumsList);
        double avgSum = _calculateAverage(sumsList);

        return _buildSummaryUi(totalSum, minSum, maxSum, avgSum);
      }
    });
  }

  Widget _buildUiForOther(List<String> modifiedKeys) {
    return Obx(() {
      if (dataController.secondApiResponse.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      } else {
        List<double> sumsList = [];
        RxMap filteredData = dataController.secondApiResponse;

        for (int i = 0; i < filteredData['1st Floor_[kW]'].length; i++) {
          double sum = _parseDouble(filteredData['1st Floor_[kW]'][i]) +
              _parseDouble(filteredData['Ground Floor_[kW]'][i]);
          sumsList.add(sum);
        }

        double totalSum = _calculateTotalSum(sumsList);
        double minSum = _calculateMin(sumsList);
        double maxSum = _calculateMax(sumsList);
        double avgSum = _calculateAverage(sumsList);

        return _buildSummaryUi(totalSum, minSum, maxSum, avgSum);
      }
    });
  }

  double _parseDouble(dynamic value) {
    if (value == null || value == "NA") {
      return 0.0;
    }
    return double.tryParse(value.toString()) ?? 0.0;
  }

  double _calculateTotalSum(List<double> sums) =>
      sums.reduce((total, current) => total + current);

  double _calculateMin(List<double> sums) =>
      sums.reduce((min, current) => min < current ? min : current);

  double _calculateMax(List<double> sums) =>
      sums.reduce((max, current) => max > current ? max : current);

  double _calculateAverage(List<double> sums) =>
      sums.isEmpty ? 0.0 : sums.reduce((sum, current) => sum + current) / sums.length;

  String _formatValue(double value) =>
      value >= 1000 ? '${(value / 1000).toStringAsFixed(2)}kW' : '${(value / 1000).toStringAsFixed(2)}kW';

  Widget _buildSummaryUi(double totalSum, double minSum, double maxSum, double avgSum) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildSummaryText('Total Power:', _formatValue(totalSum)),
          _buildSummaryText('Min Power:', _formatValue(minSum)),
          _buildSummaryText('Max Power:', _formatValue(maxSum)),
          _buildSummaryText('Average Power:', _formatValue(avgSum)),
        ],
      ),
    );
  }

  Widget _buildSummaryText(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          'Value: $value',
          style: const TextStyle(fontSize: 18),
        ),
        const Divider(),
      ],
    );
  }
}
