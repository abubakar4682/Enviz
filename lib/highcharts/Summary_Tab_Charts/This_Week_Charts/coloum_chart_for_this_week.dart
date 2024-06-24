import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:get/get.dart';

import 'dart:convert';

import '../../../controller/Summary_Page_Controller/ChartsControllerForThisWeek/coloum_chart_for_this_week.dart';
class ColumnChartScreenForThisWeek extends StatelessWidget {
  final WeekDataControllerss controller = Get.put(WeekDataControllerss());

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
          return const Center(child: CircularProgressIndicator());
        } else if (controller.hasError.isTrue) {
          return const Center(child: Text('Error loading data.'));
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