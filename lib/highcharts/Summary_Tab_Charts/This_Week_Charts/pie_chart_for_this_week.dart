import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/foundation.dart';

import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import '../../../controller/Summary_Page_Controller/ChartsControllerForThisWeek/pie_chart_this_week.dart';

class PieChartForThisWeek extends StatelessWidget {
  final PieChartControllerForThisWeek controller = Get.put(PieChartControllerForThisWeek());

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
        webViewController.runJavaScript('jsPieChartFunc(${jsonEncode(controller.pieChartData.value)});');
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

