
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';


import 'package:flutter/foundation.dart';

import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class WebViewColumnChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  WebViewColumnChart({required this.data});

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
        webViewController.runJavaScript('jsColumnChartFuncForLive($chartData);');
      },
    ));

  String _generateChartData(List<Map<String, dynamic>> data) {
    if (data.isEmpty) {
      Get.snackbar('dff', "No data available");
      return "No data available";
    }
    List<Map<String, dynamic>> seriesData = data.asMap().entries.map((entry) {
      String name = entry.value['name'].replaceAll('_[kW]', '');
      double originalValue = entry.value['value'];
      double scaledValue = originalValue / 1000;
      String formattedValue = scaledValue.toStringAsFixed(1) + ' kW';
      return {
        'name': name,
        'y': scaledValue,
        'formattedValue': formattedValue,
      };
    }).toList();

    String seriesDataJson = jsonEncode(seriesData);
    return seriesDataJson;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 600,
      child: WebViewWidget(controller: webViewController),
    );
  }
}
