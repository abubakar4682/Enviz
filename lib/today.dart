import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
class LineChartScreen extends StatefulWidget {
  final Map<String, List<String>> data;

  const LineChartScreen({Key? key, required this.data}) : super(key: key);

  @override
  _LineChartScreenState createState() => _LineChartScreenState();
}

class _LineChartScreenState extends State<LineChartScreen> {
  late final WebViewController webViewController;

  @override
  void initState() {
    super.initState();
    webViewController = WebViewController()
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
            final WebKitWebViewController webKitWebViewController =
            webViewController.platform as WebKitWebViewController;
            webKitWebViewController.setInspectable(kDebugMode);
          }
        },
        onPageFinished: (url) {
          // Serialize your data models to a string
          final xyValue = _serializeData(widget.data);
          webViewController.runJavaScript('jsHeatmapFunc($xyValue);');
        },
      ));
  }

  String _serializeData(Map<String, List<String>> data) {
    final List<String> serializedData = [];
    data.forEach((date, values) {
      values.asMap().forEach((index, value) {
        final x = index; // Assuming x represents hours
        final y = DateTime.parse(date).weekday - 1; // Adjusting for JavaScript's 0-based indexing
        final serializedEntry = '{x: $x, y: $y, value: $value}';
        serializedData.add(serializedEntry);
      });
    });
    return '[' + serializedData.join(',') + ']';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: WebViewWidget(
        controller: webViewController,
      ),
    );
  }
}




class OrgChartScreen extends StatefulWidget {
  const OrgChartScreen({Key? key}) : super(key: key);

  @override
  _OrgChartScreenState createState() => _OrgChartScreenState();
}

class _OrgChartScreenState extends State<OrgChartScreen> {
  late final WebViewController webViewController;

  @override
  void initState() {
    super.initState();
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..enableZoom(false)
      ..clearCache()
      ..setBackgroundColor(Colors.transparent)
      ..loadFlutterAsset('assets/js/org_chart_index.html')
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (url) {
          // Enable debugging if needed
          if (webViewController.platform is AndroidWebViewController) {
            AndroidWebViewController.enableDebugging(kDebugMode);
          }
          if (webViewController.platform is WebKitWebViewController) {
            final WebKitWebViewController webKitWebViewController =
            webViewController.platform as WebKitWebViewController;
            webKitWebViewController.setInspectable(kDebugMode);
          }
        },
        onPageFinished: (url) async {
          final responseData = await fetchApiData();
          final encodedData = jsonEncode(responseData);
          webViewController.runJavaScript('initializeOrgChart($encodedData);');
        },
      ));
  }

  Future<Map<String, dynamic>> fetchApiData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUsername = prefs.getString('username');
    final response = await http.get(Uri.parse('http://203.135.63.47:8000/buildingmap?username=$storedUsername'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load API data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Distribution Map"),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchApiData(), // Execute the fetchApiData method
        builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
          // Check connection state
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Return a circular progress indicator if data is still being fetched
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Return an error message if an error occurred
            return Center(child: Text("Error fetching data"));
          } else {
            // Once the data is fetched, display the WebView
            // Since data is fetched beforehand, you can directly pass it to your JavaScript initialization if needed
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
