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
import 'package:highcharts_demo/screens/dailyanalysi.dart';

import 'package:highcharts_demo/screens/splashe_screen.dart';
import 'package:highcharts_demo/test.dart';
import 'package:highcharts_demo/today.dart';

import 'heatmap.dart';
import 'heatsmap.dart';
import 'highcharts/area_chart.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final List<Map<String, dynamic>> kwData = [];

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: SplashScreen(),

      // },
    );
  }
}
