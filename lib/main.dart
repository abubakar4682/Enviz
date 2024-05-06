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
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:highcharts_demo/screens/SummaryTab/summary_full_screen.dart';



import 'package:highcharts_demo/screens/splashe_screen.dart';
import 'package:highcharts_demo/summmer.dart';


import 'controller/ThemeController.dart';
import 'firebase_options.dart';
import 'highcharts/area_chart.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,


);


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
      theme: ThemeData.light(), // Sets the light theme.
      // Removed darkTheme since it's not needed if you're always using light theme
      themeMode: ThemeMode.light,
      home:    SplashScreen(),
    );
  }
}
