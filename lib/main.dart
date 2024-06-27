import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:highcharts_demo/screens/splashe_screen.dart';

import 'controller/ThemeController.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(EnViz());
}

class EnViz extends StatelessWidget {
  final List<Map<String, dynamic>> kwData = [];
  final ThemeController themeController = Get.put(ThemeController());

   EnViz({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData.light(),
      themeMode: ThemeMode.light,
      home: const SplashScreen(),
    );
  }
}
