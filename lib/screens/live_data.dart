// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
// class Live extends StatefulWidget {
//   const Live({super.key});
//
//   @override
//   State<Live> createState() => _LiveState();
// }
//
// class _LiveState extends State<Live> {
//   Map<String, dynamic> dayData = controller.kwData[index];
//   String formattedDate = dayData['date'];
//   List<Map<String, dynamic>> newData = dayData['data'];
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: [
//
//         ],
//       ),
//     );
//   }
// }
//
//
// class StockColumnWidget extends StatelessWidget {
//   const StockColumnWidget({Key? key, required this.data}) : super(key: key);
//
//   final List<Map<String, dynamic>> data;
//
//   @override
//   Widget build(BuildContext context) {
//     final String chartData = _generateChartData(data);
//
//     return HighCharts(
//       loader: const SizedBox(
//         child: LinearProgressIndicator(),
//         width: 200,
//       ),
//       size: const Size(400, 400),
//       data: chartData,
//       scripts: const ["https://code.highcharts.com/highcharts.js"],
//     );
//   }
//
//   String _generateChartData(List<Map<String, dynamic>> data) {
//     List<Map<String, dynamic>> seriesData = data.asMap().entries.map((entry) {
//       int index = entry.key;
//       Map<String, dynamic> itemData = entry.value;
//
//       String prefixName = itemData['prefixName'];
//       double lastIndexValue = itemData['lastIndexValue'];
//
//       return {
//         'name': prefixName,
//         'y': lastIndexValue,
//       };
//     }).toList();
//
//     String seriesDataJson = jsonEncode(seriesData);
//
//     return '''
//     {
//       chart: {
//         type: 'column',
//       },
//       title: {
//         text: 'Stock Column',
//       },
//       xAxis: {
//         type: 'category',
//       },
//       yAxis: {
//         title: {
//           text: 'Value',
//         },
//       },
//       plotOptions: {
//         column: {
//           colorByPoint: true,
//         },
//       },
//       series: [{
//         name: 'Live Data',
//         data: $seriesDataJson,
//       }],
//     }
//     ''';
//   }
// }