
import 'package:flutter/material.dart';

import 'package:high_chart/high_chart.dart';

import '../controller/datacontroller.dart';

class StockColumn extends StatelessWidget {
  final DataControllers controllers;

  StockColumn({Key? key, required this.controllers}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      child: HighCharts(
        loader: Center(
          child: const SizedBox(
            child: Text('loading'),
            width: 2,
          ),
        ),
        size: const Size(400, 400),
        data: _getChartData(),
        scripts: const ["https://code.highcharts.com/highcharts.js"],
      ),
    );
  }

  String _getChartData() {
    // Extract the data from the DataControllers
    Map<String, Map<String, double>> dailyItemSumsMap =
        controllers.dailyItemSumsMapforMonth;

    // Generate dynamic chart data based on the fetched data
    List<List<dynamic>> seriesData = [];
    Map<String, int> colorMap = {};

    dailyItemSumsMap.forEach((date, itemSums) {
      String formattedDate = date;
      itemSums.forEach((itemName, sum) {
        if (!colorMap.containsKey(itemName)) {
          colorMap[itemName] = colorMap.length;
        }

        // Adjust the date to the Pakistani time zone
        DateTime dateTime = DateTime.parse(date);
        DateTime pakistaniDateTime = dateTime.toUtc().add(Duration(hours: 5));

        // Convert sum to kilowatts
        double sumInKW = sum / 1000;

        seriesData.add([
          _getEpochMillis(pakistaniDateTime), // Use the adjusted time
          sumInKW, // Use the converted value in kilowatts
          colorMap[itemName], // Color index for each item
        ]);
      });
    });

    String seriesConfig = '';
    colorMap.forEach((itemName, colorIndex) {
      // Remove underscores from the item name
      String cleanItemName = itemName.replaceAll('_', ' ');
      bool isVisible = itemName != 'Main_' && itemName != 'Generator_';

      seriesConfig += '''
    {
      type: 'column',
      name: '$cleanItemName', // Use the cleaned item name
      data: ${seriesData.where((data) => data[2] == colorIndex).map((data) => [
                data[0],
                data[1],
              ]).toList()},
      color: Highcharts.getOptions().colors[$colorIndex],
      pointWidth: 10,
      borderRadius: 5,
          visible: $isVisible, 
    },
  ''';
    });

    return '''
  {
    accessibility: {
      enabled: false
    },
    chart: {
      alignTicks: false
    },
    title: {
      text: 'Monthly Breakdown'
    },
    
    xAxis: {
      type: 'datetime',
      dateTimeLabelFormats: {
        day: '%e %b',
      },
    },
    yAxis: {
      allowDecimals: false,
      title: {
        text: 'Energy (kWh)',
      },
    },
    plotOptions: {
      column: {
        stacking: 'normal',
        tooltip: {
          pointFormat: '<span style="color:{point.color}">\u25CF</span> {series.name}: <b>{point.y:.2f} kWh</b><br/>'
        }
      }
    },
    series: [$seriesConfig],
  }
''';
  }

  // String _getChartData() {
  //   // Extract the data from the DataControllers
  //   Map<String, Map<String, double>> dailyItemSumsMap = controllers.dailyItemSumsMapforMonth;
  //
  //   // Generate dynamic chart data based on the fetched data
  //   List<List<dynamic>> seriesData = [];
  //   Map<String, int> colorMap = {};
  //
  //   dailyItemSumsMap.forEach((date, itemSums) {
  //     String formattedDate = date;
  //     itemSums.forEach((itemName, sum) {
  //       if (!colorMap.containsKey(itemName)) {
  //         colorMap[itemName] = colorMap.length;
  //       }
  //
  //       // Adjust the date to the Pakistani time zone
  //       DateTime dateTime = DateTime.parse(date);
  //       DateTime pakistaniDateTime = dateTime.toUtc().add(Duration(hours: 5));
  //
  //       // Convert sum to kilowatts
  //       double sumInKW = sum / 1000;
  //
  //       seriesData.add([
  //         _getEpochMillis(pakistaniDateTime), // Use the adjusted time
  //         sumInKW, // Use the converted value in kilowatts
  //         colorMap[itemName], // Color index for each item
  //       ]);
  //     });
  //   });
  //
  //   String seriesConfig = '';
  //   colorMap.forEach((itemName, colorIndex) {
  //     seriesConfig += '''
  //     {
  //       type: 'column',
  //       name: '$itemName',
  //       data: ${seriesData.where((data) => data[2] == colorIndex).map((data) => [
  //       data[0],
  //       data[1],
  //     ]).toList()},
  //       color: Highcharts.getOptions().colors[$colorIndex],
  //       pointWidth: 10,
  //       borderRadius: 5,
  //     },
  //   ''';
  //   });
  //
  //   return '''
  //   {
  //     accessibility: {
  //       enabled: false
  //     },
  //     chart: {
  //       alignTicks: false
  //     },
  //     title: {
  //       text: 'Monthly Breakdown'
  //     },
  //
  //     xAxis: {
  //       type: 'datetime',
  //       dateTimeLabelFormats: {
  //         day: '%e %b',
  //       },
  //     },
  //     yAxis: {
  //       allowDecimals: false,
  //       title: {
  //         text: 'Value (KW)',
  //       },
  //     },
  //     plotOptions: {
  //       column: {
  //         stacking: 'normal',
  //         tooltip: {
  //           pointFormat: '<span style="color:{point.color}">\u25CF</span> {series.name}: <b>{point.y:.2f} KW</b><br/>'
  //         }
  //       }
  //     },
  //     series: [$seriesConfig],
  //   }
  // ''';
  // }

  // String _getChartData() {
  //   // Extract the data from the DataControllers
  //   Map<String, Map<String, double>> dailyItemSumsMap = controllers.dailyItemSumsMapforMonth;
  //
  //   // Generate dynamic chart data based on the fetched data
  //   List<List<dynamic>> seriesData = [];
  //   Map<String, int> colorMap = {};
  //
  //   dailyItemSumsMap.forEach((date, itemSums) {
  //     String formattedDate = date;
  //     itemSums.forEach((itemName, sum) {
  //       if (!colorMap.containsKey(itemName)) {
  //         colorMap[itemName] = colorMap.length;
  //       }
  //
  //       // Adjust the date to the Pakistani time zone
  //       DateTime dateTime = DateTime.parse(date);
  //       DateTime pakistaniDateTime = dateTime.toUtc().add(Duration(hours: 5));
  //
  //       seriesData.add([
  //         _getEpochMillis(pakistaniDateTime), // Use the adjusted time
  //         sum,
  //         colorMap[itemName], // Color index for each item
  //       ]);
  //     });
  //   });
  //
  //   String seriesConfig = '';
  //   colorMap.forEach((itemName, colorIndex) {
  //     seriesConfig += '''
  //     {
  //       type: 'column',
  //       name: '$itemName',
  //       data: ${seriesData.where((data) => data[2] == colorIndex).map((data) => [
  //       data[0],
  //       data[1],
  //     ]).toList()},
  //       color: Highcharts.getOptions().colors[$colorIndex],
  //       pointWidth: 10,
  //        borderRadius: 5,
  //     },
  //   ''';
  //   });
  //
  //   return '''
  //   {
  //     accessibility: {
  //       enabled: false
  //     },
  //     chart: {
  //       alignTicks: false
  //     },
  //     title: {
  //       text: 'Daily Breakdown'
  //     },
  //
  //     xAxis: {
  //       type: 'datetime',
  //       dateTimeLabelFormats: {
  //         day: '%e %b',
  //       },
  //     },
  //     yAxis: {
  //       allowDecimals: false,
  //       title: {
  //         text: 'Value',
  //       },
  //     },
  //     plotOptions: {
  //       column: {
  //         stacking: 'normal'
  //       }
  //     },
  //     series: [$seriesConfig],
  //   }
  // ''';
  // }

  void _onColumnClick(Map<String, dynamic> event) {
    // Handle the click event, you can access the clicked data using event['point']
    Map<String, dynamic> point = event['point'];
    double xValue = point['x'];
    double yValue = point['y'];

    print('Clicked on column at date: $xValue, value: $yValue');
  }

  int _getEpochMillis(DateTime dateTime) {
    return dateTime.millisecondsSinceEpoch;
  }
}

// class Controllers extends GetxController {
//   // Observable list to store fetched data
//   RxList<Map<String, dynamic>> kwData = <Map<String, dynamic>>[].obs;
//
//   // Store the last main kW value
//   double lastMainKwValue = 0.0;
//
//   // Method to fetch data for the last seven days
//   Future<void> fetchData() async {
//     // Set to keep track of processed dates
//     Set<String> processedDates = Set();
//
//     try {
//       // Loop through the last seven days
//       for (int i = 6; i >= 0; i--) {
//         // Calculate the date for the current iteration
//         DateTime currentDate = DateTime.now().subtract(Duration(days: i));
//         String formattedDate =
//         currentDate.toLocal().toString().split(' ')[0];
//
//         // Skip fetching if the date has already been processed
//         if (processedDates.contains(formattedDate)) {
//           continue;
//         }
//
//         // Construct the API URL for the current date
//         final apiUrl =
//             'http://203.135.63.22:8000/data?username=ppjp2isl&mode=hour&start=$formattedDate&end=$formattedDate';
//
//         try {
//           // Make an HTTP GET request
//           final response = await http.get(Uri.parse(apiUrl));
//
//           // Check if the request was successful (status code 200)
//           if (response.statusCode == 200) {
//             // Parse the JSON response
//             Map<String, dynamic> jsonData = json.decode(response.body);
//             Map<String, dynamic> data = jsonData['data'];
//
//             // Extract and process relevant data
//             List<Map<String, dynamic>> newData = [];
//
//             data.forEach((itemName, values) {
//               if (itemName.endsWith("[kW]")) {
//                 String prefixName = itemName.substring(0, itemName.length - 4);
//                 List<double> numericValues =
//                 (values as List<dynamic>).map((value) {
//                   if (value is num) {
//                     return value.toDouble();
//                   } else if (value is String) {
//                     return double.tryParse(value) ?? 0.0;
//                   } else {
//                     return 0.0;
//                   }
//                 }).toList();
//
//                 newData.add({
//                   'prefixName': prefixName,
//                   'values': numericValues,
//                 });
//               }
//             });
//
//             // Update kwData with the new data
//             kwData.add({'date': formattedDate, 'data': newData});
//
//             // Mark the date as processed to avoid duplicates
//             processedDates.add(formattedDate);
//           } else {
//             // Handle unsuccessful response
//             print(
//                 'Failed to fetch data for $formattedDate. Status code: ${response.statusCode}');
//             print('Response body: ${response.body}');
//           }
//         } catch (error) {
//           // Handle HTTP request error
//           print('Error fetching data for $formattedDate: $error');
//         }
//       }
//     } catch (error) {
//       // Handle general error
//       print('An unexpected error occurred: $error');
//     }
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:high_chart/high_chart.dart';
//
// class StockColumn extends StatelessWidget {
//   const StockColumn({Key? key}) : super(key: key);
//
//   final String _chartData = '''{
//     accessibility: {
//       enabled: false
//     },
//     chart: {
//       alignTicks: false
//     },
//     rangeSelector: {
//       selected: 1
//     },
//     title: {
//       text: 'Stock Column'
//     },
//       series: [
//       {
//             type: 'column',
//             name: 'AAPL Stock Volume',
//             data: [[1588858200000,115215200],[1588944600000,133838400],[1589203800000,145946400],[1589290200000,162301200],[1589376600000,200622400],[1589463000000,158929200],[1589549400000,166348400],[1589808600000,135178400],[1589895000000,101729600],[1589981400000,111504800],[1590067800000,102688800],[1590154200000,81803200],[1590499800000,125522000],[1590586200000,112945200],[1590672600000,133560800],[1590759000000,153532400],[1591018200000,80791200],[1591104600000,87642800],],
//             dataGrouping: {
//                 units: [[
//                     'week', // unit name
//                     [1] // allowed multiples
//                 ], [
//                     'month',
//                     [1, 2, 3, 4, 6]
//                 ]]
//             }
//         }
//         ]
//     }''';
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
//       child: HighCharts(
//         loader: const SizedBox(
//           child: LinearProgressIndicator(),
//           width: 200,
//         ),
//         size: const Size(400, 400),
//         data: _chartData,
//         scripts: const ["https://code.highcharts.com/highcharts.js"],
//       ),
//     );
//   }
// }
