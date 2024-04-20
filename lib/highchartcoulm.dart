


// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:high_chart/high_chart.dart';
//
// class MyAppcvcc extends StatefulWidget {
//   @override
//   _MyAppcvccState createState() => _MyAppcvccState();
// }
//
// class _MyAppcvccState extends State<MyAppcvcc> {
//   Map<String, List<double>> _data = {};
//   DateTime startDate = DateTime.now().subtract(Duration(days: 1));
//
//   @override
//   void initState() {
//     super.initState();
//     fetchData();
//   }
//
//   Future<void> fetchData() async {
//     DateTime endDate = DateTime.now();
//     DateTime startDate = endDate.subtract(Duration(days: 6));
//
//     String formattedStartDate = "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}";
//     String formattedEndDate = "${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}";
//
//     final Uri uri = Uri.parse('http://203.135.63.47:8000/data?username=ppjiq&mode=hour&start=$formattedStartDate&end=$formattedEndDate');
//
//     try {
//       final response = await http.get(uri);
//       if (response.statusCode == 200) {
//         final jsonResponse = jsonDecode(response.body);
//         final Map<String, dynamic> data = jsonResponse['data'];
//         final Map<String, List<double>> processedData = {}; // Adjusted for daily sums
//
//         data.forEach((key, value) {
//           if (key.endsWith('_[kW]')) {
//             List<double> listValues = (value as List).map((item) {
//               double val = 0.0;
//               if (item != null && item != 'NA' && item != '') {
//                 val = double.tryParse(item.toString()) ?? 0.0;
//               }
//               return double.parse((val / 1000).toStringAsFixed(2));
//             }).toList();
//
//             // Sum up every 24 values
//             processedData[key] = [];
//             for (int i = 0; i < listValues.length; i += 24) {
//               processedData[key]!.add(listValues.sublist(i, i + 24 > listValues.length ? listValues.length : i + 24).reduce((a, b) => a + b));
//             }
//           }
//         });
//
//         setState(() {
//           _data = processedData;
//           this.startDate = startDate;
//         });
//       } else {
//         print('Failed to load data with status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Failed to load data with error: $e');
//     }
//   }
//
//   String _prepareChartData() {
//     List<Map<String, dynamic>> series = [];
//     _data.forEach((key, dailySums) {
//       List<dynamic> data = [];
//       for (int i = 0; i < dailySums.length; i++) {
//         DateTime date = startDate.add(Duration(days: i));
//         // Adjusting to Pakistani time by adding 5 hours
//         DateTime pakistaniDateTime = date.add(Duration(hours: 5));
//         data.add([pakistaniDateTime.millisecondsSinceEpoch, dailySums[i]]);
//       }
//       series.add({
//         "name": key.replaceAll('_[kW]', ''),
//         "data": data,
//         "visible": !(key.startsWith('Main') || key.startsWith('Generator')), // Hide Main and Generator by default
//       });
//     });
//
//     return '''
//   {
//     chart: {
//       type: 'column'
//     },
//     title: {
//       text: 'Daily kW Data in Pakistani Time (UTC+5)'
//     },
//     xAxis: {
//       type: 'datetime',
//       dateTimeLabelFormats: {
//         day: '%e. %b'
//       }
//     },
//     yAxis: {
//       min: 0,
//       title: {
//         text: 'Energy (kWh)'
//       },
//       stackLabels: {
//         enabled: false // Disable stack labels
//       }
//     },
//     tooltip: {
//       headerFormat: '<b>{point.x:%e. %b}</b><br/>',
//       pointFormat: '{series.name}: {point.y:.2f} kW' // Updated format here
//     },
//     plotOptions: {
//       column: {
//         stacking: 'normal',
//         dataLabels: {
//           enabled: false // Disable data labels to not show values on the chart
//         }
//       }
//     },
//     series: ${jsonEncode(series)}
//   }
//   ''';
//   }
//
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('Display Daily kW Data'),
//         ),
//         body: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: HighCharts(
//             loader: const SizedBox(
//               width: 50,
//               height: 50,
//               child: CircularProgressIndicator(),
//             ),
//             data: _prepareChartData(),
//             scripts: const [
//               "https://code.highcharts.com/highcharts.js",
//               "https://code.highcharts.com/modules/exporting.js",
//               "https://code.highcharts.com/modules/export-data.js",
//               "https://code.highcharts.com/modules/accessibility.js",
//             ], size: const Size(400, 400),
//           ),
//         ),
//       ),
//     );
//   }
// }




//
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
//
// class MyAppcvcc extends StatefulWidget {
//   @override
//   _MyAppcvccState createState() => _MyAppcvccState();
// }
//
// class _MyAppcvccState extends State<MyAppcvcc> {
//   Map<String, List<double>> _data = {}; // Changed to store daily sums
//   DateTime startDate = DateTime.now().subtract(Duration(days: 1));
//
//   @override
//   void initState() {
//     super.initState();
//     fetchData();
//   }
//
//   Future<void> fetchData() async {
//     DateTime endDate = DateTime.now();
//     DateTime startDate = endDate.subtract(Duration(days: 6));
//
//     String formattedStartDate = "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}";
//     String formattedEndDate = "${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}";
//
//     final Uri uri = Uri.parse('http://203.135.63.47:8000/data?username=ppjiq&mode=hour&start=$formattedStartDate&end=$formattedEndDate');
//
//     try {
//       final response = await http.get(uri);
//       if (response.statusCode == 200) {
//         final jsonResponse = jsonDecode(response.body);
//         final Map<String, dynamic> data = jsonResponse['data'];
//         final Map<String, List<double>> processedData = {}; // Adjusted for daily sums
//
//         data.forEach((key, value) {
//           if (key.endsWith('_[kW]')) {
//             List<double> listValues = (value as List).map((item) {
//               double val = 0.0;
//               if (item != null && item != 'NA' && item != '') {
//                 val = double.tryParse(item.toString()) ?? 0.0;
//               }
//               return double.parse((val / 1000).toStringAsFixed(2));
//             }).toList();
//
//             // Sum up every 24 values
//             processedData[key] = [];
//             for (int i = 0; i < listValues.length; i += 24) {
//               processedData[key]!.add(listValues.sublist(i, i + 24 > listValues.length ? listValues.length : i + 24).reduce((a, b) => a + b));
//             }
//           }
//         });
//
//         setState(() {
//           _data = processedData;
//           this.startDate = startDate;
//         });
//       } else {
//         print('Failed to load data with status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Failed to load data with error: $e');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('Display Daily kW Data'),
//         ),
//         body: ListView.builder(
//           itemCount: _data.length,
//           itemBuilder: (context, index) {
//             String key = _data.keys.elementAt(index);
//             List<double> dailySums = _data[key]!;
//             return ExpansionTile(
//               title: Text(key),
//               children: dailySums.asMap().entries.map((entry) {
//                 int dayIndex = entry.key;
//                 double daySum = entry.value;
//                 DateTime date = startDate.add(Duration(days: dayIndex));
//                 String formattedDate = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
//                 return ListTile(
//                   title: Text('Date: $formattedDate'),
//                   subtitle: Text(daySum.toStringAsFixed(2)),
//                 );
//               }).toList(),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }


/// per hr data
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
//
//
// class MyAppcvcc extends StatefulWidget {
//   @override
//   _MyAppcvccState createState() => _MyAppcvccState();
// }
//
// class _MyAppcvccState extends State<MyAppcvcc> {
//   Map<String, List<List<double>>> _data = {};
//   DateTime startDate = DateTime.now().subtract(Duration(days: 1));
//
//   @override
//   void initState() {
//     super.initState();
//     fetchData();
//   }
//
//   // Utility function to chunk a list into smaller lists of a given size
//   List<List<T>> chunkList<T>(List<T> list, int chunkSize) {
//     return List.generate(
//       (list.length / chunkSize).ceil(), // Determine the number of chunks
//           (i) => list.sublist(
//         i * chunkSize,
//         i * chunkSize + chunkSize > list.length ? list.length : i * chunkSize + chunkSize,
//       ),
//     );
//   }
//
//   Future<void> fetchData() async {
//     DateTime endDate = DateTime.now();
//     DateTime startDate = endDate.subtract(Duration(days: 6));
//
//     String formattedStartDate = "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}";
//     String formattedEndDate = "${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}";
//
//     final Uri uri = Uri.parse('http://203.135.63.47:8000/data?username=ahmad&mode=hour&start=$formattedStartDate&end=$formattedEndDate');
//
//     try {
//       final response = await http.get(uri);
//       if (response.statusCode == 200) {
//         final jsonResponse = jsonDecode(response.body);
//         final Map<String, dynamic> data = jsonResponse['data'];
//         final Map<String, List<List<double>>> processedData = {};
//
//         data.forEach((key, value) {
//           if (key.endsWith('_[kW]')) {
//             List<double> listValues = (value as List).map((item) {
//               double val = 0.0;
//               if (item != null && item != 'NA' && item != '') {
//                 val = double.tryParse(item.toString()) ?? 0.0;
//               }
//               return double.parse((val / 1000).toStringAsFixed(2));
//             }).toList();
//
//             processedData[key] = chunkList(listValues, 24);
//           }
//         });
//
//         setState(() {
//           _data = processedData;
//           this.startDate = startDate;
//         });
//       } else {
//         print('Failed to load data with status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Failed to load data with error: $e');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('Display kW Data with Dates'),
//         ),
//         body: ListView.builder(
//           itemCount: _data.length,
//           itemBuilder: (context, index) {
//             String key = _data.keys.elementAt(index);
//             List<List<double>> dayChunks = _data[key]!;
//             return ExpansionTile(
//               title: Text(key),
//               children: dayChunks.asMap().entries.map((entry) {
//                 int dayIndex = entry.key;
//                 List<double> dayValues = entry.value;
//                 DateTime chunkDate = startDate.add(Duration(days: dayIndex));
//                 String formattedDate = "${chunkDate.year}-${chunkDate.month.toString().padLeft(2, '0')}-${chunkDate.day.toString().padLeft(2, '0')}";
//                 return ListTile(
//                   title: Text('Date: $formattedDate'),
//                   subtitle: Text(dayValues.join(', ')),
//                 );
//               }).toList(),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }





import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KW Data Viewer',
      home: Scaffold(
        appBar: AppBar(
          title: Text('KW Data Viewer'),
        ),
        body: KWDataWidget(),
      ),
    );
  }
}

class KWDataWidget extends StatefulWidget {
  @override
  _KWDataWidgetState createState() => _KWDataWidgetState();
}

class _KWDataWidgetState extends State<KWDataWidget> {
  List<Map<String, dynamic>> kwData = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    const url = 'http://203.135.63.47:8000/data?username=ppjiq&mode=hour&start=2024-04-15&end=2024-04-15';
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      var data = jsonData['data'] as Map<String, dynamic>;
      setState(() {
        kwData = data.entries
            .where((entry) => entry.key.endsWith('_[kW]'))
            .map((entry) => {
          'key': entry.key,
          'values': entry.value,
        })
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: kwData.length,
        itemBuilder: (context, index) {
          var entry = kwData[index];
          return ListTile(
            title: Text(entry['key']),
            subtitle: Text(entry['values'].join(', ')),
          );
        },
      ),
    );
  }
}


