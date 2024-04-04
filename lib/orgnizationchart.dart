import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class OrgniChartScreen extends StatefulWidget {


  const OrgniChartScreen({Key? key,}) : super(key: key);

  @override
  _OrgniChartScreenState createState() => _OrgniChartScreenState();
}

class _OrgniChartScreenState extends State<OrgniChartScreen> {
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
// Call the JS function directly since the org chart data and config are included in the JS file
          webViewController.runJavaScript('jsOrgChartFunc();');
        },
      ));
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

















