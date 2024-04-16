
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:highcharts_demo/screens/SummaryTab/this_month.dart';
import 'package:highcharts_demo/screens/SummaryTab/this_week.dart';


import 'package:highcharts_demo/widgets/CustomText.dart';
import 'package:highcharts_demo/widgets/SideDrawer.dart';
import 'package:highcharts_demo/widgets/switch_button.dart';
import 'package:intl/intl.dart';

import '../../controller/Summary_Controller/max_avg_min_controller.dart';





class SummaryTab extends StatefulWidget {


  @override

  State<SummaryTab> createState() => _SummaryTabState();
}

class _SummaryTabState extends State<SummaryTab> {
  final summaryController = Get.put(MinMaxAvgValueControllers());
  int selectedIndex = 0;

  @override
  void initState() {
    summaryController. fetchFirstApiData();
    summaryController.fetchSecondApiData();


    super.initState();

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
            texts: 'SummaryTab',
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
                                  CustomText(
                                    texts: 'per hour',
                                    textColor: const Color(0xb2ffffff),
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
                              color: const Color(0xff002f46),
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
                                        return _buildUiForOther();
                                      }
                                    }
                                  }),
                                  CustomText(
                                    texts:
                                    'as of ${DateFormat('HH:mm').format(DateTime.now())}',
                                    textColor: const Color(0xb2ffffff),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),


                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Container(
                      height: MediaQuery.of(context).size.height,
                      child: DataView()
                  ),





                ],
              ),
            ),
            Visibility(
              visible: selectedIndex == 1,
              child: Column(
                children: [
                  DataViewForThisMonth()

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
        // for (int i = 0; i < secondApiData['1st Floor_[kW]'].length; i++) {
        //   double sum =
        //       summaryController.parseDouble(secondApiData['1st Floor_[kW]'][i]) +
        //           summaryController.parseDouble(secondApiData['Ground Floor_[kW]'][i]);
        //   sumsList.add(sum);
        // }
        if (summaryController.result.isNotEmpty) {
          int lengthOfData = secondApiData[summaryController.result.first].length;
          for (int i = 0; i < lengthOfData; i++) {
            double sum = 0;
            for (String key in summaryController.result) {
              sum += summaryController.parseDouble(secondApiData[key][i]);
            }
            sumsList.add(sum);
          }
        }


        double lastindexvalue = summaryController.getLastIndexValue(sumsList);

        (summaryController.lastMainKWValue * 70 / 1000).toStringAsFixed(2);

        return Text("Rs ${summaryController.formatValued(lastindexvalue*70)}", style: const TextStyle(
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
  // Widget _buildUiForOther(List<String> modifiedKeys) {
  //   return Obx(() {
  //     final secondApiData = summaryController.secondApiData!.value;
  //     if (secondApiData == null || secondApiData.isEmpty) {
  //       return CircularProgressIndicator();
  //     } else {
  //       List<double> sumsList = [];
  //       for (int i = 0; i < secondApiData['1st Floor_[kW]'].length; i++) {
  //         double sum =
  //             summaryController.parseDouble(secondApiData['1st Floor_[kW]'][i]) +
  //                 summaryController.parseDouble(secondApiData['Ground Floor_[kW]'][i]);
  //         sumsList.add(sum);
  //       }
  //
  //
  //       double lastindexvalue = summaryController.getLastIndexValue(sumsList);
  //
  //       (summaryController.lastMainKWValue * 70 / 1000).toStringAsFixed(2);
  //
  //       return Text("${summaryController.formatValued(lastindexvalue)}kW", style: const TextStyle(
  //         fontSize: 24,
  //         fontWeight: FontWeight.w700,
  //         height: 1.5,
  //         color: Colors.white,
  //       ),);
  //     }
  //   });
  // }
  Widget _buildUiForOther() {
    return Obx(() {
      final secondApiData = summaryController.secondApiData!.value;
      if (secondApiData == null || secondApiData.isEmpty) {
        return CircularProgressIndicator();
      } else {
        List<double> sumsList = [];
        // Use dynamically captured keys
        if (summaryController.result.isNotEmpty) {
          int lengthOfData = secondApiData[summaryController.result.first].length;
          for (int i = 0; i < lengthOfData; i++) {
            double sum = 0;
            for (String key in summaryController.result) {
              sum += summaryController.parseDouble(secondApiData[key][i]);
            }
            sumsList.add(sum);
          }
        }

        double lastindexvalue = summaryController.getLastIndexValue(sumsList);

        // Assuming getLastIndexValue and formatValued are methods that you have defined in your controller
        return Text("${summaryController.formatValued(lastindexvalue)}kW", style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          height: 1.5,
          color: Colors.white,
        ));
      }
    });
  }

}
