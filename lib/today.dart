import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

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


