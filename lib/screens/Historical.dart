import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:high_chart/high_chart.dart';

import '../controller/historical/historicalcontroller.dart';

import '../widgets/BoxwithIcon.dart';
import '../widgets/CustomText.dart';

import '../widgets/SideDrawer.dart';
import '../widgets/StartingndEnding.dart';


class Historical extends StatefulWidget {
  const Historical({Key? key}) : super(key: key);

  @override
  State<Historical> createState() => _HistoricalState();
}

class _HistoricalState extends State<Historical> {
  final controller = Get.put(HistoricalController());

  String formatToKilo(double value) {
    if (value >= 1000) {
      // If the value is greater than or equal to 1000, format it as kilos
      return '${(value / 1000).toStringAsFixed(2)}kW';
    } else {
      // Otherwise, just return the original value
      return '${(value / 1000).toStringAsFixed(2)}kW';

      // value.toStringAsFixed(2);
    }
  }
  late Timer _fetchDataTimer;


  @override
  void initState() {
    super.initState();

  }


  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    _fetchDataTimer.cancel();
    super.dispose();
  }

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return Scaffold(
      drawer: Sidedrawer(context: context),
      appBar: AppBar(
        title: Center(
          child: CustomText(
            texts: 'Historical',
            textColor: const Color(0xff002F46),
          ),
        ),
        actions: [
          BoxwithIcon(),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 30, right: 50, top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(
                    texts: 'start date',
                    textColor: Color(0xff002F46),
                  ),
                  CustomText(
                    texts: 'end date',
                    textColor: Color(0xff002F46),
                  ),
                ],
              ),
            ),
           //  SelectStartndEndingDate(controller: controller, context: context),
            Padding(
              padding:  const EdgeInsets.only(left: 10, right: 10,top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  Expanded(
                    flex: 1,
                    child: Container(
                      margin:  EdgeInsets.fromLTRB(0, 0, 10, 0),
                      padding:  EdgeInsets.fromLTRB(26, 4, 26, 0),
                      height:  40,
                      decoration:  BoxDecoration (
                        color:  Color(0xffffffff),
                        borderRadius:  BorderRadius.circular(60),
                        boxShadow:  [
                          BoxShadow(
                            color:  Color(0x26000000),
                            offset:  Offset(0, 11),
                            blurRadius:  12,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Obx(
                                () => Text('${controller.startDate.value}')
                          ),
                          IconButton(
                            icon: Icon(Icons.arrow_drop_down,size: 30,),
                            onPressed: () { controller.selectStartDate(context);
                        //    controller.fetchData();
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 40),



                  Expanded(
                    flex: 1,
                    child: Container(
                      margin:  EdgeInsets.fromLTRB(0, 0, 10, 0),
                      padding:  EdgeInsets.fromLTRB(26, 4, 26, 0),
                      height:  40,
                      decoration:  BoxDecoration (
                        color:  Color(0xffffffff),
                        borderRadius:  BorderRadius.circular(60),
                        boxShadow:  [
                          BoxShadow(
                            color:  Color(0x26000000),
                            offset:  Offset(0, 11),
                            blurRadius:  12,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Obx(
                                () => Text(' ${controller.endDate.value}'),
                          ),
                          //Text('${controller.endDate}'),
                          IconButton(
                            icon: Icon(Icons.arrow_drop_down,size: 30,),
                            onPressed: () { controller.selectEndDate(context);
                          //  controller.fetchData();
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Obx(() {
              final firstApiData = controller.firstApiData!.value;
              if (firstApiData == null || firstApiData.isEmpty) {
                return CircularProgressIndicator();
              } else {
                if (firstApiData.containsKey("Main")) {
                  return _buildUiForMain(firstApiData);
                } else {
                  List<String> modifiedKeys = firstApiData.keys
                      .map((key) => '$key\_[kW]')
                      .toList();
                  return _buildUiForOther(modifiedKeys);
                }
              }
            }),


            SizedBox(
              height: 20,
            ),
            Container(
              height: 500,
              child:    Obx(() {
                if (controller.kwData.isEmpty) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
                    child: HighCharts(
                      loader: const SizedBox(
                        height: 20,
                        width: 15,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                      size: const Size(400, 400),
                      data: _getChartData(controller.kwData, ),
                      scripts: const ["https://code.highcharts.com/highcharts.js"],
                    ),
                  );
                }
              }),),

          ],
        ),
      ),
    );
  }
  Widget _buildUiForMain(Map<String, dynamic> firstApiResponse) {
    return Obx(() {
      final secondApiData = controller.secondApiData!.value;
      if (secondApiData == null || secondApiData.isEmpty) {
        return CircularProgressIndicator();
      } else {
        List<double> sumsList = [];
        for (int i = 0; i < secondApiData["Main_[kW]"].length; i++) {
          double sum = controller.parseDouble(secondApiData["Main_[kW]"][i]);
          sumsList.add(sum);
        }

        double totalSum = controller.calculateTotalSum(sumsList);
        double minSum = controller.calculateMin(sumsList);
        double maxSum = controller.calculateMax(sumsList);
        double avgSum = controller.calculateAverage(sumsList);

        return _buildSummaryUi(totalSum, minSum, maxSum, avgSum);
      }
    });
  }
  Widget _buildSummaryUi(double totalSum, double minSum, double maxSum, double avgSum) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 110,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Color(0xff002f46),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText(
                                texts: 'cost',
                                textColor: Color(0xff009f8d),
                              ),
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: Image.asset(
                                    'assets/images/moneylogo.png'),
                              ),
                            ],
                          ),
                          Text(
                            'Rs.${controller.formatValued(totalSum*70)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              height: 1.5,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 110,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Color(0xff002f46),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText(
                                texts: 'power',
                                textColor: Color(0xff009f8d),
                              ),
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: Image.asset(
                                    'assets/images/Lightning Bolt.png'),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),


                          Text(
                            controller.formatValue(totalSum),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              height: 1.5,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 110,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Color(0xff002f46),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText(
                                texts: 'Min',
                                textColor: Color(0xff009f8d),
                              ),
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: Image.asset(
                                    'assets/images/Minus.png'),
                              ),
                            ],
                          ),
                          Text(
                            controller.formatValue(minSum),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              height: 1.5,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 110,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Color(0xff002f46),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText(
                                texts: 'Max',
                                textColor: Color(0xff009f8d),
                              ),
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: Image.asset(
                                    'assets/images/Plus.png'),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),


                          Text(
                            controller.formatValue(maxSum),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              height: 1.5,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 110,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Color(0xff002f46),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText(
                                texts: 'Avg',
                                textColor: Color(0xff009f8d),
                              ),
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: Image.asset(
                                    'assets/images/Disconnected.png'),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),


                          Text(
                            controller.formatValue(avgSum),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              height: 1.5,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

          ),


        ],
      ),
    );
  }

  Widget _buildSummaryText(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          ' $value',
          style: TextStyle(fontSize: 18),
        ),
        Divider(),
      ],
    );
  }
  Widget buildBox(String label, String value, String photoPath) {
    // Parse the value as double
    //double parsedValue = double.parse(value);
    String formattedValue = value.replaceAll('kW', '').trim();
    double parsedValue = double.tryParse(formattedValue) ?? 0.0;
    return Container(
      height: 85,
      width: 120,
      decoration: BoxDecoration(
        color: Color(0xff002f46),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                  style: TextStyle(
                      color: Color(0xff009f8d)
                  ),
                ),

                SizedBox(
                  width: 20,
                  height: 20,
                  child: Image.asset(photoPath),
                ),
              ],
            ),
            Text(
              // Format the value using the formatToKilo function
            value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                height: 1.5,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildUiForOther(List<String> modifiedKeys) {
    return Obx(() {
      final secondApiData = controller.secondApiData!.value;
      if (secondApiData == null || secondApiData.isEmpty) {
        return CircularProgressIndicator();
      } else {
        List<double> sumsList = [];
        for (int i = 0; i < secondApiData['1st Floor_[kW]'].length; i++) {
          double sum = controller.parseDouble(secondApiData['1st Floor_[kW]'][i]) +
              controller.parseDouble(secondApiData['Ground Floor_[kW]'][i]);
          sumsList.add(sum);
        }

        double totalSum = controller.calculateTotalSum(sumsList);
        double minSum = controller.calculateMin(sumsList);
        double maxSum = controller.calculateMax(sumsList);
        double avgSum = controller.calculateAverage(sumsList);

        return _buildSummaryUi(totalSum, minSum, maxSum, avgSum);
      }
    });
  }
  String _getChartData(List<Map<String, dynamic>> kwData) {
    List<Map<String, dynamic>> seriesData = [];
    List<String> legendNames = [];

    kwData.forEach((item) {
      String prefixName = item['prefixName'].replaceAll('_', ''); // Remove underscores
      if (prefixName == 'Main') {
        prefixName = 'Usage'; // Rename "Main" to "Usage"
      }
      List<double> values = item['values'];
      legendNames.add(prefixName); // Add key name to legends
      List<List<dynamic>> dataForSeries = [];

      // Assuming values are for each hour
      DateTime startDate = DateTime.parse(controller.startDate.value);
      DateTime endDate = DateTime.parse(controller.endDate.value);

      // Determine the number of hours between start and end dates
      int numberOfHours = endDate.difference(startDate).inHours;

      for (int i = 0; i <= numberOfHours; i++) {
        // Adjusting date to Pakistani time zone
        DateTime dateTime = startDate.add(Duration(hours: i));
        DateTime pakistaniDateTime = dateTime.toUtc().add(Duration(hours: 5));

        // Check if the date is within the range of start and end date
        if (dateTime.isAfter(startDate) && dateTime.isBefore(endDate)) {
          // Make sure the index 'i' is within the bounds of 'values'
          if (i < values.length) {
            dataForSeries.add([
              _getEpochMillis(pakistaniDateTime),
              values[i],
            ]);
          }
        }
      }

      seriesData.add({
        'name': prefixName,
        'data': dataForSeries,
        'visible': prefixName == 'Usage', // Set visibility flag to true for "Usage" and false for others
      });
    });

    List<String> seriesConfigList = [];
    seriesData.forEach((series) {
      String seriesName = series['name'];
      List<List<dynamic>> seriesData = series['data'];
      bool isVisible = series['visible'];

      seriesConfigList.add('''
{
  type: 'area',
  name: '$seriesName',
  data: ${jsonEncode(seriesData)},
  visible: $isVisible, // Set visibility
}
''');
    });

    String seriesConfig = seriesConfigList.join(',');

    return '''
{
  accessibility: {
    enabled: false
  },
  chart: {
    alignTicks: false
  },
  title: {
    text: 'Weekly Data Display'
  },
  xAxis: {
    type: 'datetime',
    dateTimeLabelFormats: {
      day: '%e %b',
    },
  },
  yAxis: {
    title: {
      text: 'Energy (kW)',
    },
  },
  legend: {
    enabled: true,
  },
  tooltip: {
    pointFormat: '<span style="color:{point.color}">\u25CF</span> {series.name}: <b>{point.y:.2f} kW</b><br/>'
  },
  series: [$seriesConfig],
}
''';
  }

//   String _getChartData(List<Map<String, dynamic>> kwData) {
//     List<Map<String, dynamic>> seriesData = [];
//     List<String> legendNames = [];
//
//     kwData.forEach((item) {
//       String prefixName = item['prefixName'].replaceAll('_', ''); // Remove underscores
//       List<double> values = item['values'];
//       legendNames.add(prefixName); // Add key name to legends
//       List<List<dynamic>> dataForSeries = [];
//
//       // Assuming values are for each hour
//       DateTime startDate = DateTime.parse(controller.startDate.value);
//       DateTime endDate = DateTime.parse(controller.endDate.value);
//
//       // Determine the number of hours between start and end dates
//       int numberOfHours = endDate.difference(startDate).inHours;
//
//       for (int i = 0; i <= numberOfHours; i++) {
//         // Adjusting date to Pakistani time zone
//         DateTime dateTime = startDate.add(Duration(hours: i));
//         DateTime pakistaniDateTime = dateTime.toUtc().add(Duration(hours: 5));
//
//         // Check if the date is within the range of start and end date
//         if (dateTime.isAfter(startDate) && dateTime.isBefore(endDate)) {
//           // Make sure the index 'i' is within the bounds of 'values'
//           if (i < values.length) {
//             dataForSeries.add([
//               _getEpochMillis(pakistaniDateTime),
//               values[i],
//             ]);
//           }
//         }
//       }
//
//       seriesData.add({
//         'name': prefixName,
//         'data': dataForSeries,
//       });
//     });
//
//     List<String> seriesConfigList = [];
//     seriesData.forEach((series) {
//       String seriesName = series['name'];
//       List<List<dynamic>> seriesData = series['data'];
//
//       seriesConfigList.add('''
// {
//   type: 'area',
//   name: '$seriesName',
//   data: ${jsonEncode(seriesData)},
// }
// ''');
//     });
//
//     String seriesConfig = seriesConfigList.join(',');
//
//     return '''
// {
//   accessibility: {
//     enabled: false
//   },
//   chart: {
//     alignTicks: false
//   },
//   title: {
//     text: 'Weekly Data Display'
//   },
//   xAxis: {
//     type: 'datetime',
//     dateTimeLabelFormats: {
//       day: '%e %b',
//     },
//   },
//   yAxis: {
//     title: {
//       text: 'Energy (kW)',
//     },
//   },
//   legend: {
//     enabled: true,
//   },
//   tooltip: {
//     pointFormat: '<span style="color:{point.color}">\u25CF</span> {series.name}: <b>{point.y:.2f} kW</b><br/>'
//   },
//   series: [$seriesConfig],
// }
// ''';
//   }







  int _getEpochMillis(DateTime dateTime) {
    return dateTime.millisecondsSinceEpoch;
  }
}


