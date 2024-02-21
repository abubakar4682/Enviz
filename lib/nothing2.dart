import 'package:flutter/material.dart';
import 'package:highcharts_demo/widgets/StartingndEnding.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';



class ApiController extends GetxController {

  RxString startDate = '2024-01-07'.obs;
  RxString endDate = '2024-01-07'.obs;
  RxMap<String, dynamic>? firstApiData = <String, dynamic>{}.obs;
  RxMap<String, dynamic>? secondApiData = <String, dynamic>{}.obs;

  RxList<String> result = <String>['0', '0', '0'].obs;
  @override
  void onInit() {
    fetchFirstApiData();
    fetchSecondApiData();
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


















//
// class MyAppsss extends StatelessWidget {
//   final ApiController apiController = Get.put(ApiController());
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('API Response'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             SelectStartndEndingDate(controller: apiController, context: context),
//
//             Obx(() {
//               final firstApiData = apiController.firstApiData!.value;
//               if (firstApiData == null || firstApiData.isEmpty) {
//                 return CircularProgressIndicator();
//               } else {
//                 if (firstApiData.containsKey("Main")) {
//                   return _buildUiForMain(firstApiData);
//                 } else {
//                   List<String> modifiedKeys = firstApiData.keys
//                       .map((key) => '$key\_[kW]')
//                       .toList();
//                   return _buildUiForOther(modifiedKeys);
//                 }
//               }
//             }),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildUiForMain(Map<String, dynamic> firstApiResponse) {
//     return Obx(() {
//       final secondApiData = apiController.secondApiData!.value;
//       if (secondApiData == null || secondApiData.isEmpty) {
//         return CircularProgressIndicator();
//       } else {
//         List<double> sumsList = [];
//         for (int i = 0; i < secondApiData["Main_[kW]"].length; i++) {
//           double sum = apiController.parseDouble(secondApiData["Main_[kW]"][i]);
//           sumsList.add(sum);
//         }
//
//         double totalSum = apiController.calculateTotalSum(sumsList);
//         double minSum = apiController.calculateMin(sumsList);
//         double maxSum = apiController.calculateMax(sumsList);
//         double avgSum = apiController.calculateAverage(sumsList);
//
//         return _buildSummaryUi(totalSum, minSum, maxSum, avgSum);
//       }
//     });
//   }
//
//   Widget _buildUiForOther(List<String> modifiedKeys) {
//     return Obx(() {
//       final secondApiData = apiController.secondApiData!.value;
//       if (secondApiData == null || secondApiData.isEmpty) {
//         return CircularProgressIndicator();
//       } else {
//         List<double> sumsList = [];
//         for (int i = 0; i < secondApiData['1st Floor_[kW]'].length; i++) {
//           double sum = apiController.parseDouble(secondApiData['1st Floor_[kW]'][i]) +
//               apiController.parseDouble(secondApiData['Ground Floor_[kW]'][i]);
//           sumsList.add(sum);
//         }
//
//         double totalSum = apiController.calculateTotalSum(sumsList);
//         double minSum = apiController.calculateMin(sumsList);
//         double maxSum = apiController.calculateMax(sumsList);
//         double avgSum = apiController.calculateAverage(sumsList);
//
//         return _buildSummaryUi(totalSum, minSum, maxSum, avgSum);
//       }
//     });
//   }
//
//   Widget _buildSummaryUi(double totalSum, double minSum, double maxSum, double avgSum) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           _buildSummaryText('Total Power:', apiController.formatValue(totalSum)),
//           _buildSummaryText('Min Power:', apiController.formatValue(minSum)),
//           _buildSummaryText('Max Power:', apiController.formatValue(maxSum)),
//           _buildSummaryText('Average Power:', apiController.formatValue(avgSum)),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSummaryText(String title, String value) {
//     return Column(
//       children: [
//         Text(
//           title,
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         Text(
//           ' $value',
//           style: TextStyle(fontSize: 18),
//         ),
//         Divider(),
//       ],
//     );
//   }
// }
