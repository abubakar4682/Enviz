// import 'package:flutter/material.dart';
// import 'package:high_chart/high_chart.dart';
//
// class LineChart extends StatelessWidget {
//   const LineChart({Key? key}) : super(key: key);
//
//   final String _chartData = '''{
//     accessibility: {
//       enabled: false
//     },
//     title: {
//         text: 'Solar Employment Growth by Sector, 2010-2016'
//     },
//
//     subtitle: {
//         text: 'Source: thesolarfoundation.com'
//     },
//
//     yAxis: {
//         title: {
//             text: 'Number of Employees'
//         }
//     },
//
//     xAxis: {
//     },
//
//     legend: {
//         layout: 'vertical',
//         align: 'right',
//         verticalAlign: 'middle'
//     },
//
//     plotOptions: {
//         series: {
//             label: {
//                 connectorAllowed: false
//             },
//             pointStart: 2010
//         }
//     },
//
//     series: [{
//         name: 'Installation',
//         data: [43934, 52503, 57177, 69658, 97031, 119931, 137133, 154175]
//     }
//     ],
//
//     responsive: {
//         rules: [{
//             condition: {
//                 maxWidth: 500
//             },
//             chartOptions: {
//                 legend: {
//                     layout: 'horizontal',
//                     align: 'center',
//                     verticalAlign: 'bottom'
//                 }
//             }
//         }]
//     }
//
// }''';
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
//       child: HighCharts(
//         loader: const SizedBox(
//           child: LinearProgressIndicator(),
//           width: 200,
//         ),
//         size: const Size(400, 400),
//         data: _chartData,
//         scripts: const [
//           "https://code.highcharts.com/highcharts.js",
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:high_chart/high_chart.dart';

class LineChart extends StatelessWidget {
  final List<double> allValues;

  const LineChart({Key? key, required this.allValues}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String chartData = _generateChartData();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      child: HighCharts(
        loader: const SizedBox(
          child: SizedBox(
              height: 30,
              child: CircularProgressIndicator()),
          width: 200,
        ),
        size: const Size(400, 400),
        data: chartData,
        scripts: const [
          "https://code.highcharts.com/highcharts.js",
        ],
      ),
    );
  }

  String _generateChartData() {
    final StringBuffer data = StringBuffer();

    data.writeln("{");
    data.writeln("  title: {");
    data.writeln("    text: ''");
    data.writeln("  },");
    data.writeln("  series: [{");
    data.writeln("    name: 'Your Daily Usage',");
    data.write("    data: [");

    // Adding values from allValues list
    for (int i = 0; i < allValues.length; i++) {
      data.write("${allValues[i]}");
      if (i != allValues.length - 1) {
        data.write(", ");
      }
    }

    data.writeln("]");
    data.writeln("  }]");
    data.writeln("}");

    return data.toString();
  }
}

