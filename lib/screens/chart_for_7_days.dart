// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
// import '../controller/Live/live_controller.dart';
// import '../controller/authcontroller/authcontroller.dart';
// import '../controller/datacontroller.dart';
// import '../highcharts/LiveChart.dart';
// import '../highcharts/stock_column.dart';
//
// class Chart extends StatefulWidget {
//
//
//   @override
//   State<Chart> createState() => _ChartState();
// }
//
// class _ChartState extends State<Chart> {
//   final LiveDataControllers controllerz = LiveDataControllers();
//
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//       future: controllerz.fetchDataforlive(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.done) {
//           // If the asynchronous operation is complete, show the Livechart
//           return Text('hello');
//           // return Livechart(controllers: controllerz);
//         } else {
//           // If the asynchronous operation is still ongoing, show a loading indicator
//           return Scaffold(
//             appBar: AppBar(
//               title: Text('Loading...'),
//             ),
//             body: Center(
//               child: CircularProgressIndicator(),
//             ),
//           );
//         }
//       },
//     );
//   }
// }
