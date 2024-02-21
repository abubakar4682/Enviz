import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:high_chart/high_chart.dart';
import 'package:highcharts_demo/widgets/CustomText.dart';
import 'package:highcharts_demo/widgets/SideDrawer.dart';

import 'dart:convert';

import 'controller/datacontroller.dart';

class LiveDataScreen extends StatefulWidget {
  const LiveDataScreen({Key? key}) : super(key: key);

  @override
  State<LiveDataScreen> createState() => _LiveDataScreenState();
}

class _LiveDataScreenState extends State<LiveDataScreen> {
  final  controller = Get.put(DataControllers());
  late Timer _timer;

  @override
  void initState() {
    controller.fetchDataforlive();
    _timer = Timer.periodic(Duration(minutes: 1), (Timer timer) {
      controller.fetchDataforlive();
    });
    // TODO: implement initState
    super.initState();
  }
  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
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

      body:  Obx(
            () => ListView.builder(
          itemCount: controller.kwData.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> dayData = controller.kwData[index];
            List<Map<String, dynamic>> newData = dayData['data'];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StockColumnWidget(data: newData),
                SizedBox(
                  height: 40,
                ),
                StockPieWidget(data: newData,),
              ],
            );
          },
        ),
      )
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
      loader: const SizedBox(
        child: CircularProgressIndicator(),
        width: 200,
      ),
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
      double lastIndexValue = itemData['lastIndexValue'];

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
               'Power: ' + this.point.formattedValue + 'W'; // Add ' kW' here
      }
    },
    series: [{
      name: 'Live Data',
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
      loader: const SizedBox(

        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
        width: 2,
        height: 5,

      ),
      size: const Size(600, 600), // Increase the size of the pie chart
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

    // Calculate the percentage for each value excluding "Main"
    List<Map<String, dynamic>> seriesData = filteredData.map((itemData) {
      String prefixName = itemData['prefixName'];
      double lastIndexValue = itemData['lastIndexValue'] ?? 0.0; // Provide a default value

      // Calculate the percentage and round it to two decimal places
      double percentage = ((lastIndexValue / totalSum) * 100.0).roundToDouble();

      return {
        'name': prefixName,
        'y': percentage,
      };
    }).toList();

    String seriesDataJson = jsonEncode(seriesData);

    return '''
{
  chart: {
    type: 'pie',
  },
  title: {
    text: 'Appliance Share',
  },
  tooltip: {
      valueSuffix: '%',
      pointFormat: 'Power: {point.y}'
  },
  plotOptions: {
    pie: {
      allowPointSelect: true,
      cursor: 'pointer',
      dataLabels: {
        enabled: true,
        format: '<b>{point.name}</b>', // Only show item name
      },
    },
  },
  series: [{
    name: 'Live Data',
    data: $seriesDataJson,
  }],
}
''';
  }




// String _generateChartData(List<Map<String, dynamic>> data) {
  //   // Calculate the total sum of all values
  //   double totalSum = data.fold(0, (sum, item) => sum + (item['lastIndexValue'] ?? 0.0));
  //
  //   // Calculate the percentage for each value
  //   List<Map<String, dynamic>> seriesData = data.map((itemData) {
  //     String prefixName = itemData['prefixName'];
  //     double lastIndexValue = itemData['lastIndexValue'] ?? 0.0; // Provide a default value
  //
  //     // Calculate the percentage
  //     double percentage = (lastIndexValue / totalSum) * 100.0;
  //
  //     return {
  //       'name': prefixName,
  //       'y': percentage,
  //       'tooltip': {
  //         'pointFormat': '<b>{point.name}:</b> {point.y:.2f}%'
  //       },
  //     };
  //   }).toList();
  //
  //   String seriesDataJson = jsonEncode(seriesData);
  //
  //   return '''
  //   {
  //     chart: {
  //       type: 'pie',
  //     },
  //     title: {
  //       text: 'Appliance Share',
  //     },
  //     plotOptions: {
  //       pie: {
  //         allowPointSelect: true,
  //         cursor: 'pointer',
  //         dataLabels: {
  //           enabled: true,
  //           format: '<b>{point.name}</b>: {point.y:.2f} %',
  //         },
  //       },
  //     },
  //     series: [{
  //       name: 'Live Data',
  //       data: $seriesDataJson,
  //     }],
  //   }
  //   ''';
  // }
}



//
// class Stock extends StatelessWidget {
//   const Stock({Key? key, required this.stockColumnData}) : super(key: key);
//
//   final List<List<dynamic>> stockColumnData;
//
//   @override
//   Widget build(BuildContext context) {
//     final String _chartData = '''
//       {
//         accessibility: {
//           enabled: false
//         },
//         chart: {
//           alignTicks: false
//         },
//         rangeSelector: {
//           selected: 1
//         },
//         title: {
//           text: 'Stock Column'
//         },
//         series: [
//           {
//             type: 'column',
//             name: 'Your Data Name', // Customize this
//             data: $stockColumnData,
//             // Other configurations...
//           }
//         ]
//       }
//     ''';
//
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
//       child: HighCharts(
//         loader: const SizedBox(
//           child: LinearProgressIndicator(),
//           width: 200,
//         ),
//         size: const Size(400, 400),
//         data: _chartData,
//         scripts: const ["https://code.highcharts.com/highcharts.js"],
//       ),
//     );
//   }
// }