import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity/connectivity.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../database/month_coloum_db.dart';


// Updated import for month data

class MonthColoumDataControllerss extends GetxController {
  var isLoading = true.obs;
  var chartData = ''.obs;
  var errorMessage = ''.obs;
  var hasError = false.obs;
  DateTime startDate = DateTime.now().subtract(Duration(days: 1));

  final DatabaseHelperForMonthColoum _dbHelper = DatabaseHelperForMonthColoum();

  @override
  void onInit() {
    super.onInit();
    fetchChartData();
  }

  void resetController() {
    isLoading(true);
    chartData('');
    errorMessage('');
    startDate = DateTime.now().subtract(Duration(days: 1));
  }

  void fetchChartData() async {
    errorMessage.value = '';
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      _loadDataFromLocalDb();
      Get.snackbar('', 'Kindly connect your device to the internet');
    } else {
      _fetchDataFromApi();
      Get.snackbar('', 'Getting data from the internet');
    }
  }

  void _loadDataFromLocalDb() async {
    isLoading(true);
    try {
      String? storedData = await _dbHelper.getChartData();
      if (storedData != null) {
        chartData(storedData);
      } else {
        errorMessage.value = "No data available locally.";
      }
    } catch (e) {
      errorMessage.value = 'Failed to load data from local DB: $e';
    } finally {
      isLoading(false);
    }
  }

  void _fetchDataFromApi() async {
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
    DateTime startDate = DateTime(now.year, now.month, 1); // Set startDate to the first day of the current month

    String formattedStartDate = "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}";
    String formattedEndDate = "${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}";

    try {
      String appurl="http://203.135.63.47:8000/data?username=$storedUsername&mode=day&start=$formattedStartDate&end=$formattedEndDate";
    print('abubakar');
    print(appurl);
      final response = await http.get(Uri.parse(appurl));
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        String chartDataString = parseChartData(jsonResponse);
        chartData(chartDataString);

        await _dbHelper.clearChartData();
        await _dbHelper.insertChartData(chartDataString);
      } else {
        errorMessage.value = 'Failed to load data with status code: ${response.statusCode}';
        hasError(true);
      }
    } catch (e) {
      errorMessage.value = 'Failed to load data from API: $e';
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
        series.add({'name': key.replaceAll('_[kW]', ''), 'data': convertedData, "visible": !(key.startsWith('Main') || key.startsWith('Generator'))});
      }
    });

    return json.encode({'categories': categories, 'series': series});
  }
}

class ColumnChartScreenForMonth extends StatelessWidget {
  final MonthColoumDataControllerss controller = Get.put(MonthColoumDataControllerss());

  late final WebViewController webViewController = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..enableZoom(false)
    ..clearCache()
    ..setBackgroundColor(Colors.transparent)
    ..loadFlutterAsset('assets/js/hc_index.html')
    ..setNavigationDelegate(NavigationDelegate(
      onPageStarted: (url) {
        if (webViewController.platform is AndroidWebViewController) {
          AndroidWebViewController.enableDebugging(kDebugMode);
        }

        if (webViewController.platform is WebKitWebViewController) {
          final WebKitWebViewController webKitWebViewController = webViewController.platform as WebKitWebViewController;
          webKitWebViewController.setInspectable(kDebugMode);
        }
      },
      onPageFinished: (url) {
        webViewController.runJavaScript('jsColumnChartFunc(${jsonEncode(controller.chartData.value)});');
      },
    ));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.isTrue) {
          return Center(child: CircularProgressIndicator());
        } else if (controller.hasError.isTrue) {
          return Center(child: Text('Error loading data.'));
        } else if (controller.errorMessage.isNotEmpty) {
          return Center(child: Text(controller.errorMessage.value, style: TextStyle(color: Colors.red)));
        } else {
          return SizedBox(
            height: 500,
            child: WebViewWidget(
              controller: webViewController,
            ),
          );
        }
      }),
    );
  }
}
