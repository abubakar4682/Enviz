import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import '../controller/Live/live_controller.dart';
import 'dart:convert';
class WebViewPieChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  WebViewPieChart({required this.data});

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
          final WebKitWebViewController webKitWebViewController =
          webViewController.platform as WebKitWebViewController;
          webKitWebViewController.setInspectable(kDebugMode);
        }
      },
      onPageFinished: (url) {
        final chartData = _generateChartData(data);
        webViewController.runJavaScript('jsPieChartFuncForLive($chartData);');
      },
    ));

  String _generateChartData(List<Map<String, dynamic>> data) {
    double totalSum = data.fold(0, (sum, item) => sum + item['value'] / 1000);

    List<Map<String, dynamic>> seriesData = data.map((item) {
      String name = item['name'].replaceAll('_[kW]', '');
      double scaledValue = item['value'] / 1000;
      double percentage = (totalSum == 0) ? 0 : (scaledValue / totalSum * 100);
      String formattedValue = scaledValue.toStringAsFixed(3) + ' kW';

      return {
        'name': name,
        'y': percentage.round(),
        'formattedValue': formattedValue,
      };
    }).toList();

    return jsonEncode([{'name': 'Energy Share', 'colorByPoint': true, 'data': seriesData}]);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 600,
      child: WebViewWidget(controller: webViewController),
    );
  }
}
