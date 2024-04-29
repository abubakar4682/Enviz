import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:high_chart/high_chart.dart';
import 'package:highcharts_demo/widgets/CustomText.dart';
import 'package:highcharts_demo/widgets/SideDrawer.dart';

import '../controller/Live/LiveController.dart';
import '../controller/datacontroller.dart';

class LiveDataScreen extends StatefulWidget {
  const LiveDataScreen({Key? key}) : super(key: key);

  @override
  State<LiveDataScreen> createState() => _LiveDataScreenState();
}

class _LiveDataScreenState extends State<LiveDataScreen> {
  final controller = Get.put(LiveDataControllers());
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    controller.fetchDataforlive();
    _timer = Timer.periodic(Duration(minutes: 1), (Timer timer) {
      controller.fetchDataforlive();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Sidedrawer(context: context),
      appBar: AppBar(
        title: Center(
          child: CustomText(
            texts: 'Live',
            textColor: const Color(0xff002F46),
          ),
        ),
        actions: [
          SizedBox(
            width: 40,
            height: 30,
            child: Image.asset('assets/images/Vector.png'),
          ),
        ],
      ),
      body: Obx(
            () => ListView.builder(
          itemCount: controller.kwData.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> dayData = controller.kwData[index];
            List<Map<String, dynamic>> newData = dayData['data'];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StockColumnWidget(data: newData),
                SizedBox(height: 40),
                SizedBox(
                  height: 700,
                  width: 700,
                  child: StockPieWidget(data: newData),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class StockColumnWidget extends StatelessWidget {
  const StockColumnWidget({Key? key, required this.data}) : super(key: key);

  final List<Map<String, dynamic>> data;

  @override
  Widget build(BuildContext context) {
    final String chartData = _generateChartData(data);
    return HighCharts(
      loader: Center(child: Text('Loading...')),
      size: const Size(400, 400),
      data: chartData,
      scripts: const ["https://code.highcharts.com/highcharts.js"],
    );
  }

  String _generateChartData(List<Map<String, dynamic>> data) {
    List<Map<String, dynamic>> seriesData = data.asMap().entries.map((entry) {
      int index = entry.key;
      Map<String, dynamic> itemData = entry.value;

      String prefixName = itemData['prefixName'];
      double lastIndexValue = itemData['lastIndexValue'] ?? 0.0; // Ensure fallback to 0.0 for null or invalid data

      // Use the formatToKW method from DataControllers
      String formattedValue = DataControllers().formatToKW(lastIndexValue);

      return {
        'name': prefixName,
        'y': lastIndexValue,  // Use the original value for chart display
        'formattedValue': formattedValue,  // Use the formatted value for display
      };
    }).toList();

    String seriesDataJson = jsonEncode(seriesData);

    return '''
    {
      chart: {
        type: 'column',
      },
      title: {
        text: 'Live Data',
      },
      xAxis: {
        type: 'category',
      },
      yAxis: {
        title: {
          text: 'Power(kW)',
        },
      },
      plotOptions: {
        column: {
          colorByPoint: true,
        },
      },
      tooltip: {
        formatter: function() {
          return '<b>' + this.point.name + '</b><br/>' +
                 'Power: ' + this.point.formattedValue + ' kW';
        }
      },
      series: [{
        name: '',
        data: $seriesDataJson,
      }],
    }
    ''';
  }
}

class StockPieWidget extends StatelessWidget {
  const StockPieWidget({Key? key, required this.data}) : super(key: key);

  final List<Map<String, dynamic>> data;

  @override
  Widget build(BuildContext context) {
    final String chartData = _generateChartData(data);
    return HighCharts(
      loader: Center(child: Text('Loading...')),
      size: const Size(600, 600),
      data: chartData,
      scripts: const ["https://code.highcharts.com/highcharts.js"],
    );
  }

  String _generateChartData(List<Map<String, dynamic>> data) {
    if (data.isEmpty) {
      return ''; // Handle empty data case
    }

    // Filter out the data for the "Main" category
    List<Map<String, dynamic>> filteredData = data.where((item) => item['prefixName'] != 'Main').toList();

    // Calculate the total sum of all values excluding "Main"
    double totalSum = filteredData.fold(0, (sum, item) => sum + (item['lastIndexValue'] ?? 0.0));

    // Ensure totalSum is not zero to avoid division by zero when calculating percentage
    if (totalSum == 0) {
      return '{"series": []}'; // Return empty series if totalSum is zero to avoid further calculations
    }

    // Calculate the percentage for each value excluding "Main" and format values
    List<Map<String, dynamic>> seriesData = filteredData.map((itemData) {
      String prefixName = itemData['prefixName'];
      double lastIndexValue = itemData['lastIndexValue'] ?? 0.0; // Provide a default value
      double percentage = ((lastIndexValue / totalSum) * 100).isNaN ? 0.0 : ((lastIndexValue / totalSum) * 100).roundToDouble();

      return {
        'name': prefixName,
        'y': percentage,
        'formattedValue': DataControllers().formatToKW(lastIndexValue),  // Use method to format lastIndexValue to kW
      };
    }).toList();

    String seriesDataJson = jsonEncode(seriesData);

    return '''
    {
      "chart": {
        "type": "pie",
        "size": "75%"
      },
      "title": {
        "text": "Appliance Share"
      },
      "tooltip": {
        "valueSuffix": "%",
        "pointFormat": "Power: <b>{point.formattedValue}</b>"
      },
      "plotOptions": {
        "pie": {
          "allowPointSelect": true,
          "cursor": "pointer",
          "dataLabels": {
            "enabled": true,
            "format": "<b>{point.name}</b>: {point.y}%"
          }
        }
      },
      "series": [{
        "name": "Live Data",
        "data": $seriesDataJson
      }]
    }
    ''';
  }
}


// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get/get_core/src/get_main.dart';
// import 'package:high_chart/high_chart.dart';
// import 'package:highcharts_demo/widgets/CustomText.dart';
// import 'package:highcharts_demo/widgets/SideDrawer.dart';
//
// import 'dart:convert';
//
// import '../controller/Live/LiveController.dart';
// import '../controller/datacontroller.dart';
//
//
// class LiveDataScreen extends StatefulWidget {
//   const LiveDataScreen({Key? key}) : super(key: key);
//
//   @override
//   State<LiveDataScreen> createState() => _LiveDataScreenState();
// }
//
// class _LiveDataScreenState extends State<LiveDataScreen> {
//   final  controller = Get.put(LiveDataControllers());
//   late Timer _timer;
//
//   @override
//   void initState() {
//     controller.fetchDataforlive();
//     _timer = Timer.periodic(Duration(minutes: 1), (Timer timer) {
//       controller.fetchDataforlive();
//     });
//     // TODO: implement initState
//     super.initState();
//   }
//   @override
//   void dispose() {
//     // Cancel the timer when the widget is disposed
//     _timer.cancel();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         drawer: Sidedrawer(context: context),
//         appBar: AppBar(
//           title: Center(
//             child: CustomText(
//               texts: 'Live',
//               textColor: const Color(0xff002F46),
//             ),
//           ),
//           actions: [
//             SizedBox(
//               width: 40,
//               height: 30,
//               child: Image.asset('assets/images/Vector.png'),
//             ),
//           ],
//         ),
//
//         body:  Obx(
//               () => ListView.builder(
//             itemCount: controller.kwData.length,
//             itemBuilder: (context, index) {
//               Map<String, dynamic> dayData = controller.kwData[index];
//               List<Map<String, dynamic>> newData = dayData['data'];
//
//               return Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   StockColumnWidget(data: newData),
//                   SizedBox(
//                     height: 40,
//                   ),
//                   SizedBox(
//                       height: 700,
//                       width: 700,
//                       child: StockPieWidget(data: newData,)),
//                 ],
//               );
//             },
//           ),
//         )
//     );
//   }
// }
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
//       loader: Center(
//         child: Text('Loading...'),
//       ),
//       size: const Size(400, 400),
//       data: chartData,
//       scripts: const ["https://code.highcharts.com/highcharts.js"],
//     );
//   }
//   String _generateChartData(List<Map<String, dynamic>> data) {
//     List<Map<String, dynamic>> seriesData = data.asMap().entries.map((entry) {
//       int index = entry.key;
//       Map<String, dynamic> itemData = entry.value;
//
//       String prefixName = itemData['prefixName'];
//       double lastIndexValue = itemData['lastIndexValue'];
//
//       // Use the formatToKW method from DataControllers
//       String formattedValue = DataControllers().formatToKW(lastIndexValue);
//
//       return {
//         'name': prefixName,
//         'y': lastIndexValue,  // Use the original value for chart display
//         'formattedValue': formattedValue,  // Use the formatted value for display
//       };
//     }).toList();
//
//     String seriesDataJson = jsonEncode(seriesData);
//
//     return '''
//   {
//     chart: {
//       type: 'column',
//     },
//     title: {
//       text: 'Live Data',
//     },
//     xAxis: {
//       type: 'category',
//     },
//     yAxis: {
//       title: {
//         text: 'Power(kW)',
//       },
//     },
//     plotOptions: {
//       column: {
//         colorByPoint: true,
//       },
//     },
//     tooltip: {
//       formatter: function() {
//         return '<b>' + this.point.name + '</b><br/>' +
//                'Power: ' + this.point.formattedValue + 'W'; // Add ' kW' here
//       }
//     },
//     series: [{
//       name: '',
//       data: $seriesDataJson,
//     }],
//   }
//   ''';
//   }
//
//
// }
//
//
//
// class StockPieWidget extends StatelessWidget {
//   const StockPieWidget({Key? key, required this.data}) : super(key: key);
//
//   final List<Map<String, dynamic>> data;
//
//   @override
//   Widget build(BuildContext context) {
//     final String chartData = _generateChartData(data);
//
//     return HighCharts(
//       loader: Center(
//         child: Text('Loading...'),
//       ),
//       size: const Size(600, 600), // Increase the size of the pie chart
//       data: chartData,
//       scripts: const ["https://code.highcharts.com/highcharts.js"],
//     );
//   }
//
//
//   String _generateChartData(List<Map<String, dynamic>> data) {
//     if (data.isEmpty) {
//       return ''; // Handle empty data case
//     }
//
//     // Filter out the data for the "Main" category
//     List<Map<String, dynamic>> filteredData = data.where((item) => item['prefixName'] != 'Main').toList();
//
//     // Calculate the total sum of all values excluding "Main"
//     double totalSum = filteredData.fold(0, (sum, item) => sum + (item['lastIndexValue'] ?? 0.0));
//
//     // Helper function to format numbers into "kW" notation
//     String formatNumber(double value) {
//       // Convert to kW first
//       double valueInKW = value / 1000;
//       if (valueInKW >= 1) {
//         // If value is 1kW or more, format with "k" and add "kW"
//         return '${valueInKW.toStringAsFixed(3)} kW';
//       } else {
//         // If less than 1kW, just show in kW without "k"
//         return '${valueInKW.toStringAsFixed(3)} kW';
//       }
//     }
//
//     // Calculate the percentage for each value excluding "Main" and format values
//     List<Map<String, dynamic>> seriesData = filteredData.map((itemData) {
//       String prefixName = itemData['prefixName'];
//       double lastIndexValue = itemData['lastIndexValue'] ?? 0.0; // Provide a default value
//       double percentage = ((lastIndexValue / totalSum) * 100.0).roundToDouble();
//
//       return {
//         'name': prefixName,
//         'y': percentage,
//         // Adding formatted value for display in tooltip
//         'formattedValue': formatNumber(lastIndexValue),
//       };
//     }).toList();
//
//     String seriesDataJson = jsonEncode(seriesData);
//
//     return '''
// {
//   chart: {
//     type: 'pie',
//      size: '75%',
//   },
//   title: {
//     text: 'Appliance Share',
//   },
//   tooltip: {
//       valueSuffix: '%',
//       // Modify to show formatted value with "kW"
//       pointFormat: 'Power: <b>{point.formattedValue}</b>'
//   },
//   plotOptions: {
//     pie: {
//       allowPointSelect: true,
//       cursor: 'pointer',
//       dataLabels: {
//         enabled: true,
//         format: '<b>{point.name}</b>: {point.y}%', // Show item name and percentage
//       },
//     },
//   },
//   series: [{
//     name: 'Live Data',
//     data: $seriesDataJson,
//   }],
// }
// ''';
//   }
//
//
// }


