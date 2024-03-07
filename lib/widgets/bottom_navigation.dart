import 'package:flutter/material.dart';

import '../screens/Historical.dart';

import '../screens/Live.dart';
import '../screens/dailyanalysi.dart';

import '../screens/summary.dart';

import '../today.dart';

class BottomPage extends StatefulWidget {
  BottomPage({Key? key}) : super(key: key);

  @override
  State<BottomPage> createState() => _BottomPageState();
}

class _BottomPageState extends State<BottomPage> {
  int currentIndex = 0;
  List<Widget> pages = [
    const Summary(),
    const LiveDataScreen(),
    const Historical(),
    Dailyanalusic(),
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
        color: currentIndex == index ? Colors.blue : Colors.grey,
      ),
      backgroundColor:
          currentIndex == index ? Colors.lightBlueAccent : Colors.white,
    );
  }
}
