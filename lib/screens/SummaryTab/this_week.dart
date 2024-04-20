import 'package:connectivity/connectivity.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:high_chart/high_chart.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WeekDataController extends GetxController {
  var isLoading = true.obs;
  var data = <String, List<double>>{}.obs;
  RxString errorMessage = ''.obs; // New observable for error messages
  DateTime startDate = DateTime.now().subtract(Duration(days: 1));

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }
  void resetController() {
    isLoading(true);  // Assuming default is loading
    data(<String, List<double>>{});  // Clear all data
    errorMessage('');  // Clear any error messages
    startDate = DateTime.now().subtract(Duration(days: 1));  // Reset the start date
  }


  // Future<void> fetchData() async {
  //   errorMessage.value = '';
  //   var connectivityResult = await Connectivity().checkConnectivity();
  //   if (connectivityResult == ConnectivityResult.none) {
  //     errorMessage.value = "No internet connection available.";
  //     isLoading(false);
  //     return;
  //   }
  //
  //   isLoading(true);
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? storedUsername = prefs.getString('username');
  //   if (storedUsername == null) {
  //     errorMessage.value = "No username found in preferences.";
  //     isLoading(false);
  //     return;
  //   }
  //
  //   DateTime endDate = DateTime.now().toUtc().add(Duration(hours: 5));  // Assuming UTC+5 for Pakistan
  //   DateTime startDate = DateTime.now().subtract(Duration(days: 7));
  //   String formattedStartDate = "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}";
  //   String formattedEndDate = "${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}";
  //
  //   final String appurl = 'http://203.135.63.47:8000/data?username=$storedUsername&mode=hour&start=$formattedStartDate&end=$formattedEndDate';
  //   final Uri uri = Uri.parse(appurl);
  //
  //   try {
  //     final response = await http.get(uri);
  //     if (response.statusCode == 200) {
  //       final jsonResponse = jsonDecode(response.body);
  //       if (jsonResponse.containsKey('error')) {
  //         errorMessage.value = jsonResponse['error'];
  //         isLoading(false);
  //         return;
  //       }
  //       final Map<String, dynamic> responseData = jsonResponse['data'];
  //       final Map<String, List<double>> processedData = {};
  //
  //       // Initialize data structure with zeros for all expected days and keys
  //       List<DateTime> dates = List.generate(
  //           endDate.difference(startDate).inDays + 1,
  //               (i) => startDate.add(Duration(days: i))
  //       );
  //       dates.forEach((date) {
  //         responseData.keys.forEach((key) {
  //           if (key.endsWith('_[kW]')) {
  //             processedData[key] ??= List.filled(dates.length, 0.0);
  //           }
  //         });
  //       });
  //
  //       // Fill the data structure with actual fetched data
  //       responseData.forEach((key, values) {
  //         if (key.endsWith('_[kW]')) {
  //           for (int i = 0; i < values.length; i++) {
  //             String dateTime = responseData['Date & Time'][i];
  //             String date = dateTime.split(' ')[0];
  //             int index = DateTime.parse(date).difference(startDate).inDays;
  //             double value = 0.0;
  //             if (values[i] != null && values[i] != 'NA' && values[i] != '') {
  //               value = double.tryParse(values[i].toString()) ?? 0.0;
  //             }
  //             processedData[key]![index] = value;
  //           }
  //         }
  //       });
  //
  //       data(processedData);
  //       this.startDate = startDate;  // Keep this updated if used in UI
  //     } else {
  //       errorMessage.value = 'Failed to load data with status code: ${response.statusCode}';
  //     }
  //   } catch (e) {
  //     errorMessage.value = 'Failed to load data with error: $e';
  //   } finally {
  //     isLoading(false);
  //   }
  // }

  Future<void> fetchData() async {
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

    // Adjust dates for potential time zone differences

    DateTime endDate = DateTime.now().toUtc().add(Duration(hours: 5)); // Assuming UTC+5 for Pakistan
    DateTime startDate = DateTime.now().subtract(Duration(days: 7));
    String formattedStartDate = "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}";
    String formattedEndDate = "${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}";

    final String appurl = 'http://203.135.63.47:8000/data?username=$storedUsername&mode=hour&start=$formattedStartDate&end=$formattedEndDate';
    final Uri uri = Uri.parse(appurl);

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse.containsKey('error')) {
          errorMessage.value = jsonResponse['error'];
          isLoading(false);
          return;
        }
        final Map<String, dynamic> responseData = jsonResponse['data'];
        final Map<String, List<double>> processedData = {};

        responseData.forEach((key, value) {
          if (key.endsWith('_[kW]')) {
            List<double> listValues = (value as List).map((item) {
              double val = 0.0;
              if (item != null && item != 'NA' && item != '') {
                val = double.tryParse(item.toString()) ?? 0.0;
              }
              return double.parse((val / 1000).toStringAsFixed(2));
            }).toList();
            processedData[key] = [];
            for (int i = 0; i < listValues.length; i += 24) {
              processedData[key]!.add(listValues.sublist(i, i + 24 > listValues.length ? listValues.length : i + 24).reduce((a, b) => a + b));
            }
          }
        });

        data(processedData);
        this.startDate = startDate; // Keep this updated if used in UI
      } else {
        errorMessage.value = 'Failed to load data with status code: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'Failed to load data with error: $e';
    } finally {
      isLoading(false);
    }
  }

}




class DataView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final WeekDataController controller = Get.put(WeekDataController());

    return Obx(() {
      if (controller.isLoading.value) {
        return Center(child: CircularProgressIndicator());
      }else if (controller.errorMessage.isNotEmpty) {
        return Center(child: Text(controller.errorMessage.value, style: TextStyle(color: Colors.red)));
      }


      else {
        return SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: HighCharts(
                  loader: const SizedBox(
                    width: 50,
                    height: 50,
                    child: Center(
                      child: Text('Loading...'),
                    ),
                  ),
                  data: _prepareChartData(controller.data.value, controller.startDate), // Adjusted to use controller's data
                  scripts: const [
                    "https://code.highcharts.com/highcharts.js",
                    "https://code.highcharts.com/modules/exporting.js",
                    "https://code.highcharts.com/modules/export-data.js",
                    "https://code.highcharts.com/modules/accessibility.js",
                  ],
                  size: const Size(400, 400),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: HighCharts(
                  loader: SizedBox(
                    width: 50,
                    height: 50,
                    child: Center(
                      child: Text('Loading...'),
                    ),
                  ),
                  data: _preparePieChartData(controller.data.value),
                  scripts: const [
                    "https://code.highcharts.com/highcharts.js",
                    "https://code.highcharts.com/modules/exporting.js",
                    "https://code.highcharts.com/modules/export-data.js",
                    "https://code.highcharts.com/highcharts-more.js", // Needed for pie chart
                    "https://code.highcharts.com/modules/accessibility.js",
                  ],
                  size: const Size(400, 400),
                ),
              ),
            ],
          ),
        );
      }
    });
  }

  String _prepareChartData(Map<String, List<double>> data, DateTime startDate) {
    List<Map<String, dynamic>> series = [];
    data.forEach((key, dailySums) {
      List<dynamic> data = [];
      for (int i = 0; i < dailySums.length; i++) {
        DateTime date = startDate.add(Duration(days: i));
        DateTime pakistaniDateTime = date.add(Duration(hours: 5));
        data.add([pakistaniDateTime.millisecondsSinceEpoch, dailySums[i]]);
      }
      series.add({
        "name": key.replaceAll('_[kW]', ''),
        "data": data,
        "visible": !(key.startsWith('Main') || key.startsWith('Generator')),
      });
    });

    return jsonEncode({
      "chart": {"type": 'column'},
      "title": {"text": 'Daily Breakdown'},
      "xAxis": {
        "type": 'datetime',
        "dateTimeLabelFormats": {"day": '%e. %b'}
      },
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
          "pointWidth": 25, // Specify the width of the column points
          "borderRadius": 5 // Specify the border radius for rounded corners
        }
      },
      "series": series
    });
  }


  String _preparePieChartData(Map<String, List<double>> data) {
    List<Map<String, dynamic>> seriesData = [];
    double total = data.values.expand((i) => i).reduce((a, b) => a + b);

    data.forEach((key, value) {
      double sum = value.fold(0, (previousValue, element) => previousValue + element);
      seriesData.add({
        "name": key.replaceAll('_[kW]', ''),
        "y": sum,
        "percentage": (sum / total) * 100 // Calculate the percentage for the legend
      });
    });

    return '''
    {
      chart: {
        plotBackgroundColor: null,
        plotBorderWidth: null,
        plotShadow: false,
        type: 'pie'
      },
      title: {
        text: 'Appliance Share'
      },
       tooltip: {
      formatter: function () {
        return '<b>' + this.point.name + '</b>: ' + this.y.toFixed(2) + ' kWh'; // Display values in kilowatts with two decimal places
      }
    },
      // tooltip: {
      //   pointFormat: '{series.name}: <b>{point.y:.1f} kWh</b> ({point.percentage:.2f}%)'
      // },
      plotOptions: {
      pie: {
        allowPointSelect: true,
        cursor: 'pointer',
        dataLabels: {
          enabled: true,
          distance: 10,
          format: '{point.percentage:.1f}%',
        },
        showInLegend: true
      }
    },
      series: [{
        name: 'Energy Source',
        colorByPoint: true,
        data: ${jsonEncode(seriesData)}
      }]
    }
  ''';
  }

}


// import 'package:get/get.dart';
//
// import 'dart:convert';
// import 'package:flutter/material.dart';
//
// import 'package:high_chart/high_chart.dart';
//
// import '../../controller/Summary_Controller/Week_Data_Chart_Controller.dart';
//
// class  WeekDataView extends StatefulWidget {
//   @override
//   State<WeekDataView> createState() => _WeekDataViewState();
// }
//
// class _WeekDataViewState extends State<WeekDataView> {
//   @override
//   Widget build(BuildContext context) {
//     final WeekDataController controller = Get.put(WeekDataController());
//
//     return Obx(() {
//       if (controller.isLoading.value) {
//         return const Center(child: CircularProgressIndicator());
//       } else if (controller.errorMessage.isNotEmpty) {
//         return Center(
//             child: Text(controller.errorMessage.value,
//                 style: TextStyle(color: Colors.red)));
//       } else {
//         return SingleChildScrollView(
//           child: Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: HighCharts(
//                   loader: const SizedBox(
//                     width: 50,
//                     height: 50,
//                     child: Center(
//                       child: Text('Loading...'),
//                     ),
//                   ),
//                   data: _prepareChartData(
//                       controller.data.value, controller.startDate),
//                   // Adjusted to use controller's data
//                   scripts: const [
//                     "https://code.highcharts.com/highcharts.js",
//                     "https://code.highcharts.com/modules/exporting.js",
//                     "https://code.highcharts.com/modules/export-data.js",
//                     "https://code.highcharts.com/modules/accessibility.js",
//                   ],
//                   size: const Size(400, 400),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: HighCharts(
//                   loader: const SizedBox(
//                     width: 50,
//                     height: 50,
//                     child: Center(
//                       child: Text('Loading...'),
//                     ),
//                   ),
//                   data: _preparePieChartData(controller.data.value),
//                   scripts: const [
//                     "https://code.highcharts.com/highcharts.js",
//                     "https://code.highcharts.com/modules/exporting.js",
//                     "https://code.highcharts.com/modules/export-data.js",
//                     "https://code.highcharts.com/highcharts-more.js",
//                     // Needed for pie chart
//                     "https://code.highcharts.com/modules/accessibility.js",
//                   ],
//                   size: const Size(400, 400),
//                 ),
//               ),
//             ],
//           ),
//         );
//       }
//     });
//   }
//
//   String _prepareChartData(Map<String, List<double>> data, DateTime startDate) {
//     List<Map<String, dynamic>> series = [];
//     data.forEach((key, dailySums) {
//       List<dynamic> data = [];
//       for (int i = 0; i < dailySums.length; i++) {
//         DateTime date = startDate.add(Duration(days: i));
//         DateTime pakistaniDateTime = date.add(Duration(hours: 5));
//         data.add([pakistaniDateTime.millisecondsSinceEpoch, dailySums[i]]);
//       }
//       series.add({
//         "name": key.replaceAll('_[kW]', ''),
//         "data": data,
//         "visible": !(key.startsWith('Main') || key.startsWith('Generator')),
//       });
//     });
//
//     return jsonEncode({
//       "chart": {"type": 'column'},
//       "title": {"text": 'Daily Breakdown'},
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
//         "headerFormat": '{point.key:%A, %e %b %Y}</b><br/>',
//         "pointFormat": '<b>{series.name}: {point.y:.2f} kWh</b>'
//       },
//       "plotOptions": {
//         "column": {
//           "stacking": 'normal',
//           "dataLabels": {"enabled": false},
//           "pointWidth": 25, // Specify the width of the column points
//           "borderRadius": 5 // Specify the border radius for rounded corners
//         }
//       },
//       "series": series
//     });
//   }
//
//   String _preparePieChartData(Map<String, List<double>> data) {
//     List<Map<String, dynamic>> seriesData = [];
//     double total = data.values.expand((i) => i).reduce((a, b) => a + b);
//
//     data.forEach((key, value) {
//       double sum =
//           value.fold(0, (previousValue, element) => previousValue + element);
//       seriesData.add({
//         "name": key.replaceAll('_[kW]', ''),
//         "y": sum,
//         "percentage": (sum / total) * 100
//         // Calculate the percentage for the legend
//       });
//     });
//
//     return '''
//     {
//       chart: {
//         plotBackgroundColor: null,
//         plotBorderWidth: null,
//         plotShadow: false,
//         type: 'pie'
//       },
//       title: {
//         text: 'Appliance Share'
//       },
//        tooltip: {
//       formatter: function () {
//         return '<b>' + this.point.name + '</b>: ' + this.y.toFixed(2) + ' kWh'; // Display values in kilowatts with two decimal places
//       }
//     },
//       // tooltip: {
//       //   pointFormat: '{series.name}: <b>{point.y:.1f} kWh</b> ({point.percentage:.2f}%)'
//       // },
//       plotOptions: {
//       pie: {
//         allowPointSelect: true,
//         cursor: 'pointer',
//         dataLabels: {
//           enabled: true,
//           distance: 10,
//           format: '{point.percentage:.1f}%',
//         },
//         showInLegend: true
//       }
//     },
//       series: [{
//         name: 'Energy Source',
//         colorByPoint: true,
//         data: ${jsonEncode(seriesData)}
//       }]
//     }
//   ''';
//   }
// }
//
// // class WeekDataController extends GetxController {
// //   var isLoading = true.obs;
// //   var data = <String, List<double>>{}.obs;
// //   DateTime startDate = DateTime.now().subtract(Duration(days: 1));
// //
// //   @override
// //   void onInit() {
// //     super.onInit();
// //     fetchData();
// //   }
// //
//   Future<void> fetchData() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? storedUsername = prefs.getString('username');
//     isLoading(true);
//     DateTime endDate = DateTime.now();
//     DateTime startDate = endDate.subtract(Duration(days: 6));
//     String formattedStartDate = "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}";
//     String formattedEndDate = "${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}";
//
//     final Uri uri = Uri.parse('http://203.135.63.47:8000/data?username=$storedUsername&mode=hour&start=$formattedStartDate&end=$formattedEndDate');
//
//     try {
//       final response = await http.get(uri);
//       if (response.statusCode == 200) {
//         final jsonResponse = jsonDecode(response.body);
//         final Map<String, dynamic> responseData = jsonResponse['data'];
//         final Map<String, List<double>> processedData = {};
//
//         responseData.forEach((key, value) {
//           if (key.endsWith('_[kW]')) {
//             List<double> listValues = (value as List).map((item) {
//               double val = 0.0;
//               if (item != null && item != 'NA' && item != '') {
//                 val = double.tryParse(item.toString()) ?? 0.0;
//               }
//               return double.parse((val / 1000).toStringAsFixed(2)); // Corrected conversion logic here
//             }).toList();
//             processedData[key] = [];
//             for (int i = 0; i < listValues.length; i += 24) {
//               processedData[key]!.add(listValues.sublist(i, i + 24 > listValues.length ? listValues.length : i + 24).reduce((a, b) => a + b));
//             }
//           }
//         });
//
//         data(processedData);
//         this.startDate = startDate;
//       } else {
//         print('Failed to load data with status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Failed to load data with error: $e');
//     } finally {
//       isLoading(false);
//     }
//   }
// // }
