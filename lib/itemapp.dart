import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'package:webview_flutter/webview_flutter.dart';

import 'package:flutter/foundation.dart';

import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
// Update this with the path to your controller file
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'controller/historical/historical_controller.dart';

class LineChartController extends GetxController {
  var isLoading = true.obs;
  var chartData = ''.obs;
  var startDate = ''.obs; // Add this line
  var endDate = ''.obs; // Add this line

  @override
  void onInit() {
    super.onInit();
    checkDataAvailability();
  }

  // Method to check data availability and decide which data to fetch for chart
  void checkDataAvailability() async {
    isLoading(true);
    try {
      // Assuming you have a user or a mechanism to select the current username dynamically
      final String username = 'ahmad'; // Replace with actual dynamic username if needed
      final url = Uri.parse('http://203.135.63.22:8000/buildingmap?username=$username');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        fetchMainKWData();
      } else {
        print('Failed to check data availability. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('An error occurred while checking data availability: $e');
    } finally {
      isLoading(false);
    }
  }

  // Method to fetch and process data for chart visualization
  void fetchMainKWData() async {
    isLoading(true);
    try {
      // Replace with dynamic dates or parameters as necessary
      final url = Uri.parse('http://203.135.63.22:8000/data?username=ahmad&mode=hour&start=${startDate.value}&end=${endDate.value}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        List<dynamic> mainKWList;

        if (data.containsKey('Main_[kW]')) {
          mainKWList = data['Main_[kW]'];
        } else {
          List<dynamic> firstFloorList = data['1st Floor_[kW]'];
          List<dynamic> groundFloorList = data['Ground Floor_[kW]'];
          mainKWList = List.generate(firstFloorList.length, (index) => 0.0); // Initialize with zeroes

          for (int i = 0; i < firstFloorList.length; i++) {
            // Sum the values index-wise from both keys
            double firstFloorValue = double.tryParse(firstFloorList[i].toString()) ?? 0.0;
            double groundFloorValue = double.tryParse(groundFloorList[i].toString()) ?? 0.0;
            mainKWList[i] = firstFloorValue + groundFloorValue;
          }
        }

        // Process the data for visualization
        List<List<dynamic>> chunks = [];
        for (int i = 0; i < mainKWList.length; i += 24) {
          chunks.add(mainKWList.sublist(i, i + 24 > mainKWList.length ? mainKWList.length : i + 24));
        }

        List<String> xyValues = [];
        for (int day = 0; day < chunks.length; day++) {
          for (int hour = 0; hour < chunks[day].length; hour++) {
            double value = (chunks[day][hour] == null || chunks[day][hour] == "NA") ? 0.0 : double.parse(chunks[day][hour].toString());
            xyValues.add('{"x": $day, "y": $hour, "value": $value}');
          }
        }

        chartData('[${xyValues.join(",")}]');
      } else {
        throw Exception('Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('An error occurred while fetching and processing data: $e');
    } finally {
      isLoading(false);
    }
  }
}



class LineChartScreentwo extends StatefulWidget {
  LineChartScreentwo({Key? key}) : super(key: key);

  @override
  State<LineChartScreentwo> createState() => _LineChartScreentwoState();
}

class _LineChartScreentwoState extends State<LineChartScreentwo> {
  final HistoricalController controller = Get.put(HistoricalController());

  final WebViewController webViewController = WebViewController();

  void setupWebViewController() {
    webViewController
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..enableZoom(false)
      ..clearCache()
      ..setBackgroundColor(Colors.transparent)
      ..loadFlutterAsset('assets/js/hc_index.html');
  }
  @override
  void initState() {
    setupWebViewController();
    // TODO: implement initState
    super.initState();
  }


  @override
  Widget build(BuildContext context) {


    return Column(
      children: [
        Obx(() {
          if (controller.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          } else {
            // Reactively execute JavaScript whenever chartData changes
            if (controller.chartData.value.isNotEmpty) {
            //  webViewController.runJavaScript('jsHeatmapFunc(${controller.chartData.value});');

              String jsCall = "jsHeatmapFunc(${controller.chartData.value}, '${controller.startDate.value}', '${controller.endDate.value}');";
              webViewController.runJavaScript(jsCall);

            }

            return SizedBox(
              height: 700,
              child: WebViewWidget( // Ensure WebViewWidget supports passing a WebViewController
                controller: webViewController,
              ),
            );
          }
        }),
      ],

    );
  }
}












// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:webview_flutter_android/webview_flutter_android.dart';
// import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
//
// class LineChartScreentwo extends StatelessWidget {
//
//
//   late final WebViewController webViewController = WebViewController()
//     ..setJavaScriptMode(JavaScriptMode.unrestricted)
//     ..enableZoom(false)
//     ..clearCache()
//     ..setBackgroundColor(Colors.transparent)
//     ..loadFlutterAsset('assets/js/hc_index.html')
//     ..setNavigationDelegate(NavigationDelegate(
//       onPageStarted: (url) {
//         if (webViewController.platform is AndroidWebViewController) {
//           AndroidWebViewController.enableDebugging(kDebugMode);
//         }
//
//         if (webViewController.platform is WebKitWebViewController) {
//           final WebKitWebViewController webKitWebViewController =
//           webViewController.platform as WebKitWebViewController;
//           webKitWebViewController.setInspectable(kDebugMode);
//         }
//       },
//       onPageFinished: (url) {
//         //serialize your data models to string
//         fetchMainKWData().then((xyValue) {
//           webViewController.runJavaScript('jsHeatmapFunc($xyValue);');
//         });
//
//       },
//     ));
//   Future<String> fetchMainKWData() async {
//     // Assuming you've updated the URL to include the desired date range
//     final url = Uri.parse('http://203.135.63.22:8000/data?username=ppjiq&mode=hour&start=2024-02-11&end=2024-02-17');
//     final response = await http.get(url);
//
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       final mainKWList = data['data']['Main_[kW]'] as List<dynamic>;
//
//       // Split the list into chunks of 24 (representing each day's data)
//       List<List<dynamic>> chunks = [];
//       for (int i = 0; i < mainKWList.length; i += 24) {
//         chunks.add(mainKWList.sublist(i, i + 24 > mainKWList.length ? mainKWList.length : i + 24));
//       }
//
//       // Prepare data for serialization, assigning each chunk to a column
//       List<String> xyValues = [];
//       for (int day = 0; day < chunks.length; day++) {
//         for (int hour = 0; hour < chunks[day].length; hour++) {
//           double value = (chunks[day][hour] == null || chunks[day][hour] == "NA") ? 0.0 : double.parse(chunks[day][hour].toString());
//           xyValues.add('{"x": $day, "y": $hour, "value": $value}');
//         }
//       }
//
//       // Serialize the list of values to a JSON string
//       return '[${xyValues.join(",")}]';
//     } else {
//       throw Exception('Failed to load data');
//     }
//   }
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//         height: 700,
//         child: WebViewWidget(
//           controller: webViewController,
//         ));
//   }
// }
//
//



// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
//
//
//
// class MyAppazxc extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('API Data Display'),
//         ),
//         body: MainKWDisplay(),
//       ),
//     );
//   }
// }
// class MainKWDisplay extends StatefulWidget {
//   @override
//   _MainKWDisplayState createState() => _MainKWDisplayState();
// }
//
// class _MainKWDisplayState extends State<MainKWDisplay> {
//   Future<List<double>> fetchMainKWData() async {
//     final url = Uri.parse('http://203.135.63.22:8000/data?username=ppjiq&mode=hour&start=2023-12-07&end=2023-12-07');
//     final response = await http.get(url);
//
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       final mainKWList = data['data']['Main_[kW]'] as List<dynamic>;
//
//       // Convert null or "NA" to 0 and parse to double
//       return mainKWList.map<double>((value) => (value == null || value == "NA") ? 0.0 : double.parse(value.toString())).toList();
//     } else {
//       throw Exception('Failed to load data');
//     }
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('Main_[kW] Data'),
//         ),
//         body: FutureBuilder<List<double>>(
//           future: fetchMainKWData(),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return Center(child: CircularProgressIndicator());
//             } else if (snapshot.hasError) {
//               return Center(child: Text('Error: ${snapshot.error}'));
//             }
//
//             final data = snapshot.data!;
//             return ListView.builder(
//               itemCount: data.length,
//               itemBuilder: (context, index) {
//                 return ListTile(
//                   title: Text('Hour ${index}: ${data[index]} kW'),
//                 );
//               },
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
//
//
