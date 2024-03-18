// import 'package:enfo_ai/shortsgraph.dart';
// import 'package:flutter/material.dart';
//
//
// void main() {
//   runApp( MyApp());
// }
//
// class MyApp extends StatelessWidget {
//    MyApp({Key? key}) : super(key: key);
//   final Controllers controllers = Controllers();
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text("HighCharts Demo"),
//           centerTitle: true,
//         ),
//         body:  FutureBuilder(
//           future: controllers.fetchData(),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.done) {
//               return StockColumn(controllers: controllers);
//             } else {
//               return Scaffold(
//                 appBar: AppBar(
//                   title: Text('Loading...'),
//                 ),
//                 body: Center(
//                   child: CircularProgressIndicator(),
//                 ),
//               );
//             }
//           },
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:highcharts_demo/screens/Historical.dart';


import 'package:highcharts_demo/screens/splashe_screen.dart';
import 'package:highcharts_demo/sevenday.dart';
import 'package:highcharts_demo/test.dart';
import 'package:highcharts_demo/today.dart';

import 'controller/ThemeController.dart';
import 'hcheatmap.dart';
import 'heatsmap.dart';
import 'itemapp.dart';


void main() {
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
      theme: ThemeData.light(), // Define your light theme
      darkTheme: ThemeData.dark(), // Define your dark theme
      themeMode: ThemeMode.system,
      home: SplashScreen(),

      // },
    );
  }
}
