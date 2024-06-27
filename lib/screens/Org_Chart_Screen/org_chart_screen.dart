import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../database/db_for_orgChart.dart';

class OrgChartScreen extends StatefulWidget {
  const OrgChartScreen({Key? key}) : super(key: key);

  @override
  _OrgChartScreenState createState() => _OrgChartScreenState();
}

class _OrgChartScreenState extends State<OrgChartScreen> {
  late final WebViewController webViewController;
  final DBHelper dbHelper = DBHelper();

  @override
  void initState() {
    super.initState();
    initializeWebView();
  }

  /// Initializes the WebView controller and its settings.
  void initializeWebView() {
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..enableZoom(false)
      ..clearCache()
      ..setBackgroundColor(Colors.transparent)
      ..loadFlutterAsset('assets/js/org_chart_index.html')
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (url) {
          enableWebViewDebugging();
        },
        onPageFinished: (url) async {
          await handlePageFinished();
        },
      ));
  }

  /// Enables debugging for the WebView based on the platform.
  void enableWebViewDebugging() {
    if (webViewController.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(kDebugMode);
    }
    if (webViewController.platform is WebKitWebViewController) {
      final WebKitWebViewController webKitWebViewController =
      webViewController.platform as WebKitWebViewController;
      webKitWebViewController.setInspectable(kDebugMode);
    }
  }

  /// Handles actions to be performed when the WebView page finishes loading.
  Future<void> handlePageFinished() async {
    try {
      final responseData = await fetchApiData();
      final encodedData = jsonEncode(responseData);
      webViewController.runJavaScript('initializeOrgChart($encodedData);');
      await dbHelper.insertData(encodedData);
    } catch (error) {
      print('Error initializing org chart: $error');
      final offlineData = await dbHelper.fetchData();
      if (offlineData != null) {
        webViewController.runJavaScript('initializeOrgChart($offlineData);');
      }
    }
  }

  /// Fetches API data based on the stored username in SharedPreferences.
  Future<Map<String, dynamic>> fetchApiData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUsername = prefs.getString('username');
    final response = await http.get(Uri.parse('http://203.135.63.47:8000/buildingmap?username=$storedUsername'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load API data with status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Distribution Map"),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchApiData(),
        builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else {
            return SizedBox(
              child: WebViewWidget(
                controller: webViewController,
              ),
            );
          }
        },
      ),
    );
  }
}
