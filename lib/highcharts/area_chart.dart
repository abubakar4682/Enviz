import 'package:flutter/material.dart';
import 'package:high_chart/high_chart.dart';

class AreaChart extends StatelessWidget {
  const AreaChart({Key? key}) : super(key: key);

  final String _chartData = '''{
    accessibility: {
      enabled: false
    },
    chart: {
        type: 'area'
    },
    title: {
        text: 'Area Chart'
    },
    xAxis: {
        allowDecimals: false,
        labels: {
            formatter: function () {
                return this.value; // clean, unformatted number for year
            }
        }
    },
    yAxis: {
        title: {
            text: 'Nuclear weapon states'
        },
        labels: {
            formatter: function () {
                return this.value / 1000 + 'k';
            }
        }
    },
    tooltip: {
        pointFormat: '{series.name} had stockpiled <b>{point.y:,.0f}</b><br/>warheads in {point.x}'
    },
    plotOptions: {
        area: {
            pointStart: 1940,
            marker: {
                enabled: false,
                symbol: 'circle',
                radius: 2,
                states: {
                    hover: {
                        enabled: true
                    }
                }
            }
        }
    },
    series: [{
        name: 'USA',
        data: [
            null, null, null, null, null, 6, 11, 32, 110, 235,
            369, 640, 1005, 1436, 2063, 3057, 4618, 6444, 9822, 15468,
            20434, 24126, 27387, 29459, 31056, 31982, 32040, 31233, 29224, 27342,
            26662, 26956, 27912, 28999, 28965, 27826, 25579, 25722, 24826, 24605,
            24304, 23464, 23708, 24099, 24357, 24237, 24401, 24344, 23586, 22380,
            21004, 17287, 14747, 13076, 12555, 12144, 11009, 10950, 10871, 10824,
            10577, 10527, 10475, 10421, 10358, 10295, 10104, 9914, 9620, 9326,
            5113, 5113, 4954, 4804, 4761, 4717, 4368, 4018
        ]
    }]
}''';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      child: HighCharts(
        loader: const SizedBox(
          child: LinearProgressIndicator(),
          width: 200,
        ),
        size: const Size(400, 400),
        data: _chartData,
        scripts: const [
          "https://code.highcharts.com/highcharts.js",
        ],
      ),
    );
  }
}










// import 'package:flutter/material.dart';


// import 'package:high_chart/high_chart.dart';
// import '../controller/datacontroller.dart'; // Import your controller class
//
// class AreaChart extends StatelessWidget {
//   final DataControllers controllers; // Add a reference to your controller
//   const AreaChart({Key? key, required this.controllers}) : super(key: key);
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
//         data: _getChartData(), // Use a method to generate dynamic chart data
//         scripts: const [
//           "https://code.highcharts.com/highcharts.js",
//         ],
//       ),
//     );
//   }
//
//   String _getChartData() {
//     // Extracting data from the DataControllers
//     List<Map<String, dynamic>> kwData = controllers.kwData;
//
//     // Generating dynamic chart data based on fetched data
//     String seriesData = '';
//     kwData.forEach((data) {
//       String formattedDate = data['date'];
//       List<Map<String, dynamic>> newData = data['data'];
//
//       List<double> values = [];
//       newData.forEach((itemData) {
//         String itemName = itemData['prefixName']; // Get the key name
//         List<double> itemValues = itemData['values'];
//         values.addAll(itemValues);
//
//         // Constructing series data with key names
//         seriesData += '''
//         {
//           name: '$itemName', // Include key name in legend
//           data: $itemValues,
//         },
//       ''';
//       });
//     });
//
//     // Constructing the chart configuration with the series data
//     return '''
//     {
//       accessibility: {
//         enabled: false
//       },
//       chart: {
//         type: 'area'
//       },
//       title: {
//         text: 'Area Chart'
//       },
//       xAxis: {
//         visible: false, // Hide x-axis
//       },
//       yAxis: {
//         title: {
//           text: 'Days' // Add label for y-axis
//         },
//         labels: {
//           formatter: function () {
//             return this.value + ' days'; // Format values to display as days
//           }
//         }
//       },
//       tooltip: {
//         // Customize tooltip as needed
//       },
//       plotOptions: {
//         area: {
//           // Customize plotOptions as needed
//         }
//       },
//       series: [$seriesData]
//     }
//   ''';
//   }
//
//
// }
