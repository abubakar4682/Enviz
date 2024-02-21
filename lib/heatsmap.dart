// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:highcharts_flutter/highcharts_flutter.dart';
// import 'package:flutter/services.dart' show rootBundle;
//
// void main() => runApp(HeatmapApp());
//
// class HeatmapApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: HeatmapPage(),
//     );
//   }
// }
//
// class HeatmapPage extends StatefulWidget {
//   @override
//   _HeatmapPageState createState() => _HeatmapPageState();
// }
//
// class _HeatmapPageState extends State<HeatmapPage> {
//   List<List<dynamic>>? heatmapData;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadHeatmapData();
//   }
//
//   Future<void> _loadHeatmapData() async {
//     final jsonString = await rootBundle.loadString('assets/heatmap_data.json');
//     final data = jsonDecode(jsonString) as List<List<dynamic>>;
//     setState(() {
//       heatmapData = data;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (heatmapData == null) {
//       return Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Heatmap'),
//       ),
//       body: Highcharts(
//         options: HCOptions(
//           chart: Chart(
//             type: ChartType.heatmap,
//           ),
//           xAxis: XAxis(
//             crosshair: true,
//           ),
//           yAxis: YAxis(
//             crosshair: true,
//           ),
//           tooltip: Tooltip(
//             shared: true,
//           ),
//           title: Title(
//             text: 'Heatmap',
//           ),
//           series: [
//             HCSeries(
//               data: heatmapData,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
