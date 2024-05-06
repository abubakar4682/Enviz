import 'package:flutter/material.dart';
import 'package:high_chart/high_chart.dart';

class StackedColumnChart extends StatelessWidget {
  const StackedColumnChart({Key? key}) : super(key: key);

  final String _chartData = '''{
    accessibility: {
      enabled: false
    },
    chart: {
        type: 'column'
    },
    title: {
        text: 'Stacked Column Chart'
    },
    xAxis: {
        categories: ['1945', '1955', '1965', '1975', '1985', '1995', '2005', '2015']
    },
    yAxis: {
        min: 0,
        title: {
            text: 'Total warheads'
        },
        stackLabels: {
            enabled: true,
            style: {
                fontWeight: 'bold',
                color: 'gray'
            }
        }
    },
    tooltip: {
        headerFormat: '<b>{point.x}</b><br/>',
        pointFormat: '{series.name}: {point.y}<br/>Total: {point.stackTotal}'
    },
    plotOptions: {
        column: {
            stacking: 'normal',
            dataLabels: {
                enabled: true,
                color: 'white'
            }
        }
    },
    series: [{
        name: 'USA',
        data: [120, 300, 400, 700, 950, 1250, 1500, 1700]
    }, {
        name: 'USSR/Russia',
        data: [150, 225, 300, 500, 600, 750, 900, 1000]
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
          "https://code.highcharts.com/modules/exporting.js"
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
