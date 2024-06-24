import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:highcharts_demo/screens/SummaryTab/this_month.dart';
import 'package:highcharts_demo/screens/SummaryTab/weekly_charts.dart';
import 'package:highcharts_demo/widgets/custom_text.dart';
import 'package:highcharts_demo/widgets/side_drawer.dart';
import 'package:highcharts_demo/widgets/switch_button.dart';
import 'package:intl/intl.dart';

import '../../controller/Summary_Page_Controller/max_avg_min_controller.dart';


class SummaryTab extends StatefulWidget {
  @override
  State<SummaryTab> createState() => _SummaryTabState();
}

class _SummaryTabState extends State<SummaryTab> {
  final summaryController = Get.put(MinMaxAvgValueController());
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    summaryController.fetchData(); // Fetch data when the widget is initialized
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
            if (selectedIndex == 0) _buildCurrentTab(),
            if (selectedIndex == 1) _buildThisMonthTab(),
          ],
        ),
      ),
    );
  }

  // Build the UI for the current tab (Summary)
  Widget _buildCurrentTab() {
    return Column(
      children: [
        _buildSummaryCards(),
        const SizedBox(height: 40),
        SizedBox(
          height: MediaQuery.of(context).size.height,
          child: WeeklyCharts(),
        ),
      ],
    );
  }

  // Build the summary cards
  Widget _buildSummaryCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Expanded(child: _buildCostOfUsageCard()),
          const SizedBox(width: 10),
          Expanded(child: _buildPowerCard()),
        ],
      ),
    );
  }

  // Build the cost of usage card
  Widget _buildCostOfUsageCard() {
    return Container(
      height: 130,
      decoration: BoxDecoration(
        color: Color(0xff002f46),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardHeader('cost of usage', 'assets/images/moneylogo.png'),
            Obx(() {
              final firstApiData = summaryController.firstApiData?.value;
              if (firstApiData == null || firstApiData.isEmpty) {
                return const CircularProgressIndicator();
              }
              if (firstApiData.containsKey("Main")) {
                return _buildUiForMainForPrice(firstApiData);
              } else {
                List<String> modifiedKeys = _getModifiedKeys(firstApiData.keys);
                return _buildUiForOtherForPrice(modifiedKeys);
              }
            }),
            CustomText(
              texts: 'per hour',
              textColor: const Color(0xb2ffffff),
            ),
          ],
        ),
      ),
    );
  }

  // Build the power card
  Widget _buildPowerCard() {
    return Container(
      height: 130,
      decoration: BoxDecoration(
        color: const Color(0xff002f46),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardHeader('power', 'assets/images/Vector.png'),
            Obx(() {
              final firstApiData = summaryController.firstApiData?.value;
              if (firstApiData == null || firstApiData.isEmpty) {
                return const CircularProgressIndicator();
              }
              if (firstApiData.containsKey("Main")) {
                return _buildUiForMain(firstApiData);
              } else {
                List<String> modifiedKeys = _getModifiedKeys(firstApiData.keys);
                return _buildUiForOther(modifiedKeys);
              }
            }),
            CustomText(
              texts: 'as of ${DateFormat('HH:mm').format(DateTime.now())}',
              textColor: const Color(0xb2ffffff),
            ),
          ],
        ),
      ),
    );
  }

  // Build card header with title and icon
  Widget _buildCardHeader(String title, String iconPath) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomText(
          texts: title,
          textColor: const Color(0xff009f8d),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: 20,
            height: 20,
            child: Image.asset(iconPath),
          ),
        ),
      ],
    );
  }

  // Build the UI for main data for price
  Widget _buildUiForMainForPrice(Map<String, dynamic> firstApiResponse) {
    return Obx(() {
      final secondApiData = summaryController.secondApiData?.value;
      if (secondApiData == null || secondApiData.isEmpty) {
        return const CircularProgressIndicator();
      }
      List<double> sumsList = _getSumsList(secondApiData["Main_[kW]"]);
      double lastIndexValue = summaryController.getCurrentHourValue(sumsList);
      return Text(
        "Rs ${summaryController.formatValue(lastIndexValue * 70)}",
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          height: 1.5,
          color: Colors.white,
        ),
      );
    });
  }

  // Build the UI for main data
  Widget _buildUiForMain(Map<String, dynamic> firstApiResponse) {
    return Obx(() {
      final secondApiData = summaryController.secondApiData?.value;
      if (secondApiData == null || secondApiData.isEmpty) {
        return const CircularProgressIndicator();
      }
      List<double> sumsList = _getSumsList(secondApiData["Main_[kW]"]);
      double lastIndexValue = summaryController.getCurrentHourValue(sumsList);
      return Text(
        "${summaryController.formatValue(lastIndexValue)}kW",
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          height: 1.5,
          color: Colors.white,
        ),
      );
    });
  }

  // Build the UI for other data
  Widget _buildUiForOther(List<String> keys) {
    return Obx(() {
      final secondApiData = summaryController.secondApiData?.value;
      if (secondApiData == null || secondApiData.isEmpty) {
        return const CircularProgressIndicator();
      }
      List<double> sumsList = _getSummedDailyValues(secondApiData, keys);
      double lastIndexValue = summaryController.getCurrentHourValue(sumsList);
      return Text(
        "${summaryController.formatValue(lastIndexValue)}kW",
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      );
    });
  }

  // Build the UI for other data for price
  Widget _buildUiForOtherForPrice(List<String> keys) {
    return Obx(() {
      final secondApiData = summaryController.secondApiData?.value;
      if (secondApiData == null || secondApiData.isEmpty) {
        return const CircularProgressIndicator();
      }
      List<double> sumsList = _getSummedDailyValues(secondApiData, keys);
      double lastIndexValue = summaryController.getCurrentHourValue(sumsList);
      return Text(
        "Rs ${summaryController.formatValue(lastIndexValue * 70)}",
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          height: 1.5,
          color: Colors.white,
        ),
      );
    });
  }

  // Build the UI for "This Month" tab
  Widget _buildThisMonthTab() {
    return Column(
      children: [DataViewForThisMonth()],
    );
  }

  // Helper function to get modified keys with '_[kW]' suffix
  List<String> _getModifiedKeys(Iterable<String> keys) {
    return keys.map((key) => '$key\_[kW]').toList();
  }

  // Helper function to get sums list from API data
  List<double> _getSumsList(List<dynamic> apiData) {
    return apiData.map((data) => summaryController.parseDouble(data)).toList();
  }

  // Helper function to sum daily values across multiple keys
  List<double> _getSummedDailyValues(Map<String, dynamic> data, List<String> keys) {
    List<double> dailyValues = [];
    int minLength = _getMinLength(data, keys);

    for (int i = 0; i < minLength; i++) {
      double sum = keys
          .where((key) => data.containsKey(key))
          .map((key) => summaryController.parseDouble(data[key][i]))
          .reduce((a, b) => a + b);
      dailyValues.add(sum);
    }
    return dailyValues;
  }

  // Helper function to get the minimum length among the keys
  int _getMinLength(Map<String, dynamic> data, List<String> keys) {
    return keys
        .where((key) => data.containsKey(key))
        .map((key) => data[key].length)
        .reduce((a, b) => a < b ? a : b);
  }
}
