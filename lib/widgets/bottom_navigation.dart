import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../controller/historical/historical_controller.dart';
import '../screens/HistoricalTab/historical.dart';

import '../screens/LiveScreen/Live.dart';
import '../screens/SummaryTab/summary_full_screen.dart';
import '../screens/Daily_Analysis/daily_analysi.dart';



class BottomPage extends StatefulWidget {
  BottomPage({Key? key}) : super(key: key);

  @override
  State<BottomPage> createState() => _BottomPageState();
}

class _BottomPageState extends State<BottomPage> {
  //final controller = Get.put(HistoricalController());
  @override
  void initState() {
   // controller.updateDateRange();
   //  controller.fetchDataForAreaChart();
   //  controller.fetchDataForHeatmap();
    // TODO: implement initState
    super.initState();
  }

  int currentIndex = 0;
  List<Widget> pages = [
    SummaryTab(),
     const LiveDataScreen(),
    const Historical(),
    DailyAnalysis(),
  ];

  onTapped(int index) {
      setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: onTapped,
        items: [
          _buildNavigationBarItem('Summary', 'assets/images/Overview.png', 0),
          _buildNavigationBarItem('Live', 'assets/images/Historical.png', 1),
          _buildNavigationBarItem(
              'Historical', 'assets/images/Last 24 Hours.png', 2),
          _buildNavigationBarItem(
              'Daily Analysis', 'assets/images/RFID Signal.png', 3),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildNavigationBarItem(
      String label, String imagePath, int index) {
    return BottomNavigationBarItem(
      label: label,
      icon: Image.asset(
        imagePath,
        width: 30,
        height: 30,
        color: currentIndex == index ? Color(0xff009F8D) : Colors.grey,
      ),
      backgroundColor:
          currentIndex == index ? Colors.lightBlueAccent : Colors.white,
    );
  }
}
