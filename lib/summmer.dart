import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:high_chart/high_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChartController extends GetxController {
  var chartData = ''.obs;
  var pieChartData = ''.obs;  // Observable for pie chart data
  var isLoading = true.obs;
  var hasError = false.obs;
  RxString errorMessage = ''.obs;
  DateTime startDate = DateTime.now().subtract(Duration(days: 1));
  @override
  void onInit() {
    fetchChartData();
    super.onInit();
  }
  void resetController() {
    isLoading(true);  // Assuming default is loading
    // Clear all data
    errorMessage('');  // Clear any error messages
    startDate = DateTime.now().subtract(Duration(days: 1));  // Reset the start date
  }


  void fetchChartData() async {
    errorMessage.value = '';
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      errorMessage.value = "No internet connection available.";
      isLoading(false);
      return;
    }

    isLoading(true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUsername = prefs.getString('username');
    if (storedUsername == null) {
      errorMessage.value = "No username found in preferences.";
      isLoading(false);
      return;
    }
    DateTime endDate = DateTime.now().toUtc().add(Duration(hours: 5));
    DateTime startDate = DateTime.now().subtract(Duration(days: 7));
    String formattedStartDate = "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}";
    String formattedEndDate = "${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}";

    try {
      isLoading(true);
      final response = await http.get(Uri.parse('http://203.135.63.47:8000/data?username=$storedUsername&mode=day&start=$formattedStartDate&end=$formattedEndDate'));
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        chartData(parseChartData(jsonResponse));
        pieChartData(parsePieChartData(jsonResponse));  // Generate pie chart data
      } else {
        errorMessage.value = 'Failed to load data with status code: ${response.statusCode}';
        hasError(true);
        throw Exception('Failed to load chart data');
      }
    } catch (e) {
      errorMessage.value = 'Failed to load data with error: $e';
      hasError(true);
    } finally {
      isLoading(false);
    }
  }

  String parseChartData(Map<String, dynamic> jsonResponse) {
    List<String> categories = List<String>.from(jsonResponse['data']['Date & Time']);
    List<dynamic> series = [];
    jsonResponse['data'].forEach((key, value) {
      if (key.endsWith('_[kW]')) {
        List convertedData = (value as List).map((item) => item is int ? item.toDouble() : item / 1000).toList();
        series.add({'name': key.replaceAll('_[kW]', ''), 'data': convertedData,
          "visible": !(key.startsWith('Main') || key.startsWith('Generator')),
        });
      }
    });

    return json.encode({
      'chart': {'type': 'column'},
      "title": {"text": 'Daily Breakdown'},
      'xAxis': {'categories': categories},
      "yAxis": {
        "min": 0,
        "title": {"text": 'Energy (kWh)'},
        "stackLabels": {"enabled": false}
      },
      "tooltip": {
        "headerFormat": '{point.key:%A, %e %b %Y}</b><br/>',
        "pointFormat": '<b>{series.name}: {point.y:.2f} kWh</b>'
      },
      "plotOptions": {
        "column": {
          "stacking": 'normal',
          "dataLabels": {"enabled": false},
          "pointWidth": 25,
          "borderRadius": 5
        }
      },
      'series': series
    });
  }

  String parsePieChartData(Map<String, dynamic> jsonResponse) {
    List<dynamic> data = [];
    jsonResponse['data'].forEach((key, value) {
      if (key.endsWith('_[kW]')) {
        double total = (value as List).fold(0, (sum, item) => sum + (item / 1000));
        data.add({'name': key.replaceAll('_[kW]', ''), 'y': total});
      }
    });

    return json.encode({
      'chart': {'type': 'pie'},
      "title": {"text": 'Energy Distribution'},
      'tooltip': {
        "pointFormat": '{series.name}: <b>{point.y:.1f} kWh</b>'
      },
      'plotOptions': {
        'pie': {
          'allowPointSelect': true,
          'cursor': 'pointer',
          'dataLabels': {'enabled': true, 'format': '<b>{point.name}</b>: {point.y:.1f} kWh'}
        }
      },
      'series': [{'name': 'Energy', 'colorByPoint': true, 'data': data}]
    });
  }
}

class ChartPage extends StatelessWidget {
  const ChartPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ChartController controller = Get.put(ChartController());

    return Scaffold(
      appBar: AppBar(
        title: Text('Energy Data Visualization'),
      ),
      body: Obx(() {
        if (controller.isLoading.isTrue) {
          return Center(child: CircularProgressIndicator());
        } else if (controller.hasError.isTrue) {
          return Center(child: Text('Error loading data.'));
        }
        else if (controller.errorMessage.isNotEmpty) {
          return Center(child: Text(controller.errorMessage.value, style: TextStyle(color: Colors.red)));
        } else {
          return SingleChildScrollView(
            child: Column(
              children: [
                HighCharts(
                  loader: const SizedBox(
                    width: 50,
                    height: 50,
                    child: Center(
                      child: Text('Loading...'),
                    ),
                  ),
                  size: Size(MediaQuery.of(context).size.width, 400),
                  data: controller.chartData.value,
                  scripts: const [
                    "https://code.highcharts.com/highcharts.js",
                    "https://code.highcharts.com/modules/exporting.js",
                    "https://code.highcharts.com/modules/export-data.js",
                    "https://code.highcharts.com/highcharts-more.js",
                    "https://code.highcharts.com/modules/accessibility.js",
                  ],
                ),
                SizedBox(height: 20),
                HighCharts(
                  loader: const SizedBox(
                    width: 50,
                    height: 50,
                    child: Center(
                      child: Text('Loading...'),
                    ),
                  ),
                  size: Size(MediaQuery.of(context).size.width, 400),
                  data: controller.pieChartData.value,
                  scripts: const [
                    "https://code.highcharts.com/highcharts.js",
                    "https://code.highcharts.com/modules/exporting.js",
                    "https://code.highcharts.com/modules/export-data.js",
                    "https://code.highcharts.com/highcharts-more.js",
                    "https://code.highcharts.com/modules/accessibility.js",
                  ],
                ),
              ],
            ),
          );
        }
      }),
    );
  }
}






// import 'package:flutter/material.dart';
// import 'package:high_chart/high_chart.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
//
// class StackedColumnChartdfd extends StatefulWidget {
//   const StackedColumnChartdfd({Key? key}) : super(key: key);
//
//   @override
//   _StackedColumnChartdfdState createState() => _StackedColumnChartdfdState();
// }
//
// class _StackedColumnChartdfdState extends State<StackedColumnChartdfd> {
//   late Future<String> _futureChartData;
//
//   @override
//   void initState() {
//     super.initState();
//     _futureChartData = _fetchChartData();
//   }
//
//   Future<String> _fetchChartData() async {
//     final response = await http.get(Uri.parse('http://203.135.63.47:8000/data?username=ppjiq&mode=day&start=2024-04-16&end=2024-04-23'));
//
//     if (response.statusCode == 200) {
//       var jsonResponse = json.decode(response.body);
//       return _parseChartData(jsonResponse);
//     } else {
//       throw Exception('Failed to load chart data');
//     }
//   }
//
//   String _parseChartData(Map<String, dynamic> jsonResponse) {
//     List<String> categories = List<String>.from(jsonResponse['data']['Date & Time']);
//     List<dynamic> series = [];
//
//     jsonResponse['data'].forEach((key, value) {
//       if (key.endsWith('_[kW]')) {
//         // Convert all numbers to double to avoid type issues
//         List convertedData = (value as List).map((item) {
//           return item is int ? item.toDouble() : item;
//         }).toList();
//
//         series.add({
//           'name': key.replaceAll('_[kW]', ''),
//           'data': convertedData
//         });
//       }
//     });
//
//     return json.encode({
//       'chart': {'type': 'column'},
//       'title': {'text': 'Energy Consumption [kW]'},
//       'xAxis': {'categories': categories},
//       'yAxis': {'min': 0, 'title': {'text': 'Energy (kW)'}},
//       'tooltip': {'pointFormat': '{series.name}: {point.y}<br/>Total: {point.stackTotal}'},
//       'plotOptions': {
//         'column': {
//           'stacking': 'normal',
//           'dataLabels': {'enabled': true, 'color': 'white'}
//         }
//       },
//       'series': series
//     });
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: FutureBuilder<String>(
//         future: _futureChartData,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.done) {
//             if (snapshot.hasError) {
//               return Text('Error: ${snapshot.error}');
//             } else {
//               return Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
//                 child: HighCharts(
//                   loader: const SizedBox(
//                     width: 200,
//                     child: LinearProgressIndicator(),
//                   ),
//                   size: const Size(400, 400),
//                   data: snapshot.data!,
//                   scripts: const [
//                     "https://code.highcharts.com/highcharts.js",
//                     "https://code.highcharts.com/modules/exporting.js"
//                   ],
//                 ),
//               );
//             }
//           } else {
//             return const CircularProgressIndicator();
//           }
//         },
//       ),
//     );
//   }
// }

// import 'package:get/get.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// class ApiController extends GetxController {
//   var isLoading = true.obs;
//   var dataMap = {}.obs;
//   var errorMessage = ''.obs;
//
//   @override
//   void onInit() {
//     fetchData();
//     super.onInit();
//   }
//
//   Future<void> fetchData() async {
//     try {
//       isLoading(true);
//
//       // Calculate the date range for the last seven days
//       DateTime endDate = DateTime.now();
//       DateTime startDate = endDate.subtract(Duration(days: 6));
//       String formattedEndDate = '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
//       String formattedStartDate = '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
//
//       // Update the API URL with the dynamic dates
//       final response = await http.get(Uri.parse('http://203.135.63.47:8000/data?username=ppjiq&mode=day&start=2024-04-16&end=2024-04-23'));
//       if (response.statusCode == 200) {
//         dataMap(json.decode(response.body));
//       } else {
//         throw Exception('Failed to load data');
//       }
//     } catch (e) {
//       errorMessage(e.toString());
//     } finally {
//       isLoading(false);
//     }
//   }
// }
//
//
//
// class ApiDataWidget extends StatelessWidget {
//   final ApiController controller = Get.put(ApiController());
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Obx(() {
//         if (controller.isLoading.value) {
//           return Center(child: CircularProgressIndicator());
//         } else if (controller.errorMessage.isNotEmpty) {
//           return Center(child: Text("Error: ${controller.errorMessage}"));
//         }
//         return ListView.builder(
//           itemCount: controller.dataMap['data']['Date & Time'].length,
//           itemBuilder: (context, index) {
//             var date = controller.dataMap['data']['Date & Time'][index];
//             List<Widget> tiles = [Text(date, style: TextStyle(fontWeight: FontWeight.bold))];
//             controller.dataMap['data'].forEach((key, value) {
//               if (key.endsWith('_[kW]')) {
//                 tiles.add(ListTile(
//                   title: Text('$key: ${value[index]} kW'),
//                 ));
//               }
//             });
//             return Column(children: tiles);
//           },
//         );
//       }),
//     );
//   }
// }

















// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:high_chart/high_chart.dart';
//
// class ApiController extends GetxController {
//   var isLoading = true.obs;
//   var dataMap = <String, dynamic>{}.obs;
//   var errorMessage = ''.obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     fetchData();
//   }
//
//   Future<void> fetchData() async {
//     isLoading(true);
//     try {
//       DateTime now = DateTime.now();
//       DateTime startDate = now.subtract(Duration(days: 6));
//       String startDateFormatted = '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
//       String endDateFormatted = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
//
//       final uri = Uri.parse('http://203.135.63.47:8000/data?username=ppjiq&mode=day&start=$startDateFormatted&end=$endDateFormatted');
//       final response = await http.get(uri);
//
//       if (response.statusCode == 200) {
//         dataMap(json.decode(response.body) as Map<String, dynamic>);
//       } else {
//         throw Exception('Failed to load data');
//       }
//     } catch (e) {
//       errorMessage(e.toString());
//     } finally {
//       isLoading(false);
//     }
//   }
// }
//
// class ApiDataWidget extends StatelessWidget {
//   final ApiController controller = Get.put(ApiController());
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Obx(() {
//         if (controller.isLoading.value) {
//           return Center(child: CircularProgressIndicator());
//         } else if (controller.errorMessage.isNotEmpty) {
//           return Center(child: Text("Error: ${controller.errorMessage}"));
//         }
//
//         return Column(
//           children: [
//             Expanded(
//               child: HighCharts(
//                 loader: SizedBox(
//                   width: 50,
//                   height: 50,
//                   child: CircularProgressIndicator(),
//                 ),
//                 size: Size(MediaQuery.of(context).size.width, 400),
//                 data: _createChartData(controller.dataMap.value),
//                 scripts: [
//                   "https://code.highcharts.com/highcharts.js",
//                   "https://code.highcharts.com/modules/series-label.js",
//                   "https://code.highcharts.com/modules/exporting.js",
//                   "https://code.highcharts.com/modules/export-data.js",
//                   "https://code.highcharts.com/modules/accessibility.js",
//                 ],
//               ),
//             ),
//           ],
//         );
//       }),
//     );
//   }
//
//   String _createChartData(Map<String, dynamic> data) {
//     List<Map<String, dynamic>> series = [];
//
//     data['data'].forEach((key, values) {
//       if (key.endsWith('_[kW]')) {
//         List<dynamic> formattedData = [];
//         List<dynamic> dateStrings = data['data']['Date & Time'] ?? [];
//         for (int i = 0; i < dateStrings.length; i++) {
//           DateTime utcDate = DateTime.parse(dateStrings[i]);
//           DateTime pakistaniDateTime = utcDate.add(Duration(hours: 5));  // Adjusting to Pakistani time
//           // Assuming `values` contains the daily sums in the same order as dates
//           formattedData.add([
//             pakistaniDateTime.millisecondsSinceEpoch, // x value: time in milliseconds
//             values[i]  // y value: energy value for that date
//           ]);
//         }
//
//         series.add({
//           "name": key.replaceAll('_[kW]', ''),  // Clean the name
//           "data": formattedData,
//           "visible": !(key.startsWith('Main') || key.startsWith('Generator'))  // Hide series for 'Main' or 'Generator'
//         });
//       }
//     });
//
//     return jsonEncode({
//       "chart": {"type": 'column'},
//       "title": {"text": 'Daily Energy Consumption Breakdown'},
//       "xAxis": {
//         "type": 'datetime',
//         "dateTimeLabelFormats": {"day": '%e. %b'}
//       },
//       "yAxis": {
//         "min": 0,
//         "title": {"text": 'Energy (kWh)'},
//         "stackLabels": {"enabled": false}
//       },
//       "tooltip": {
//         "headerFormat": '{point.key:%A, %e %b %Y}<br/>',
//         "pointFormat": '<b>{series.name}: {point.y:.2f} kWh</b>'
//       },
//       "plotOptions": {
//         "column": {
//           "stacking": 'normal',
//           "dataLabels": {"enabled": false},
//           "pointWidth": 25,
//           "borderRadius": 5
//         }
//       },
//       "series": series
//     });
//   }
//
//
// }
