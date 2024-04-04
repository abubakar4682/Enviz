import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:highcharts_demo/pichart.dart';
import 'package:highcharts_demo/widgets/CustomText.dart';
import 'package:highcharts_demo/widgets/SideDrawer.dart';
import 'package:highcharts_demo/widgets/switch_button.dart';
import 'package:intl/intl.dart';

import 'controller/datacontroller.dart';
import 'controller/summaryedController.dart';
import 'highcharts/Coloumchartformonth.dart';
import 'highcharts/WeekChart.dart';
import 'highcharts/piechartformonth.dart';
import 'highcharts/piechartforweek.dart';
import 'highcharts/stock_column.dart';
import 'highcharts/weekchartforsummary.dart';

class Summayed extends StatefulWidget {


  @override

  State<Summayed> createState() => _SummayedState();
}

class _SummayedState extends State<Summayed> {
  final summaryController = Get.put(SummaryysControllers());
  int selectedIndex = 0;

  @override
  void initState() {
    summaryController. fetchFirstApiData();
    summaryController.fetchSecondApiData();
    summaryController.fetchData();
    summaryController.fetchDataformonth();

    super.initState();
    //  _fetchAllData();
  }
  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Sidedrawer(context: context),
      appBar: AppBar(
        title: Center(
          child: CustomText(
            texts: 'Summary',
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
    body: SingleChildScrollView(
      child: Column(
        children: [
          SwitchWidget(
            selectedIndex: selectedIndex,
            onToggle: (index) {
              setState(() {
                selectedIndex = index!;
              });
            },
          ),
          Visibility(
            visible: selectedIndex == 0,
            child: Column(
              children: [
      
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    children: [

                      Expanded(
                        flex: 1,
                        child: Container(
                          height: 130,
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
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    CustomText(
                                      texts: 'cost of usage',
                                      textColor: Color(0xff009f8d),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: Image.asset(
                                            'assets/images/moneylogo.png'),
                                      ),
                                    ),
                                  ],
                                ),
                                Obx(() {
                                  final firstApiData = summaryController.firstApiData!.value;
                                  if (firstApiData == null || firstApiData.isEmpty) {
                                    return CircularProgressIndicator();
                                  }else {
                                    if (firstApiData.containsKey("Main")) {
                                      return _buildUiForMainForPrice(firstApiData);
                                    } else {
                                      List<String> modifiedKeys =
                                      firstApiData.keys.map((key) => '$key\_[kW]').toList();
                                      return _buildUiForOtherForPrice(modifiedKeys);
                                    }
                                  }
                                }),
                                // Obx(() {
                                //   print(summaryController.lastMainKWValue);
                                //   return Text(
                                //     'Rs. ${(summaryController.lastMainKWValue * 70 / 1000).toStringAsFixed(2)}',
                                //     style: const TextStyle(
                                //       fontSize: 24,
                                //       fontWeight: FontWeight.w700,
                                //       height: 1.5,
                                //       color: Colors.white,
                                //     ),
                                //   );
                                // }),
                                CustomText(
                                  texts: 'per hour',
                                  textColor: Color(0xb2ffffff),
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
                          height: 130,
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
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    CustomText(
                                      texts: 'power',
                                      textColor: Color(0xff009f8d),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: Image.asset(
                                            'assets/images/Vector.png'),
                                      ),
                                    ),
                                  ],
                                ),
                                Obx(() {
                                  final firstApiData = summaryController.firstApiData!.value;
                                  if (firstApiData == null || firstApiData.isEmpty) {
                                    return CircularProgressIndicator();
                                  }else {
                                    if (firstApiData.containsKey("Main")) {
                                      return _buildUiForMain(firstApiData);
                                    } else {
                                      List<String> modifiedKeys =
                                      firstApiData.keys.map((key) => '$key\_[kW]').toList();
                                      return _buildUiForOther(modifiedKeys);
                                    }
                                  }
                                }),
                                CustomText(
                                  texts:
                                  'as of ${DateFormat('HH:mm').format(DateTime.now())}',
                                  textColor: Color(0xb2ffffff),
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
                  height: 40,
                ),
                Container(
                  height: 400,
                  child: Obx(() {
                    if (summaryController.loading.isTrue) {
                      // Show loading indicator
                      return Center(child: CircularProgressIndicator());
                    } else {
                      // Data has been loaded, show WeekChart
                      return WeekChartforsummary(
                        controllers: summaryController,
                      );
                    }
                  }),
                ),
                const SizedBox(
                  height: 50,
                ),
      PieChartforweek(controllers: summaryController)
                // Container(
                //   height: 400,
                //   child: Obx(() {
                //     if (summaryController.loading.isTrue) {
                //       // Show loading indicator
                //       return Center(child: CircularProgressIndicator());
                //     } else {
                //       // Data has been loaded, show WeekChart
                //       return
                //     }
                //   }),
                // ),
             //   PieChart(controllers: summaryControllersds),

      
      
              ],
            ),
          ),
          Visibility(
            visible: selectedIndex == 1,
            child: Column(
              children: [
                Container(
                  height: 400,
                  child: Obx(() {
                    if (summaryController.loading.isTrue) {
                      // Show loading indicator
                      return Center(child: CircularProgressIndicator());
                    } else {
                      // Data has been loaded, show WeekChart
                      return StockColumnformonth(
                        controllers: summaryController,
                      );
                    }
                  }),
                ),

                const SizedBox(
                  height: 30,
                ),
                Container(
                  height: 400,
                  child: Obx(() {
                    if (summaryController.loading.isTrue) {
                      // Show loading indicator
                      return Center(child: CircularProgressIndicator());
                    } else {
                      // Data has been loaded, show WeekChart
                      return PieChartFormonth(controllers: summaryController);
                    }
                  }),
                ),

              ],
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildUiForMainForPrice(Map<String, dynamic> firstApiResponse) {
    return Obx(() {
      final secondApiData = summaryController.secondApiData!.value;
      if (secondApiData == null || secondApiData.isEmpty) {
        return CircularProgressIndicator();
      } else {
        List<double> sumsList = [];
        for (int i = 0; i < secondApiData["Main_[kW]"].length; i++) {
          double sum = summaryController.parseDouble(secondApiData["Main_[kW]"][i]);
          sumsList.add(sum);
        }


        double lastindexvalue = summaryController.getLastIndexValue(sumsList);

        return Text("Rs ${summaryController.formatValued(lastindexvalue*70)}", style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          height: 1.5,
          color: Colors.white,
        ),);
      }
    });
  }
  Widget _buildUiForOtherForPrice(List<String> modifiedKeys) {
    return Obx(() {
      final secondApiData = summaryController.secondApiData!.value;
      if (secondApiData == null || secondApiData.isEmpty) {
        return CircularProgressIndicator();
      } else {
        List<double> sumsList = [];
        for (int i = 0; i < secondApiData['1st Floor_[kW]'].length; i++) {
          double sum =
              summaryController.parseDouble(secondApiData['1st Floor_[kW]'][i]) +
                  summaryController.parseDouble(secondApiData['Ground Floor_[kW]'][i]);
          sumsList.add(sum);
        }


        double lastindexvalue = summaryController.getLastIndexValue(sumsList);

        (summaryController.lastMainKWValue * 70 / 1000).toStringAsFixed(2);

        return Text("Rs. ${summaryController.formatValued(lastindexvalue*70)}", style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          height: 1.5,
          color: Colors.white,
        ),);
      }
    });
  }
  Widget _buildUiForMain(Map<String, dynamic> firstApiResponse) {
    return Obx(() {
      final secondApiData = summaryController.secondApiData!.value;
      if (secondApiData == null || secondApiData.isEmpty) {
        return CircularProgressIndicator();
      } else {
        List<double> sumsList = [];
        for (int i = 0; i < secondApiData["Main_[kW]"].length; i++) {
          double sum = summaryController.parseDouble(secondApiData["Main_[kW]"][i]);
          sumsList.add(sum);
        }


        double lastindexvalue = summaryController.getLastIndexValue(sumsList);

        return Text("${summaryController.formatValued(lastindexvalue)}kW", style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          height: 1.5,
          color: Colors.white,
        ),);
      }
    });
  }
  Widget _buildUiForOther(List<String> modifiedKeys) {
    return Obx(() {
      final secondApiData = summaryController.secondApiData!.value;
      if (secondApiData == null || secondApiData.isEmpty) {
        return CircularProgressIndicator();
      } else {
        List<double> sumsList = [];
        for (int i = 0; i < secondApiData['1st Floor_[kW]'].length; i++) {
          double sum =
              summaryController.parseDouble(secondApiData['1st Floor_[kW]'][i]) +
                  summaryController.parseDouble(secondApiData['Ground Floor_[kW]'][i]);
          sumsList.add(sum);
        }


        double lastindexvalue = summaryController.getLastIndexValue(sumsList);

        (summaryController.lastMainKWValue * 70 / 1000).toStringAsFixed(2);

        return Text("${summaryController.formatValued(lastindexvalue)}kW", style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          height: 1.5,
          color: Colors.white,
        ),);
      }
    });
  }
}
