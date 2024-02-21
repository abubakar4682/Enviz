import 'dart:async';
import 'dart:math';

import 'package:fl_heatmap/fl_heatmap.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';

import '../controller/datacontroller.dart';
import '../heatmap.dart';
import '../highcharts/WeekChart.dart';
import '../highcharts/stock_column.dart';
import '../nothing2.dart';
import '../pichart.dart';
import '../sevenday.dart';
import '../today.dart';
import '../widgets/BoxwithIcon.dart';
import '../widgets/CustomText.dart';
import '../widgets/MinMaxandAvg.dart';
import '../widgets/SideDrawer.dart';
import '../widgets/StartingndEnding.dart';
import '../widgets/switch_button.dart';

class Historical extends StatefulWidget {
  const Historical({Key? key}) : super(key: key);

  @override
  State<Historical> createState() => _HistoricalState();
}

class _HistoricalState extends State<Historical> {
  final controller = Get.put(ApiController());
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
  HeatmapItem? selectedItem;
  late HeatmapData heatmapDataPower;

  @override
  void initState() {
    _initExampleData();
    super.initState();
    //  _fetchAllData();
  }

  void _initExampleData() {
    const rows = [
      '2022',
      '2021',
      '2020',
      '2019',
      '2018',
      '2017',
      '2016',
      '2015',
    ];
    const columns = [
      'Jan',
      'Feb',
      'Mär',
      'Apr',
      'Mai',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Okt',
      'Nov',
      'Dez',
    ];
    final r = Random();
    const String unit = 'kWh';
    final items = [
      for (int row = 0; row < rows.length; row++)
        for (int col = 0; col < columns.length; col++)
          if (!(row == 3 &&
              col <
                  2)) // Do not add the very first item (incomplete data edge case)
            HeatmapItem(
                value: r.nextDouble() * 6,
                style: row == 0 && col > 1
                    ? HeatmapItemStyle.hatched
                    : HeatmapItemStyle.filled,
                unit: unit,
                xAxisLabel: columns[col],
                yAxisLabel: rows[row]),
    ];
    heatmapDataPower = HeatmapData(
      rows: rows,
      columns: columns,
      radius: 6.0,
      items: items,
    );
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
    final title = selectedItem != null
        ? '${selectedItem!.value.toStringAsFixed(2)} ${selectedItem!.unit}'
        : '--- ${heatmapDataPower.items.first.unit}';
    final subtitle = selectedItem != null
        ? '${selectedItem!.xAxisLabel} ${selectedItem!.yAxisLabel}'
        : '---';
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
             SelectStartndEndingDate(controller: controller, context: context),
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

            // Padding(
            //   padding: const EdgeInsets.only(left: 10, right: 10),
            //   child: Row(
            //     children: [
            //       Expanded(
            //         flex: 1,
            //         child: Container(
            //           height: 110,
            //           width: 150,
            //           decoration: BoxDecoration(
            //             color: Color(0xff002f46),
            //             borderRadius: BorderRadius.circular(20),
            //           ),
            //           child: Padding(
            //             padding: const EdgeInsets.all(8.0),
            //             child: Column(
            //               mainAxisAlignment: MainAxisAlignment.start,
            //               crossAxisAlignment: CrossAxisAlignment.start,
            //               children: [
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //                   crossAxisAlignment: CrossAxisAlignment.start,
            //                   children: [
            //                     CustomText(
            //                       texts: 'cost',
            //                       textColor: Color(0xff009f8d),
            //                     ),
            //                     SizedBox(
            //                       width: 20,
            //                       height: 20,
            //                       child: Image.asset(
            //                           'assets/images/moneylogo.png'),
            //                     ),
            //                   ],
            //                 ),
            //                 Text(
            //                   'Rs. 500',
            //                   style: const TextStyle(
            //                     fontSize: 24,
            //                     fontWeight: FontWeight.w700,
            //                     height: 1.5,
            //                     color: Colors.white,
            //                   ),
            //                 ),
            //               ],
            //             ),
            //           ),
            //         ),
            //       ),
            //       const SizedBox(
            //         width: 10,
            //       ),
            //       Expanded(
            //         flex: 1,
            //         child: Container(
            //           height: 110,
            //           width: 150,
            //           decoration: BoxDecoration(
            //             color: Color(0xff002f46),
            //             borderRadius: BorderRadius.circular(20),
            //           ),
            //           child: Padding(
            //             padding: const EdgeInsets.all(8.0),
            //             child: Column(
            //               mainAxisAlignment: MainAxisAlignment.start,
            //               crossAxisAlignment: CrossAxisAlignment.start,
            //               children: [
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //                   crossAxisAlignment: CrossAxisAlignment.start,
            //                   children: [
            //                     CustomText(
            //                       texts: 'power',
            //                       textColor: Color(0xff009f8d),
            //                     ),
            //                     SizedBox(
            //                       width: 20,
            //                       height: 20,
            //                       child: Image.asset(
            //                           'assets/images/Lightning Bolt.png'),
            //                     ),
            //                   ],
            //                 ),
            //                 SizedBox(
            //                   height: 10,
            //                 ),
            //
            //
            //                 Text(
            //                   '85 KW',
            //                   style: const TextStyle(
            //                     fontSize: 28,
            //                     fontWeight: FontWeight.w700,
            //                     height: 1.5,
            //                     color: Colors.white,
            //                   ),
            //                 ),
            //               ],
            //             ),
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            SizedBox(
              height: 20,
            ),

            // MinAvgValueBox(),

            SizedBox(
              height: 30,
            ),
            // Container(
            //     height: 200,
            //     width: MediaQuery.of(context).size.width,
            //     child: Heatmap(
            //         onItemSelectedListener: (HeatmapItem? selectedItem) {
            //           debugPrint(
            //               'Item ${selectedItem?.yAxisLabel}/${selectedItem?.xAxisLabel} with value ${selectedItem?.value} selected');
            //           setState(() {
            //             this.selectedItem = selectedItem;
            //           });
            //         },
            //         rowsVisible: 5,
            //         heatmapData: heatmapDataPower)),
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


        //   _buildSummaryText('Total Power:', controller.formatValue(totalSum)),
        // //  _buildSummaryText('Min Power:', controller.formatValue(minSum)),
        //   _buildSummaryText('Max Power:', controller.formatValue(maxSum)),
        //   _buildSummaryText('Average Power:', controller.formatValue(avgSum)),
        //   buildBox('Min Power',controller.formatValue(minSum),'assets/images/Minus.png'),
        //  // buildBox('Total Power',controller.formatValue(totalSum),'assets/images/Minus.png'),
        //   buildBox('Average Power',controller.formatValue(avgSum),'assets/images/Minus.png'),
        //   buildBox('Max Power',controller.formatValue(maxSum),'assets/images/Minus.png'),
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
}


