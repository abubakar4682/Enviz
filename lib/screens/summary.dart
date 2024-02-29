import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';

import '../controller/datacontroller.dart';
import '../highcharts/WeekChart.dart';
import '../highcharts/stock_column.dart';
import '../pichart.dart';
import '../sevenday.dart';
import '../today.dart';
import '../widgets/CustomText.dart';
import '../widgets/SideDrawer.dart';
import '../widgets/switch_button.dart';

class Summary extends StatefulWidget {
  const Summary({Key? key}) : super(key: key);

  @override
  State<Summary> createState() => _SummaryState();
}

class _SummaryState extends State<Summary> {
  final summaryController = Get.put(DataControllers());

  late Timer _fetchDataTimer;

  @override
  void initState() {
    _fetchDataTimer = Timer.periodic(Duration(minutes: 1), (timer) {
      print('Timer callback abubakar');
      _fetchAllData();
    });
    super.initState();
    //  _fetchAllData();
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    _fetchDataTimer.cancel();
    super.dispose();
  }

  Future<void> _fetchAllData() async {
    try {
      summaryController.kwData.clear(); // Clear existing data

      await summaryController.fetchData(); // Fetch 7-day data

      if (selectedIndex == 1) {
        // Fetch month data only if the selected index is 1
        await summaryController.fetchDataformonth();
      }

      summaryController.update();
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Display a loading indicator or placeholder UI
            return Center(child:CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Display an error message
            return Text('Error loading data: ${snapshot.error}');
          } else {
            return _buildUI();
          }
        },
        future: _fetchAllData(),
      ),
    );
  }

  Widget _buildUI() {
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
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: Image.asset(
                                            'assets/images/Vector.png'),
                                      ),
                                    ],
                                  ),
                                  Obx(() {
                                    print(summaryController.lastMainKWValue);
                                    return Text(
                                      'Rs. ${(summaryController.lastMainKWValue * 70 / 1000).toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                        height: 1.5,
                                        color: Colors.white,
                                      ),
                                    );
                                  }),
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
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: Image.asset(
                                            'assets/images/Vector.png'),
                                      ),
                                    ],
                                  ),
                                  Obx(() {
                                    return Text(
                                      '${(summaryController.lastMainKWValue / 1000).toStringAsFixed(2)} KW',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                        height: 1.5,
                                        color: Colors.white,
                                      ),
                                    );
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
                  Container(
                      height: 400,

                      child: WeekChart(
                        controllers: summaryController,
                      )),
                  // LiveChart(myController: summaryController,),
                  const SizedBox(
                    height: 50,
                  ),
                  PieChart(controllers: summaryController),
                ],
              ),
            ),
            Visibility(
              visible: selectedIndex == 1,
              child: Column(
                children: [
                  Container(
                      height: 400,
                      child: StockColumn(
                        controllers: summaryController,
                      )),
                  const SizedBox(
                    height: 30,
                  ),
                  PieChart(controllers: summaryController),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
