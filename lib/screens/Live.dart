import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:high_chart/high_chart.dart';
import 'package:highcharts_demo/widgets/custom_text.dart';
import 'package:highcharts_demo/widgets/side_drawer.dart';

import '../JS_Web_View/View/coloum_chart_for_live.dart';
import '../JS_Web_View/pie_for_live.dart';
import '../controller/Live/live_controller.dart';


class LiveDataScreen extends StatefulWidget {
  const LiveDataScreen({Key? key}) : super(key: key);

  @override
  State<LiveDataScreen> createState() => _LiveDataScreenState();
}

class _LiveDataScreenState extends State<LiveDataScreen> {
  final LiveDataControllers controller = Get.put(LiveDataControllers());
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    controller.fetchDataforlives();
    _timer = Timer.periodic(Duration(minutes: 1), (Timer timer) {
      controller.fetchDataforlives();
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
      body: Obx(() {
        if (controller.kwData.isEmpty) {
          return Center(child: Text(controller.isOnline.value ? "Loading..." : "Displaying offline data"));
        } else {
          return ListView(
            children: [
              // StockColumnWidget(data: controller.kwData),
              // SizedBox(height: 40),
              WebViewColumnChart(data: controller.kwData),
              // StockPieWidget(data: controller.kwData),
              SizedBox(height: 40),
              WebViewPieChart(data: controller.kwData),


            ],
          );
        }
      }),
    );
  }
}


class StockColumnWidget extends StatelessWidget {
  const StockColumnWidget({Key? key, required this.data}) : super(key: key);

  final List<Map<String, dynamic>> data;

  @override
  Widget build(BuildContext context) {
    final String chartData = _generateChartData(data);
    // Debugging: Print the chart data to the console
    print("Chart Data: $chartData");
    return HighCharts(
      loader: Center(child: Text('Loading...')),
      size: const Size(400, 400),
      data: chartData,
      scripts: const ["https://code.highcharts.com/highcharts.js"],
    );
  }

  String _generateChartData(List<Map<String, dynamic>> data) {
    if (data.isEmpty) {
      Get.snackbar('dff', "No data available");
      return "No data available";
    }
    List<Map<String, dynamic>> seriesData = data.asMap().entries.map((entry) {
      String name = entry.value['name'].replaceAll('_[kW]', '');
      double originalValue = entry.value['value'];
      double scaledValue = originalValue / 1000;
      String formattedValue = scaledValue.toStringAsFixed(1) + ' kW';
      return {
        'name': name,
        'y': scaledValue,
        'formattedValue': formattedValue,
      };
    }).toList();

    String seriesDataJson = jsonEncode(seriesData);
    return '''
    {
      chart: {
        type: 'column'
      },
      title: {
        text: ''
      },
      xAxis: {
        type: 'category'
      },
      yAxis: {
        title: {
          text: 'Power (kW)'
        },
        labels: {
          enabled: false
        },
        min: 0,
        startOnTick: false,
        endOnTick: false,
        gridLineWidth: 0,
        minorGridLineWidth: 0,
        lineColor: 'transparent',
        minorTickLength: 0,
        tickLength: 0
      },
      tooltip: {
        formatter: function() {
          return '<b>' + this.point.name + '</b><br/>' +
                 'Power: ' + this.point.formattedValue;
        }
      },
      plotOptions: {
        column: {
          colorByPoint: true,
          pointPadding: 0.1,
          groupPadding: 0.1,
          borderWidth: 0,
          minPointLength: 3
        }
      },
      series: [{
        name: 'kW',
        data: $seriesDataJson
      }]
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
    double totalSum = data.fold(0, (sum, item) => sum + item['value'] / 1000);  // Scale the sum calculation

    List<Map<String, dynamic>> seriesData = data.map((item) {
      String name = item['name'].replaceAll('_[kW]', '');  // Clean name
      double scaledValue = item['value'] / 1000;  // Scale down the value
      double percentage = (totalSum == 0) ? 0 : (scaledValue / totalSum * 100);  // Calculate percentage based on scaled value
      String formattedValue = scaledValue.toStringAsFixed(3) + ' kW';  // Format the scaled value for display

      return {
        'name': name,
        'y': percentage.round(),
        'formattedValue': formattedValue,  // Use for tooltip display
      };
    }).toList();

    String seriesDataJson = jsonEncode(seriesData);

    return '''
    {
      chart: {
        type: 'pie'
      },
      title: {
        text: 'Appliance Energy Distribution'
      },
      tooltip: {
        formatter: function() {
          return '<b>' + this.point.name + '</b><br/>' +
                 'Energy Share: ' + this.point.y.toFixed(1) + '%<br/>' +
                 'Power: ' + this.point.formattedValue;  // Display the scaled value and percentage
        }
      },
      plotOptions: {
        pie: {
          allowPointSelect: true,
          cursor: 'pointer',
          dataLabels: {
            enabled: true,
            format: '<b>{point.name}</b>: {point.y:.1f}%'
          }
        }
      },
      series: [{
        name: 'Energy Share',
        colorByPoint: true,
        data: $seriesDataJson
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
// import 'package:highcharts_demo/widgets/custom_text.dart';
// import 'package:highcharts_demo/widgets/side_drawer.dart';
//
// import 'dart:convert';
//
// import '../controller/Live/live_controller.dart';
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


