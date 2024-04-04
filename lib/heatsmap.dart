import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;



class DataDisplayScreendsd extends StatefulWidget {
  @override
  _DataDisplayScreendsdState createState() => _DataDisplayScreendsdState();
}

class _DataDisplayScreendsdState extends State<DataDisplayScreendsd> {
  late Future<Map<String, List<String>>> futureDataOrganized;

  Future<Map<String, List<String>>> fetchData() async {
    String startDate = "2023-12-07";
    String endDate = "2023-12-10";
    final String url = 'http://203.135.63.22:8000/data?username=ahmad&mode=hour&start=$startDate&end=$endDate';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return _organizeData(data);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      throw Exception('Failed to fetch data: $e');
    }
  }

  Map<String, List<String>> _organizeData(Map<String, dynamic> rawData) {
    Map<String, List<String>> organizedData = {};
    List<dynamic> dateTimeData = rawData['data']['Date & Time'];
    List<dynamic> kwData = rawData['data']['Main_[kW]'];

    for (int i = 0; i < dateTimeData.length; i++) {
      String date = dateTimeData[i].split(' ')[0]; // Extract date part
      String kwValue = kwData[i] == "NA" || kwData[i] == null ? "0" : kwData[i].toString();

      organizedData.putIfAbsent(date, () => []);
      organizedData[date]!.add(kwValue);
    }

    return organizedData;
  }

  @override
  void initState() {
    super.initState();
    futureDataOrganized = fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Main_[kW] Data Display'),
      ),
      body: FutureBuilder<Map<String, List<String>>>(
        future: futureDataOrganized,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var dates = snapshot.data!.keys.toList();
            return ListView.builder(
              itemCount: dates.length,
              itemBuilder: (context, index) {
                String date = dates[index];
                List<String> kwValues = snapshot.data![date]!;
                return ExpansionTile(
                  title: Text(date),
                  children: kwValues.asMap().entries.map((entry) {
                    int idx = entry.key;
                    String kwValue = entry.value;
                    return ListTile(
                      title: Text("Value $idx"),
                      subtitle: Text("Main_[kW]: $kwValue"),
                    );
                  }).toList(),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          // By default, show a loading spinner.
          return CircularProgressIndicator();
        },
      ),
    );
  }
}




// // import 'package:flutter/cupertino.dart';
// // import 'package:flutter/material.dart';
// // import 'package:high_chart/high_chart.dart';
// // import 'package:http/http.dart' as http;
// // import 'dart:convert';
// //
// // class WeekDataDisplay extends StatefulWidget {
// //   @override
// //   _WeekDataDisplayState createState() => _WeekDataDisplayState();
// // }
// //
// // class _WeekDataDisplayState extends State<WeekDataDisplay> {
// //   List<Map<String, dynamic>> kwData = [];
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     fetchData();
// //   }
// //
// //   Future<void> fetchData() async {
// //     try {
// //       final String apiUrl =
// //           "http://203.135.63.22:8000/data?username=ppjiq&mode=hour&start=2024-02-11&end=2024-02-11";
// //       final response = await http.get(Uri.parse(apiUrl));
// //
// //       try {
// //         if (response.statusCode == 200) {
// //           Map<String, dynamic> jsonData = json.decode(response.body);
// //           Map<String, dynamic> data = jsonData['data'];
// //
// //           data.forEach((itemName, values) {
// //             if (itemName.endsWith("[kW]")) {
// //               String prefixName = itemName.substring(0, itemName.length - 4);
// //               List<double> numericValues = (values as List<dynamic>).map((value) {
// //                 if (value is num) {
// //                   return value.toDouble();
// //                 } else if (value is String) {
// //                   return double.tryParse(value) ?? 0.0;
// //                 } else {
// //                   return 0.0;
// //                 }
// //               }).toList();
// //
// //               setState(() {
// //                 kwData.add({'prefixName': prefixName, 'values': numericValues});
// //               });
// //             }
// //           });
// //         } else {
// //           print('Failed to fetch data. Status code: ${response.statusCode}');
// //         }
// //       } catch (error) {
// //         print('Error fetching data: $error');
// //       }
// //     } catch (error) {
// //       print('An unexpected error occurred: $error');
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Padding(
// //       padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
// //       child: HighCharts(
// //         loader: const SizedBox(
// //           height: 20,
// //           width: 15,
// //           child: CircularProgressIndicator(
// //             strokeWidth: 2,
// //           ),
// //         ),
// //         size: const Size(400, 400),
// //         data: _getChartData(),
// //         scripts: highchartsScripts,
// //       ),
// //     );
// //   }
// //
// //   String _getChartData() {
// //     List<List<dynamic>> heatmapData = [];
// //
// //     kwData.forEach((item) {
// //       String prefixName = item['prefixName'];
// //       List<double> values = item['values'];
// //       // Assuming values are for each hour
// //       for (int i = 0; i < values.length; i++) {
// //         // Adjusting date to Pakistani time zone
// //         DateTime dateTime = DateTime.parse('2024-02-11T00:00:00Z').add(Duration(hours: i));
// //         DateTime pakistaniDateTime = dateTime.toUtc().add(Duration(hours: 5));
// //
// //         // Adding data for the heatmap
// //         heatmapData.add([
// //           _getEpochMillis(pakistaniDateTime),
// //           kwData.indexOf(item), // Row index
// //           values[i], // Value
// //         ]);
// //       }
// //     });
// //
// //     return '''
// //     {
// //       accessibility: {
// //         enabled: false
// //       },
// //       chart: {
// //         type: 'heatmap',
// //         marginTop: 40,
// //         marginBottom: 80,
// //         plotBorderWidth: 1
// //       },
// //       title: {
// //         text: 'Weekly Data Display'
// //       },
// //       xAxis: {
// //         type: 'datetime',
// //         dateTimeLabelFormats: {
// //           day: '%e %b',
// //         },
// //         title: {
// //           text: 'Date'
// //         }
// //       },
// //       yAxis: {
// //         title: {
// //           text: 'Prefix Name'
// //         },
// //         categories: ${jsonEncode(kwData.map((item) => item['prefixName']).toList())}, // Prefix names as categories
// //       },
// //       colorAxis: {
// //         min: 0,
// //         minColor: '#FFFFFF',
// //         maxColor: Highcharts.getOptions().colors[0]
// //       },
// //       legend: {
// //         enabled: false
// //       },
// //       series: [{
// //         borderWidth: 0,
// //         data: ${jsonEncode(heatmapData)},
// //         dataLabels: {
// //           enabled: true,
// //           color: '#000000'
// //         }
// //       }]
// //     }
// //     ''';
// //   }
// //
// //   // Helper function to get milliseconds since epoch
// //   int _getEpochMillis(DateTime dateTime) {
// //     return dateTime.millisecondsSinceEpoch;
// //   }
// //
// //   // Highcharts scripts including heatmap module
// //   static const List<String> highchartsScripts = [
// //     'https://code.highcharts.com/highcharts.js',
// //     'https://code.highcharts.com/modules/heatmap.js'
// //   ];
// // }
//
//
//
//
//
// // import 'package:flutter/material.dart';
// // import 'package:high_chart/high_chart.dart';
// // import 'package:http/http.dart' as http;
// // import 'dart:convert';
// // import 'package:get/get.dart';
// //
// // class WeekDataDisplayController extends GetxController {
// //   RxList<Map<String, dynamic>> kwData = <Map<String, dynamic>>[].obs;
// //
// //   @override
// //   void onInit() {
// //     super.onInit();
// //     fetchData();
// //   }
// //
// //   Future<void> fetchData() async {
// //     try {
// //       final String apiUrl =
// //           "http://203.135.63.22:8000/data?username=ahmad&mode=hour&start=2024-02-11&end=2024-02-18";
// //       final response = await http.get(Uri.parse(apiUrl));
// //
// //       try {
// //         if (response.statusCode == 200) {
// //           Map<String, dynamic> jsonData = json.decode(response.body);
// //           Map<String, dynamic> data = jsonData['data'];
// //
// //           data.forEach((itemName, values) {
// //             if (itemName.endsWith("[kW]")) {
// //               String prefixName = itemName.substring(0, itemName.length - 4);
// //               List<double> numericValues = (values as List<dynamic>).map((value) {
// //                 if (value is num) {
// //                   // Convert to kW (divide by 1000)
// //                   return value.toDouble() / 1000.0;
// //                 } else if (value is String) {
// //                   // Convert to double and then to kW (divide by 1000)
// //                   return (double.tryParse(value) ?? 0.0) / 1000.0;
// //                 } else {
// //                   return 0.0;
// //                 }
// //               }).toList();
// //
// //               kwData.add({'prefixName': prefixName, 'values': numericValues});
// //             }
// //           });
// //         } else {
// //           print('Failed to fetch data. Status code: ${response.statusCode}');
// //         }
// //       } catch (error) {
// //         print('Error fetching data: $error');
// //       }
// //     } catch (error) {
// //       print('An unexpected error occurred: $error');
// //     }
// //   }
// //
// // }
// //
// // class WeekDataDisplay extends StatelessWidget {
// //   final WeekDataDisplayController controller = Get.put(WeekDataDisplayController());
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text('Week Data Display'),
// //       ),
// //       body: Obx(() {
// //         if (controller.kwData.isEmpty) {
// //           return Center(
// //             child: CircularProgressIndicator(),
// //           );
// //         } else {
// //           return Padding(
// //             padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
// //             child: HighCharts(
// //               loader: const SizedBox(
// //                 height: 20,
// //                 width: 15,
// //                 child: CircularProgressIndicator(
// //                   strokeWidth: 2,
// //                 ),
// //               ),
// //               size: const Size(400, 400),
// //               data: _getChartData(controller.kwData),
// //               scripts: const ["https://code.highcharts.com/highcharts.js"],
// //             ),
// //           );
// //         }
// //       }),
// //     );
// //   }
// //
// //   String _getChartData(List<Map<String, dynamic>> kwData) {
// //     List<Map<String, dynamic>> seriesData = [];
// //     List<String> legendNames = [];
// //
// //     kwData.forEach((item) {
// //       String prefixName = item['prefixName'].replaceAll('_', ''); // Remove underscores
// //       List<double> values = item['values'];
// //       legendNames.add(prefixName); // Add key name to legends
// //       List<List<dynamic>> dataForSeries = [];
// //       // Assuming values are for each hour
// //       for (int i = 0; i < values.length; i++) {
// //         // Adjusting date to Pakistani time zone
// //         DateTime dateTime = DateTime.parse('2024-02-11T00:00:00Z').add(Duration(hours: i));
// //         DateTime pakistaniDateTime = dateTime.toUtc().add(Duration(hours: 5));
// //
// //         dataForSeries.add([
// //           _getEpochMillis(pakistaniDateTime),
// //           values[i],
// //         ]);
// //       }
// //       seriesData.add({
// //         'name': prefixName,
// //         'data': dataForSeries,
// //       });
// //     });
// //
// //     List<String> seriesConfigList = [];
// //     seriesData.forEach((series) {
// //       String seriesName = series['name'];
// //       List<List<dynamic>> seriesData = series['data'];
// //
// //       seriesConfigList.add('''
// // {
// //   type: 'area',
// //   name: '$seriesName',
// //   data: ${jsonEncode(seriesData)},
// // }
// // ''');
// //     });
// //
// //     String seriesConfig = seriesConfigList.join(',');
// //
// //     return '''
// // {
// //   accessibility: {
// //     enabled: false
// //   },
// //   chart: {
// //     alignTicks: false
// //   },
// //   title: {
// //     text: 'Weekly Data Display'
// //   },
// //   xAxis: {
// //     type: 'datetime',
// //     dateTimeLabelFormats: {
// //       day: '%e %b',
// //     },
// //   },
// //   yAxis: {
// //     title: {
// //       text: 'Energy (kW)',
// //     },
// //   },
// //   legend: {
// //     enabled: true,
// //   },
// //   tooltip: {
// //     pointFormat: '<span style="color:{point.color}">\u25CF</span> {series.name}: <b>{point.y:.2f} kW</b><br/>'
// //   },
// //   series: [$seriesConfig],
// // }
// // ''';
// //   }
// //
// //
// //
// //   // Helper function to get milliseconds since epoch
// //   int _getEpochMillis(DateTime dateTime) {
// //     return dateTime.millisecondsSinceEpoch;
// //   }
// // }
//
//
//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:high_chart/high_chart.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
//
// class WeekDataDisplay extends StatefulWidget {
//   @override
//   _WeekDataDisplayState createState() => _WeekDataDisplayState();
// }
//
// class _WeekDataDisplayState extends State<WeekDataDisplay> {
//   List<Map<String, dynamic>> kwData = [];
//
//   @override
//   void initState() {
//     super.initState();
//     fetchData();
//   }
//
//   Future<void> fetchData() async {
//     try {
//       final String apiUrl =
//           "http://203.135.63.22:8000/data?username=ppjiq&mode=hour&start=2024-02-11&end=2024-02-11";
//       final response = await http.get(Uri.parse(apiUrl));
//
//       try {
//         if (response.statusCode == 200) {
//           Map<String, dynamic> jsonData = json.decode(response.body);
//           Map<String, dynamic> data = jsonData['data'];
//
//           data.forEach((itemName, values) {
//             if (itemName.endsWith("[kW]")) {
//               String prefixName = itemName.substring(0, itemName.length - 4);
//               List<double> numericValues = (values as List<dynamic>).map((value) {
//                 if (value is num) {
//                   return value.toDouble();
//                 } else if (value is String) {
//                   return double.tryParse(value) ?? 0.0;
//                 } else {
//                   return 0.0;
//                 }
//               }).toList();
//
//               setState(() {
//                 kwData.add({'prefixName': prefixName, 'values': numericValues});
//               });
//             }
//           });
//         } else {
//           print('Failed to fetch data. Status code: ${response.statusCode}');
//         }
//       } catch (error) {
//         print('Error fetching data: $error');
//       }
//     } catch (error) {
//       print('An unexpected error occurred: $error');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
//       child: HighCharts(
//         loader: const SizedBox(
//           height: 20,
//           width: 15,
//           child: CircularProgressIndicator(
//             strokeWidth: 2,
//           ),
//         ),
//         size: const Size(400, 400),
//         data: _getChartData(),
//         scripts: const ["https://code.highcharts.com/highcharts.js"],
//       ),
//     );
//   }
//
//   String _getChartData() {
//     List<Map<String, dynamic>> seriesData = [];
//     List<String> legendNames = [];
//
//     kwData.forEach((item) {
//       String prefixName = item['prefixName'];
//       List<double> values = item['values'];
//       legendNames.add(prefixName); // Add key name to legends
//       List<List<dynamic>> dataForSeries = [];
//       // Assuming values are for each hour
//       for (int i = 0; i < values.length; i++) {
//         // Adjusting date to Pakistani time zone
//         DateTime dateTime = DateTime.parse('2024-02-11T00:00:00Z').add(Duration(hours: i));
//         DateTime pakistaniDateTime = dateTime.toUtc().add(Duration(hours: 5));
//
//         dataForSeries.add([
//           _getEpochMillis(pakistaniDateTime),
//           values[i],
//         ]);
//       }
//       seriesData.add({
//         'name': prefixName,
//         'data': dataForSeries,
//       });
//     });
//
//     List<String> seriesConfigList = [];
//     seriesData.forEach((series) {
//       String seriesName = series['name'];
//       List<List<dynamic>> seriesData = series['data'];
//       seriesConfigList.add('''
//     {
//       type: 'area',
//       name: '$seriesName',
//       data: ${jsonEncode(seriesData)},
//     }
//     ''');
//     });
//
//     String seriesConfig = seriesConfigList.join(',');
//
//     return '''
//   {
//     accessibility: {
//       enabled: false
//     },
//     chart: {
//       alignTicks: false
//     },
//     title: {
//       text: 'Weekly Data Display'
//     },
//     xAxis: {
//       type: 'datetime',
//       dateTimeLabelFormats: {
//         day: '%e %b',
//       },
//     },
//     yAxis: {
//       title: {
//         text: 'Energy (kW)',
//       },
//     },
//     legend: {
//       enabled: true,
//     },
//     series: [$seriesConfig],
//   }
//   ''';
//   }
//
//
//   // Helper function to get milliseconds since epoch
//   int _getEpochMillis(DateTime dateTime) {
//     return dateTime.millisecondsSinceEpoch;
//   }
// }
// //
// //
// //
// //
// //
// //
// // // import 'package:flutter/material.dart';
// // // import 'package:http/http.dart' as http;
// // // import 'dart:convert';
// // // import 'package:high_chart/high_chart.dart';
// // //
// // // class WeekDataDisplay extends StatefulWidget {
// // //   @override
// // //   _WeekDataDisplayState createState() => _WeekDataDisplayState();
// // // }
// // //
// // // class _WeekDataDisplayState extends State<WeekDataDisplay> {
// // //   List<Map<String, dynamic>> kwData = [];
// // //
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     fetchData();
// // //   }
// // //
// // //   Future<void> fetchData() async {
// // //     try {
// // //       final String apiUrl =
// // //           "http://203.135.63.22:8000/data?username=ppjiq&mode=hour&start=2024-02-11&end=2024-02-11";
// // //       final response = await http.get(Uri.parse(apiUrl));
// // //
// // //       try {
// // //         if (response.statusCode == 200) {
// // //           Map<String, dynamic> jsonData = json.decode(response.body);
// // //           Map<String, dynamic> data = jsonData['data'];
// // //
// // //           data.forEach((itemName, values) {
// // //             if (itemName.endsWith("[kW]")) {
// // //               String prefixName = itemName.substring(0, itemName.length - 4);
// // //               List<double> numericValues = (values as List<dynamic>).map((value) {
// // //                 if (value is num) {
// // //                   return value.toDouble();
// // //                 } else if (value is String) {
// // //                   return double.tryParse(value) ?? 0.0;
// // //                 } else {
// // //                   return 0.0;
// // //                 }
// // //               }).toList();
// // //
// // //               setState(() {
// // //                 kwData.add({'prefixName': prefixName, 'values': numericValues});
// // //               });
// // //             }
// // //           });
// // //         } else {
// // //           print('Failed to fetch data. Status code: ${response.statusCode}');
// // //         }
// // //       } catch (error) {
// // //         print('Error fetching data: $error');
// // //       }
// // //     } catch (error) {
// // //       print('An unexpected error occurred: $error');
// // //     }
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       appBar: AppBar(
// // //         title: Text('Week Data Display'),
// // //       ),
// // //       body: Column(
// // //         children: [
// // //           Expanded(
// // //             child: ListView.builder(
// // //               itemCount: kwData.length,
// // //               itemBuilder: (context, index) {
// // //                 final item = kwData[index];
// // //                 return ListTile(
// // //                   title: Text('key name: ${item['prefixName']}'),
// // //                   subtitle: Text(' Values: ${item['values']}'),
// // //                 );
// // //               },
// // //             ),
// // //           ),
// // //
// // //         ],
// // //       ),
// // //     );
// // //   }
// // // }
// // //
// // //
// // //
// // //
