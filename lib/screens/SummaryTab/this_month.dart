import 'package:connectivity/connectivity.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:high_chart/high_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';


class DataControllerForThisMonth extends GetxController {
  var isLoading = true.obs;
  var pieChartData = ''.obs;
  var data = <String, List<double>>{}.obs;
  DateTime startDate = DateTime.now().subtract(Duration(days: 1));
  var hasError = false.obs;
  RxString errorMessage = ''.obs;
  var chartData = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchChartData();
  }
  void resetController() {
    isLoading(true);  // Assuming default is loading
    data(<String, List<double>>{});  // Clear all data
    errorMessage('');  // Clear any error messages
    startDate = DateTime.now().subtract(Duration(days: 1));  // Reset the start date
  }

  Future<void> fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUsername = prefs.getString('username');
    isLoading(true);
    DateTime now = DateTime.now();
    DateTime endDate = DateTime(now.year, now.month, now.day); // Ensures the time is set to 00:00:00 of today
    // Set startDate to the first day of the current month
    DateTime startDate = DateTime(now.year, now.month, 1);

    // Format the dates to 'YYYY-MM-DD' format
    String formattedStartDate = "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}";
    String formattedEndDate = "${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}";

    final Uri uri = Uri.parse('http://203.135.63.47:8000/data?username=$storedUsername&mode=hour&start=$formattedStartDate&end=$formattedEndDate');

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
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
        this.startDate = startDate;
      } else {
        print('Failed to load data with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to load data with error: $e');
    } finally {
      isLoading(false);
    }
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
    DateTime now = DateTime.now();
    DateTime endDate = DateTime(now.year, now.month, now.day); // Ensures the time is set to 00:00:00 of today
    // Set startDate to the first day of the current month
    DateTime startDate = DateTime(now.year, now.month, 1);
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
          "pointWidth": 15,
          "borderRadius": 5
        }
      },
      'series': series
    });
  }

  String parsePieChartData(Map<String, dynamic> jsonResponse) {
    List<dynamic> data = [];
    double total = 0;

    // Calculate total to compute percentages
    jsonResponse['data'].forEach((key, value) {
      if (key.endsWith('_[kW]')) {
        double sum = (value as List).fold(0, (prev, item) => prev + (item / 1000));
        total += sum;
      }
    });

    // Construct the data array for the pie chart
    jsonResponse['data'].forEach((key, value) {
      if (key.endsWith('_[kW]')) {
        double sum = (value as List).fold(0, (prev, item) => prev + (item / 1000));
        double percentage = (sum / total) * 100;
        data.add({
          'name': key.replaceAll('_[kW]', ''),
          'y': sum,
          'percentage': percentage  // Store percentage for display
        });
      }
    });

    return json.encode({
      'chart': {'type': 'pie'},
      "title": {"text": 'Appliance Share'},
      'tooltip': {
        // Tooltip shows only the value in kWh
        "pointFormat": '<b>{point.y:.1f} kWh</b>'
      },
      'plotOptions': {
        'pie': {
          'allowPointSelect': true,
          'cursor': 'pointer',
          'dataLabels': {
            'enabled': true,
            // Display only percentage outside the slices
            'format': '{point.percentage:.1f}%',
            'style': {
              'color': 'black'  // Change as needed to fit your app's theme
            }
          },
          'showInLegend': true  // Ensure the legend is shown
        }
      },
      'series': [{
        'name': 'Energy',
        'colorByPoint': true,
        'data': data
      }]
    });
  }




















}













class DataViewForThisMonth extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final DataControllerForThisMonth controller = Get.put(DataControllerForThisMonth());

    return Obx(() {
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
// import '../../controller/Summary_Controller/Data_for_this_month_controller.dart';
//
//
//
//
//
// class DataViewForThisMonth extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final DataControllerForThisMonth controller = Get.put(DataControllerForThisMonth());
//
//     return Obx(() {
//       if (controller.isLoading.value) {
//         return Center(child: CircularProgressIndicator());
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
//                   data: _prepareChartData(controller.data.value, controller.startDate), // Adjusted to use controller's data
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
//                     "https://code.highcharts.com/highcharts-more.js", // Needed for pie chart
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
//
//   String _preparePieChartData(Map<String, List<double>> data) {
//     List<Map<String, dynamic>> seriesData = [];
//     double total = data.values.expand((i) => i).reduce((a, b) => a + b);
//
//     data.forEach((key, value) {
//       double sum = value.fold(0, (previousValue, element) => previousValue + element);
//       seriesData.add({
//         "name": key.replaceAll('_[kW]', ''),
//         "y": sum,
//         "percentage": (sum / total) * 100 // Calculate the percentage for the legend
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
//
// }