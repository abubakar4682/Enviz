import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../controller/datacontroller.dart';
import '../pichart.dart';

class SwitchWidget extends StatelessWidget {
  const SwitchWidget({
    Key? key,
    required this.selectedIndex,
    required this.onToggle,
  }) : super(key: key);

  final int selectedIndex;
  final Function(int?)? onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Column(
          children: [
            ToggleSwitch(
              minHeight: 30.0,
              minWidth: MediaQuery.of(context).size.width,
              initialLabelIndex: selectedIndex,
              totalSwitches: 2,
              activeFgColor: Colors.white,
              inactiveBgColor: Colors.white,
              inactiveFgColor: Colors.grey[900],
              labels: ['Today', 'This Month'],
              onToggle: onToggle,
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}



class LastMonthWidget extends StatelessWidget {
  final summaryController = Get.put(DataControllers());
  @override
  Widget build(BuildContext context) {
    // Placeholder for Last Month Widget UI
    return  PieChart(controllers: summaryController);
  }
}