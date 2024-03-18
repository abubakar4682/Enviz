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
        title: Text('API Response'),
      ),
      body: Obx(() {
        if (dataController.firstApiResponse.isEmpty) {
          return Center(child: CircularProgressIndicator());
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
        return Center(child: CircularProgressIndicator());
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
        return Center(child: CircularProgressIndicator());
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
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          'Value: $value',
          style: TextStyle(fontSize: 18),
        ),
        Divider(),
      ],
    );
  }
}

// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:get/get.dart';
//
// class MyDataController extends GetxController {
//   final String firstApiUrl =
//       'http://203.135.63.22:8000/buildingmap?username=ppjp7isl';
//   final String secondApiUrl =
//       'http://203.135.63.22:8000/data?username=ppjp7isl&mode=hour&start=2024-01-11&end=2024-02-14';
//   String formatValue(double value) => value >= 1000 ? '${(value / 1000).toStringAsFixed(2)}kW' : '${(value / 1000).toStringAsFixed(2)}kW';
//   var firstApiResponse = {}.obs;
//   var mainApiData = {}.obs;
//   var filteredData = {}.obs;
//
//   @override
//   void onInit() {
//     fetchFirstApiData();
//     super.onInit();
//   }
//
//   Future<void> fetchFirstApiData() async {
//     final response = await http.get(Uri.parse(firstApiUrl));
//
//     if (response.statusCode == 200) {
//       firstApiResponse.value = json.decode(response.body);
//     } else {
//       throw Exception('Failed to load data from the first API');
//     }
//   }
//
//   Future<void> fetchSecondApiData(List<String> keys) async {
//     final response = await http.get(Uri.parse(secondApiUrl));
//
//     if (response.statusCode == 200) {
//       Map<String, dynamic> secondApiResponse = json.decode(response.body);
//
//       filteredData.value = {};
//       keys.forEach((key) {
//         if (secondApiResponse['data'].containsKey(key)) {
//           if (secondApiResponse['data'][key].isEmpty) {
//             filteredData[key] = List<double>.filled(24, 0.0);
//           } else {
//             List<dynamic> dataList = secondApiResponse['data'][key];
//             List<double> sanitizedDataList = dataList.map((value) {
//               if (value == null || value == "NA") {
//                 return 0.0;
//               }
//               return double.tryParse(value.toString()) ?? 0.0;
//             }).toList();
//
//             filteredData[key] = sanitizedDataList;
//           }
//         }
//       });
//
//       mainApiData.value = filteredData.value;
//     } else {
//       throw Exception('Failed to load data from the second API');
//     }
//   }
//
//   double parseDouble(dynamic value) {
//     if (value == null || value == "NA") {
//       return 0.0;
//     }
//     return double.tryParse(value.toString()) ?? 0.0;
//   }
//
//   double calculateTotalSum(List<double> sums) => sums.reduce((total, current) => total + current);
//
//   double calculateMin(List<double> sums) => sums.reduce((min, current) => min < current ? min : current);
//
//   double calculateMax(List<double> sums) => sums.reduce((max, current) => max > current ? max : current);
//
//   double calculateAverage(List<double> sums) => sums.isEmpty ? 0.0 : sums.reduce((sum, current) => sum + current) / sums.length;
// }
//
//
//
// class MyHomePageSD extends StatelessWidget {
//   final MyDataController myDataController = Get.put(MyDataController());
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('API Response'),
//       ),
//       body: Obx(() {
//         if (myDataController.firstApiResponse.isEmpty) {
//           return Center(child: CircularProgressIndicator());
//         } else if (myDataController.firstApiResponse.containsKey("Main")) {
//           return _buildUiForMain(myDataController.firstApiResponse.value as Map<String, dynamic>);
//
//         } else {
//           List<String> modifiedKeys =
//           myDataController.firstApiResponse.keys.map((key) => '$key\_[kW]').toList();
//           return _buildUiForOther(modifiedKeys);
//         }
//       }),
//     );
//   }
//
//   Widget _buildUiForMain(Map<String, dynamic> firstApiResponse) {
//     return Obx(() {
//       if (myDataController.mainApiData.isEmpty) {
//         return Center(child: CircularProgressIndicator());
//       } else {
//         List<double> sumsList = [];
//         for (int i = 0; i < myDataController.mainApiData["Main_[kW]"].length; i++) {
//           double sum = myDataController.parseDouble(myDataController.mainApiData["Main_[kW]"][i]);
//           sumsList.add(sum);
//         }
//
//         double totalSum = myDataController.calculateTotalSum(sumsList);
//         double minSum = myDataController.calculateMin(sumsList);
//         double maxSum = myDataController.calculateMax(sumsList);
//         double avgSum = myDataController.calculateAverage(sumsList);
//
//         return _buildSummaryUi(totalSum, minSum, maxSum, avgSum);
//       }
//     });
//   }
//
//   Widget _buildUiForOther(List<String> modifiedKeys) {
//     return Obx(() {
//       if (myDataController.filteredData.isEmpty) {
//         return Center(child: CircularProgressIndicator());
//       } else {
//         List<double> sumsList = [];
//         for (int i = 0; i < myDataController.filteredData['1st Floor_[kW]'].length; i++) {
//           double sum = myDataController.parseDouble(myDataController.filteredData['1st Floor_[kW]'][i]) +
//               myDataController.parseDouble(myDataController.filteredData['Ground Floor_[kW]'][i]);
//           sumsList.add(sum);
//         }
//
//         double totalSum = myDataController.calculateTotalSum(sumsList);
//         double minSum = myDataController.calculateMin(sumsList);
//         double maxSum = myDataController.calculateMax(sumsList);
//         double avgSum = myDataController.calculateAverage(sumsList);
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
//           _buildSummaryText('Total Power:', myDataController.formatValue(totalSum)),
//           _buildSummaryText('Min Power:', myDataController.formatValue(minSum)),
//           _buildSummaryText('Max Power:', myDataController.formatValue(maxSum)),
//           _buildSummaryText('Average Power:', myDataController.formatValue(avgSum)),
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
//           'Value: $value',
//           style: TextStyle(fontSize: 18),
//         ),
//         Divider(),
//       ],
//     );
//   }
// }
//
// // import 'package:flutter/material.dart';
// // import 'dart:convert';
// // import 'package:http/http.dart' as http;
// // import 'package:get/get.dart';
// //
// // void main() {
// //   runApp(MyAppsss());
// // }
// //
// // class Model {
// //   Future<Map<String, dynamic>> fetchFirstApiData() async {
// //     final String firstApiUrl =
// //         'http://203.135.63.22:8000/buildingmap?username=ppjp7isl';
// //     final response = await http.get(Uri.parse(firstApiUrl));
// //
// //     if (response.statusCode == 200) {
// //       return json.decode(response.body);
// //     } else {
// //       throw Exception('Failed to load data from the first API');
// //     }
// //   }
// //
// //   Future<Map<String, dynamic>> fetchSecondApiData(List<String> keys) async {
// //     final String secondApiUrl =
// //         'http://203.135.63.22:8000/data?username=ppjp7isl&mode=hour&start=2024-02-11&end=2024-02-14';
// //     final response = await http.get(Uri.parse(secondApiUrl));
// //
// //     if (response.statusCode == 200) {
// //       Map<String, dynamic> secondApiResponse = json.decode(response.body);
// //       Map<String, dynamic> filteredData = {};
// //
// //       keys.forEach((key) {
// //         if (secondApiResponse['data'].containsKey(key)) {
// //           if (secondApiResponse['data'][key].isEmpty) {
// //             filteredData[key] = List<double>.filled(24, 0.0);
// //           } else {
// //             List<dynamic> dataList = secondApiResponse['data'][key];
// //             List<double> sanitizedDataList = dataList.map((value) {
// //               if (value == null || value == "NA") {
// //                 return 0.0;
// //               }
// //               return double.tryParse(value.toString()) ?? 0.0;
// //             }).toList();
// //
// //             filteredData[key] = sanitizedDataList;
// //           }
// //         }
// //       });
// //
// //       return filteredData;
// //     } else {
// //       throw Exception('Failed to load data from the second API');
// //     }
// //   }
// //
// //   double parseDouble(dynamic value) {
// //     if (value == null || value == "NA") {
// //       return 0.0;
// //     }
// //     return double.tryParse(value.toString()) ?? 0.0;
// //   }
// // }
// //
// // class ViewModel extends GetxController {
// //   final Model model = Model();
// //   Rx<Map<String, dynamic>> firstApiData = Rx<Map<String, dynamic>>({});
// //   Rx<Map<String, dynamic>> secondApiData = Rx<Map<String, dynamic>>({});
// //
// //   Future<void> getFirstApiData() async {
// //     try {
// //       firstApiData.value = await model.fetchFirstApiData();
// //     } catch (e) {
// //       print('Error fetching first API data: $e');
// //     }
// //   }
// //
// //   Future<void> getSecondApiData(List<String> keys) async {
// //     try {
// //       secondApiData.value = await model.fetchSecondApiData(keys);
// //     } catch (e) {
// //       print('Error fetching second API data: $e');
// //     }
// //   }
// // }
// //
// // class View extends StatelessWidget {
// //   final ViewModel viewModel = Get.put(ViewModel());
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       home: Scaffold(
// //         appBar: AppBar(
// //           title: Text('API Response'),
// //         ),
// //         body: Obx(
// //               () {
// //             final firstApiData = viewModel.firstApiData.value;
// //             if (firstApiData.isEmpty) {
// //               return Center(child: CircularProgressIndicator());
// //             } else {
// //               return firstApiData.containsKey("Main")
// //                   ? _buildUiForMain(firstApiData)
// //                   : _buildUiForOther(
// //                 firstApiData.keys.map((key) => '$key\_[kW]').toList(),
// //               );
// //             }
// //           },
// //         ),
// //
// //       ),
// //     );
// //   }
// //
// //   Widget _buildUiForMain(Map<String, dynamic> firstApiResponse) {
// //     return FutureBuilder(
// //       future: viewModel.getSecondApiData(["Main_[kW]"]),
// //       builder: (context, mainApiSnapshot) {
// //         if (mainApiSnapshot.connectionState == ConnectionState.waiting) {
// //           return Center(child: CircularProgressIndicator());
// //         } else if (mainApiSnapshot.hasError) {
// //           return Center(child: Text('Error: ${mainApiSnapshot.error}'));
// //         } else if (mainApiSnapshot.data == null) {
// //           print('Main API data is null.');
// //           return Center(
// //               child: Text('No data available for the Main_[kW] key'));
// //         } else {
// //           List<double> sumsList = [];
// //           Map<String, dynamic> mainApiData = viewModel.secondApiData.value;
// //           for (int i = 0; i < mainApiData["Main_[kW]"].length; i++) {
// //             double sum =
// //             viewModel.model.parseDouble(mainApiData["Main_[kW]"][i]);
// //             sumsList.add(sum);
// //           }
// //           double totalSum = sumsList.reduce((total, current) => total + current);
// //           double minSum =
// //           sumsList.reduce((min, current) => min < current ? min : current);
// //           double maxSum =
// //           sumsList.reduce((max, current) => max > current ? max : current);
// //           double avgSum = sumsList.isEmpty
// //               ? 0.0
// //               : sumsList.reduce((sum, current) => sum + current) /
// //               sumsList.length;
// //
// //           return _buildSummaryUi(totalSum, minSum, maxSum, avgSum);
// //         }
// //       },
// //     );
// //   }
// //
// //   Widget _buildUiForOther(List<String> modifiedKeys) {
// //     return FutureBuilder(
// //       future: viewModel.getSecondApiData(modifiedKeys),
// //       builder: (context, secondApiSnapshot) {
// //         if (secondApiSnapshot.connectionState == ConnectionState.waiting) {
// //           return Center(child: CircularProgressIndicator());
// //         } else if (secondApiSnapshot.hasError) {
// //           return Center(child: Text('Error: ${secondApiSnapshot.error}'));
// //         } else if (secondApiSnapshot.data == null) {
// //           print('Second API data is null.');
// //           return Center(child: Text('No data available from the second API'));
// //         } else {
// //           List<double> sumsList = [];
// //           Map<String, dynamic> filteredData = viewModel.secondApiData.value;
// //           for (int i = 0; i < filteredData['1st Floor_[kW]'].length; i++) {
// //             double sum = viewModel.model.parseDouble(
// //                 filteredData['1st Floor_[kW]'][i]) +
// //                 viewModel.model.parseDouble(
// //                     filteredData['Ground Floor_[kW]'][i]);
// //             sumsList.add(sum);
// //           }
// //           double totalSum =
// //           sumsList.reduce((total, current) => total + current);
// //           double minSum =
// //           sumsList.reduce((min, current) => min < current ? min : current);
// //           double maxSum =
// //           sumsList.reduce((max, current) => max > current ? max : current);
// //           double avgSum = sumsList.isEmpty
// //               ? 0.0
// //               : sumsList.reduce((sum, current) => sum + current) /
// //               sumsList.length;
// //
// //           return _buildSummaryUi(totalSum, minSum, maxSum, avgSum);
// //         }
// //       },
// //     );
// //   }
// //
// //   Widget _buildSummaryUi(double totalSum, double minSum, double maxSum, double avgSum) {
// //     return Center(
// //       child: Column(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         crossAxisAlignment: CrossAxisAlignment.center,
// //         children: [
// //           _buildSummaryText('Total Sum:', formatValue(totalSum)),
// //           _buildSummaryText('Min Sum:', formatValue(minSum)),
// //           _buildSummaryText('Max Sum:', formatValue(maxSum)),
// //           _buildSummaryText('Average Sum:', formatValue(avgSum)),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildSummaryText(String title, String value) {
// //     return Column(
// //       children: [
// //         Text(
// //           title,
// //           style: TextStyle(fontWeight: FontWeight.bold),
// //         ),
// //         Text(
// //           'Value: $value',
// //           style: TextStyle(fontSize: 18),
// //         ),
// //         Divider(),
// //       ],
// //     );
// //   }
// //
// //   String formatValue(double value) =>
// //       value >= 1000 ? '${(value / 1000).toStringAsFixed(2)}kW' : '${(value / 1000).toStringAsFixed(2)}kW';
// // }
// //
// // class MyAppsss extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     return View();
// //   }
// // }
//
//
//
//
//
//
// // import 'package:flutter/material.dart';
//
// // import 'dart:convert';
// // import 'package:http/http.dart' as http;
// //
// // void main() {
// //   runApp(MyAppsssss());
// // }
// //
// // class Model {
// //   Future<Map<String, dynamic>> fetchFirstApiData() async {
// //     final String firstApiUrl =
// //         'http://203.135.63.22:8000/buildingmap?username=ppjp7isl';
// //     final response = await http.get(Uri.parse(firstApiUrl));
// //
// //     if (response.statusCode == 200) {
// //       return json.decode(response.body);
// //     } else {
// //       throw Exception('Failed to load data from the first API');
// //     }
// //   }
// //
// //   Future<Map<String, dynamic>> fetchSecondApiData(List<String> keys) async {
// //     final String secondApiUrl =
// //         'http://203.135.63.22:8000/data?username=ppjp7isl&mode=hour&start=2024-02-11&end=2024-02-14';
// //     final response = await http.get(Uri.parse(secondApiUrl));
// //
// //     if (response.statusCode == 200) {
// //       Map<String, dynamic> secondApiResponse = json.decode(response.body);
// //       Map<String, dynamic> filteredData = {};
// //
// //       keys.forEach((key) {
// //         if (secondApiResponse['data'].containsKey(key)) {
// //           if (secondApiResponse['data'][key].isEmpty) {
// //             filteredData[key] = List<double>.filled(24, 0.0);
// //           } else {
// //             List<dynamic> dataList = secondApiResponse['data'][key];
// //             List<double> sanitizedDataList = dataList.map((value) {
// //               if (value == null || value == "NA") {
// //                 return 0.0;
// //               }
// //               return double.tryParse(value.toString()) ?? 0.0;
// //             }).toList();
// //
// //             filteredData[key] = sanitizedDataList;
// //           }
// //         }
// //       });
// //
// //       return filteredData;
// //     } else {
// //       throw Exception('Failed to load data from the second API');
// //     }
// //   }
// //
// //   double parseDouble(dynamic value) {
// //     if (value == null || value == "NA") {
// //       return 0.0;
// //     }
// //     return double.tryParse(value.toString()) ?? 0.0;
// //   }
// // }
// //
// // class ViewModel {
// //   final Model model = Model();
// //
// //   Future<Map<String, dynamic>> getFirstApiData() async {
// //     return await model.fetchFirstApiData();
// //   }
// //
// //   Future<Map<String, dynamic>> getSecondApiData(List<String> keys) async {
// //     return await model.fetchSecondApiData(keys);
// //   }
// // }
// //
// // class View extends StatelessWidget {
// //   final ViewModel viewModel = ViewModel();
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       home: Scaffold(
// //         appBar: AppBar(
// //           title: Text('API Response'),
// //         ),
// //         body: FutureBuilder(
// //           future: viewModel.getFirstApiData(),
// //           builder: (context, firstApiSnapshot) {
// //             if (firstApiSnapshot.connectionState == ConnectionState.waiting) {
// //               return Center(child: CircularProgressIndicator());
// //             } else if (firstApiSnapshot.hasError) {
// //               return Center(child: Text('Error: ${firstApiSnapshot.error}'));
// //             } else if (firstApiSnapshot.data == null) {
// //               return Center(child: Text('No data available from the first API'));
// //             } else {
// //               Map<String, dynamic> firstApiResponse =
// //               firstApiSnapshot.data as Map<String, dynamic>; // Explicit cast
// //               if (firstApiResponse.containsKey("Main")) {
// //                 return _buildUiForMain(firstApiResponse);
// //               } else {
// //                 List<String> modifiedKeys = firstApiResponse.keys
// //                     .map((key) => '$key\_[kW]')
// //                     .toList();
// //                 return _buildUiForOther(modifiedKeys);
// //               }
// //             }
// //           },
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildUiForMain(Map<String, dynamic> firstApiResponse) {
// //     return FutureBuilder(
// //       future: viewModel.getSecondApiData(["Main_[kW]"]),
// //       builder: (context, mainApiSnapshot) {
// //         if (mainApiSnapshot.connectionState == ConnectionState.waiting) {
// //           return Center(child: CircularProgressIndicator());
// //         } else if (mainApiSnapshot.hasError) {
// //           return Center(child: Text('Error: ${mainApiSnapshot.error}'));
// //         } else if (mainApiSnapshot.data == null) {
// //           print('Main API data is null.');
// //           return Center(
// //               child: Text('No data available for the Main_[kW] key'));
// //         } else {
// //           List<double> sumsList = [];
// //           Map<String, dynamic> mainApiData =
// //           mainApiSnapshot.data as Map<String, dynamic>; // Explicit cast
// //           for (int i = 0; i < mainApiData["Main_[kW]"].length; i++) {
// //             double sum = viewModel.model
// //                 .parseDouble(mainApiData["Main_[kW]"][i]);
// //             sumsList.add(sum);
// //           }
// //           double totalSum = sumsList.reduce((total, current) => total + current);
// //           double minSum =
// //           sumsList.reduce((min, current) => min < current ? min : current);
// //           double maxSum =
// //           sumsList.reduce((max, current) => max > current ? max : current);
// //           double avgSum = sumsList.isEmpty
// //               ? 0.0
// //               : sumsList.reduce((sum, current) => sum + current) /
// //               sumsList.length;
// //
// //           return _buildSummaryUi(totalSum, minSum, maxSum, avgSum);
// //         }
// //       },
// //     );
// //   }
// //
// //   Widget _buildUiForOther(List<String> modifiedKeys) {
// //     return FutureBuilder(
// //       future: viewModel.getSecondApiData(modifiedKeys),
// //       builder: (context, secondApiSnapshot) {
// //         if (secondApiSnapshot.connectionState == ConnectionState.waiting) {
// //           return Center(child: CircularProgressIndicator());
// //         } else if (secondApiSnapshot.hasError) {
// //           return Center(child: Text('Error: ${secondApiSnapshot.error}'));
// //         } else if (secondApiSnapshot.data == null) {
// //           print('Second API data is null.');
// //           return Center(child: Text('No data available from the second API'));
// //         } else {
// //           List<double> sumsList = [];
// //           Map<String, dynamic> filteredData =
// //           secondApiSnapshot.data as Map<String, dynamic>; // Explicit cast
// //           for (int i = 0; i < filteredData['1st Floor_[kW]'].length; i++) {
// //             double sum = viewModel.model.parseDouble(
// //                 filteredData['1st Floor_[kW]'][i]) +
// //                 viewModel.model.parseDouble(
// //                     filteredData['Ground Floor_[kW]'][i]);
// //             sumsList.add(sum);
// //           }
// //           double totalSum =
// //           sumsList.reduce((total, current) => total + current);
// //           double minSum =
// //           sumsList.reduce((min, current) => min < current ? min : current);
// //           double maxSum =
// //           sumsList.reduce((max, current) => max > current ? max : current);
// //           double avgSum = sumsList.isEmpty
// //               ? 0.0
// //               : sumsList.reduce((sum, current) => sum + current) /
// //               sumsList.length;
// //
// //           return _buildSummaryUi(totalSum, minSum, maxSum, avgSum);
// //         }
// //       },
// //     );
// //   }
// //
// //   Widget _buildSummaryUi(double totalSum, double minSum, double maxSum, double avgSum) {
// //     return Center(
// //       child: Column(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         crossAxisAlignment: CrossAxisAlignment.center,
// //         children: [
// //           _buildSummaryText('Total Sum:', formatValue(totalSum)),
// //           _buildSummaryText('Min Sum:', formatValue(minSum)),
// //           _buildSummaryText('Max Sum:', formatValue(maxSum)),
// //           _buildSummaryText('Average Sum:', formatValue(avgSum)),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildSummaryText(String title, String value) {
// //     return Column(
// //       children: [
// //         Text(
// //           title,
// //           style: TextStyle(fontWeight: FontWeight.bold),
// //         ),
// //         Text(
// //           'Value: $value',
// //           style: TextStyle(fontSize: 18),
// //         ),
// //         Divider(),
// //       ],
// //     );
// //   }
// //
// //   String formatValue(double value) =>
// //       value >= 1000 ? '${(value / 1000).toStringAsFixed(2)}kW' : '${(value / 1000).toStringAsFixed(2)}kW';
// // }
// //
// // class MyAppsssss extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     return View();
// //   }
// // }
