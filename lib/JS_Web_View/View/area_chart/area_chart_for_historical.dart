import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import '../../../controller/historical/historical_controller.dart';

class AreaChartScreen extends StatefulWidget {
  @override
  _AreaChartScreenState createState() => _AreaChartScreenState();
}

class _AreaChartScreenState extends State<AreaChartScreen> {
  late final WebViewController webViewController;
  final HistoricalController historicalController = Get.put(HistoricalController());

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
      ));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      child: SizedBox(
        height: 400,
        child: Obx(() {
          if (historicalController.kwData.isEmpty) {
            return Center(child: Text('Loading...'));
          } else {
            final chartData = historicalController.getChartData();
            webViewController.runJavaScript('jsAreaChartFunc($chartData);');
            return WebViewWidget(
              controller: webViewController,
            );
          }
        }),
      ),
    );
  }
}
