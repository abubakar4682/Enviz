
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


import 'package:highcharts_demo/screens/splashe_screen.dart';

import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';

import 'JS_Web_View/View/area_chart/area_chart_for_historical.dart';
import 'JS_Web_View/pie_chart.dart';
import 'JS_Web_View/pie_for_live.dart';
import 'controller/ThemeController.dart';
import 'firebase_options.dart';
import 'highcharts/area_chart.dart';
import 'linechartdata.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Hive.initFlutter();
  await Hive.openBox('apiDataBox');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final List<Map<String, dynamic>> kwData = [];
  final ThemeController themeController = Get.put(ThemeController());

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData.light(),
      // Sets the light theme.
      // Removed darkTheme since it's not needed if you're always using light theme
      themeMode: ThemeMode.light,
      home: SplashScreen(),
    );
  }
}
