import 'package:flutter/cupertino.dart';
import 'package:high_chart/high_chart.dart';

import 'controller/datacontroller.dart';

class PieChart extends StatelessWidget {
  final DataControllers controllers;

  PieChart({Key? key, required this.controllers}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      child: Column(
        children: [
          SizedBox(height: 10),
          HighCharts(
            loader: const SizedBox(
              child: Text('Loading'),
            ),
            size: const Size(400, 400),
            data: _getPieChartData(),
            scripts: const ["https://code.highcharts.com/highcharts.js"],
          ),
        ],
      ),
    );
  }
  String _getPieChartData() {
    List<Map<String, dynamic>> chartData = controllers.kwData;

    if (chartData.isEmpty) {
      return '''
    {
      chart: {
        type: 'pie',
        height: 400,
      },
      title: {
        text: 'No Data Available'
      },
      series: []
    }
  ''';
    }

    Map<String, double> pieChartData = {};

    for (var entry in chartData) {
      if (entry.containsKey('data')) {
        List<Map<String, dynamic>> data = entry['data'];

        if (data.isNotEmpty) {
          data.forEach((item) {
            if (item.containsKey('prefixName') && item.containsKey('values')) {
              String prefixName = item['prefixName'];
              List<double> values = item['values'];

              if (values.isNotEmpty) {
                double sum = values.reduce((value, element) => value + element);

                if (prefixName != 'Main_') {
                  pieChartData.update(prefixName, (value) => value + sum, ifAbsent: () => sum);
                }
              }
            }
          });
        }
      }
    }

    if (pieChartData.isEmpty) {
      return '''
    {
      chart: {
        type: 'pie',
        height: 400,
      },
      title: {
        text: 'No Data Available'
      },
      tooltip: {
        valueSuffix: '%'
      },
      series: []
    }
  ''';
    }

    String seriesConfig = '''
  {
    name: 'Percentage',
    colorByPoint: true,
    data: [
''';

    pieChartData.forEach((name, value) {
      // Convert value to kilowatts
      double valueInKW = value / 1000;

      seriesConfig += '''
    {
      name: '$name',
      y: $valueInKW
    },
  ''';
    });

    seriesConfig += '''
    ]
  }
''';

    // Remove underscores from the legend names
    seriesConfig = seriesConfig.replaceAll('_', ' ');

    return '''
  {
    chart: {
      type: 'pie',
      height: 400,
    },
    title: {
      text: 'Appliance Share'
    },
    tooltip: {
      formatter: function () {
        return '<b>' + this.point.name + '</b>: ' + this.y.toFixed(2) + ' kWh'; // Display values in kilowatts with two decimal places
      }
    },
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
    series: [$seriesConfig]
  }
''';
  }
  // String _getPieChartData() {
  //   List<Map<String, dynamic>> chartData = controllers.kwData;
  //
  //   if (chartData.isEmpty) {
  //     return '''
  //     {
  //       chart: {
  //         type: 'pie',
  //         height: 400,
  //       },
  //       title: {
  //         text: 'No Data Available'
  //       },
  //       series: []
  //     }
  //   ''';
  //   }
  //
  //   Map<String, double> pieChartData = {};
  //
  //   for (var entry in chartData) {
  //     if (entry.containsKey('data')) {
  //       List<Map<String, dynamic>> data = entry['data'];
  //
  //       if (data.isNotEmpty) {
  //         data.forEach((item) {
  //           if (item.containsKey('prefixName') && item.containsKey('values')) {
  //             String prefixName = item['prefixName'];
  //             List<double> values = item['values'];
  //
  //             if (values.isNotEmpty) {
  //               double sum = values.reduce((value, element) => value + element);
  //
  //               if (prefixName != 'Main_') {
  //                 pieChartData.update(prefixName, (value) => value + sum, ifAbsent: () => sum);
  //               }
  //             }
  //           }
  //         });
  //       }
  //     }
  //   }
  //
  //   if (pieChartData.isEmpty) {
  //     return '''
  //     {
  //       chart: {
  //         type: 'pie',
  //         height: 400,
  //       },
  //       title: {
  //         text: 'No Data Available'
  //       },
  //       tooltip: {
  //         valueSuffix: '%'
  //       },
  //       series: []
  //     }
  //   ''';
  //   }
  //
  //   String seriesConfig = '''
  //   {
  //     name: 'Percentage',
  //     colorByPoint: true,
  //     data: [
  // ''';
  //
  //   pieChartData.forEach((name, value) {
  //     // Convert value to kilowatts
  //     double valueInKW = value / 1000;
  //
  //     seriesConfig += '''
  //     {
  //       name: '$name',
  //       y: $valueInKW
  //     },
  //   ''';
  //   });
  //
  //   seriesConfig += '''
  //     ]
  //   }
  // ''';
  //
  //   return '''
  //   {
  //     chart: {
  //       type: 'pie',
  //       height: 400,
  //     },
  //     title: {
  //       text: 'Appliance Share'
  //     },
  //     tooltip: {
  //       formatter: function () {
  //         return '<b>' + this.point.name + '</b>: ' + this.y.toFixed(2) + ' KW'; // Display values in kilowatts with two decimal places
  //       }
  //     },
  //     plotOptions: {
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
  //     series: [$seriesConfig]
  //   }
  // ''';
  // }


// String _getPieChartData() {
  //   List<Map<String, dynamic>> chartData = controllers.kwData;
  //
  //   if (chartData.isEmpty) {
  //     return '''
  //       {
  //         chart: {
  //           type: 'pie',
  //           height: 400,
  //         },
  //         title: {
  //           text: 'No Data Available'
  //         },
  //         series: []
  //       }
  //     ''';
  //   }
  //
  //   Map<String, double> pieChartData = {};
  //
  //   for (var entry in chartData) {
  //     if (entry.containsKey('data')) {
  //       List<Map<String, dynamic>> data = entry['data'];
  //
  //       if (data.isNotEmpty) {
  //         data.forEach((item) {
  //           if (item.containsKey('prefixName') && item.containsKey('values')) {
  //             String prefixName = item['prefixName'];
  //             List<double> values = item['values'];
  //
  //             if (values.isNotEmpty) {
  //               double sum = values.reduce((value, element) => value + element);
  //
  //               if (prefixName != 'Main_') {
  //                 pieChartData.update(prefixName, (value) => value + sum, ifAbsent: () => sum);
  //               }
  //             }
  //           }
  //         });
  //       }
  //     }
  //   }
  //
  //   if (pieChartData.isEmpty) {
  //     return '''
  //       {
  //         chart: {
  //           type: 'pie',
  //           height: 400,
  //         },
  //         title: {
  //           text: 'No Data Available'
  //         },
  //          tooltip: {
  //       valueSuffix: '%'
  //   },
  //         series: []
  //       }
  //     ''';
  //   }
  //
  //   String seriesConfig = '''
  //     {
  //       name: 'Percentage',
  //       colorByPoint: true,
  //       data: [
  //   ''';
  //
  //   pieChartData.forEach((name, value) {
  //     seriesConfig += '''
  //       {
  //         name: '$name',
  //         y: $value
  //       },
  //     ''';
  //   });
  //
  //   seriesConfig += '''
  //       ]
  //     }
  //   ''';
  //
  //   return '''
  //     {
  //       chart: {
  //         type: 'pie',
  //         height: 400,
  //       },
  //       title: {
  //         text: 'Appliance Share'
  //       },
  //       tooltip: {
  //         formatter: function () {
  //           return '<b>' + this.point.name + '</b>: ' + this.y + ' %';
  //         }
  //       },
  //       plotOptions: {
  //         pie: {
  //           allowPointSelect: true,
  //           cursor: 'pointer',
  //           dataLabels: {
  //             enabled: true,
  //             distance: 10,
  //             format: '{point.percentage:.1f}%',
  //           },
  //           showInLegend: true
  //         }
  //       },
  //       series: [$seriesConfig]
  //     }
  //   ''';
  // }
}





// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:get/get_rx/src/rx_types/rx_types.dart';
// import 'package:get/get_state_manager/src/simple/get_controllers.dart';
// import 'package:http/http.dart' as http;
// import 'package:high_chart/high_chart.dart';
//
// import 'controller/datacontroller.dart';
//
// class PieChart extends StatelessWidget {
//   final DataControllers controllers;
//
//   PieChart({Key? key, required this.controllers}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
//       child: HighCharts(
//         loader: const SizedBox(
//           child: Text('Loading'),
//         ),
//         size: const Size(400, 400),
//         data: _getPieChartData(),
//         scripts: const ["https://code.highcharts.com/highcharts.js"],
//       ),
//     );
//   }
//
//   String _getPieChartData() {
//     List<Map<String, dynamic>> chartData = controllers.kwData;
//
//     // Extract data for the pie chart
//     Map<String, double> pieChartData = {};
//
//     for (var entry in chartData) {
//       List<Map<String, dynamic>> data = entry['data'];
//
//       data.forEach((item) {
//         String prefixName = item['prefixName'];
//         List<double> values = item['values'];
//
//         // Exclude 'Main_[kW]' from the calculation
//         if (!prefixName.startsWith('Main_')) {
//           double sum = values.reduce((value, element) => value + element);
//           pieChartData.update(prefixName, (value) => value + sum, ifAbsent: () => sum);
//         }
//       });
//     }
//
//     // Build series configuration for the pie chart
//     String seriesConfig = '''
//     {
//       name: 'Percentage',
//       colorByPoint: true,
//       data: [
//     ''';
//
//     pieChartData.forEach((name, value) {
//       seriesConfig += '''
//       {
//         name: '$name',
//         y: $value
//       },
//     ''';
//     });
//
//     seriesConfig += '''
//       ]
//     }
//     ''';
//
//     return '''
//     {
//       chart: {
//         type: 'pie'
//       },
//       title: {
//         text: 'Appliance Share'
//       },
//       tooltip: {
//         valueSuffix: '%'
//       },
//       plotOptions: {
//         pie: {
//           allowPointSelect: true,
//           cursor: 'pointer',
//           dataLabels: {
//             enabled: true,
//             distance: 20,
//             format: '{point.percentage:.1f}%'
//           },
//           showInLegend: true
//         }
//       },
//       series: [$seriesConfig]
//     }
//   ''';
//   }
// }





/// for later on
/// class Controllers extends GetxController {
// //   RxList<Map<String, dynamic>> kwData = <Map<String, dynamic>>[].obs;
// //   double lastMainKwValue = 0.0;
// //
// //   Future<void> fetchData() async {
// //     Set<String> processedDates = Set();
// //
// //     for (int i = 6; i >= 0; i--) {
// //       DateTime currentDate = DateTime.now().subtract(Duration(days: i));
// //       String formattedDate = currentDate.toLocal().toString().split(' ')[0];
// //
// //       if (processedDates.contains(formattedDate)) {
// //         continue;
// //       }
// //
// //       final apiUrl =
// //           'http://203.135.63.22:8000/data?username=ppjp2isl&mode=hour&start=$formattedDate&end=$formattedDate';
// //
// //       try {
// //         final response = await http.get(Uri.parse(apiUrl));
// //
// //         if (response.statusCode == 200) {
// //           Map<String, dynamic> jsonData = json.decode(response.body);
// //           Map<String, dynamic> data = jsonData['data'];
// //
// //           List<Map<String, dynamic>> newData = [];
// //
// //           data.forEach((itemName, values) {
// //             if (itemName.endsWith("[kW]")) {
// //               String prefixName = itemName.substring(0, itemName.length - 4);
// //               List<double> numericValues =
// //               (values as List<dynamic>).map((value) {
// //                 if (value is num) {
// //                   return value.toDouble();
// //                 } else if (value is String) {
// //                   return double.tryParse(value) ?? 0.0;
// //                 } else {
// //                   return 0.0;
// //                 }
// //               }).toList();
// //
// //               newData.add({
// //                 'prefixName': prefixName,
// //                 'values': numericValues,
// //               });
// //             }
// //           });
// //
// //           kwData.add({'date': formattedDate, 'data': newData});
// //           processedDates.add(formattedDate);
// //         } else {
// //           print(
// //               'Failed to fetch data for $formattedDate. Status code: ${response.statusCode}');
// //           print('Response body: ${response.body}');
// //         }
// //       } catch (error) {
// //         print('Error fetching data for $formattedDate: $error');
// //       }
// //     }
// //   }
// // }