import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../controller/historical/historical_controller.dart';

class Heatmap extends StatefulWidget {
  @override
  State<Heatmap> createState() => _HeatmapState();
}

class _HeatmapState extends State<Heatmap> {
  final HistoricalController controller = Get.put(HistoricalController());
  late WebViewController webViewController;

  @override
  void initState() {
    // controller.fetchDataForHeatmap();
    super.initState();
    setupWebViewController();
  }

  void setupWebViewController() {
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..enableZoom(true)
      ..clearCache()
      ..setBackgroundColor(Colors.transparent)
      ..loadFlutterAsset('assets/js/hc_index.html');
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          } else if (controller.chartData.value.isEmpty) {
            return const Center(
                child: Text(
                    "No data available. Please check your internet connection."));
          } else {
            String jsCall =
                "jsHeatmapFunc(${controller.chartData.value}, '${controller.startDate.value}', '${controller.endDate.value}');";
            webViewController.runJavaScript(jsCall);
            // controller.fetchDataForHeatmap();
            return SizedBox(
              height: 700,
              child: WebViewWidget(controller: webViewController),
            );
          }
        }),
      ],
    );
  }
  @override
  void dispose() {
    webViewController.clearCache();
    super.dispose();
  }
}
