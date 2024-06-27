import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/dailyanalysis/daily_analysis_controller.dart';
import '../../highcharts/Daily_Analysis/line_chart_build.dart';

class LineChartForDailyAnalysis extends StatefulWidget {
  @override
  State<LineChartForDailyAnalysis> createState() => _LineChartForDailyAnalysisState();
}

class _LineChartForDailyAnalysisState extends State<LineChartForDailyAnalysis> {
  final DailyAnalysisController apiController = Get.put(DailyAnalysisController());

  @override
  void initState() {
    super.initState();
    apiController.fetchFirstApiData(); // Fetch initial data on state initialization
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Display loading indicator while fetching data
      if (apiController.firstApiResponse.value == null) {
        return const Center(child: CircularProgressIndicator());
      }

      // Display UI based on the response data
      if (apiController.firstApiResponse.value!.containsKey("Main")) {
        return _buildUiForMain();
      } else {
        List<String> modifiedKeys = _getModifiedKeys(apiController.firstApiResponse.value!.keys);
        return _buildUiForOther(modifiedKeys);
      }
    });
  }

  // Build UI for "Main" data
  Widget _buildUiForMain() {
    apiController.fetchSecondApiData(["Main_[kW]"]); // Fetch second API data for main key

    return Obx(() {
      if (apiController.secondApiResponse.value == null) {
        return const Center(child: CircularProgressIndicator());
      } else {
        List<double> allDailyValues = _getDailyValues(apiController.secondApiResponse.value!, "Main_[kW]");
        return LineChartScreen( alldailyvalues: allDailyValues);
      }
    });
  }

  // Build UI for other data keys
  Widget _buildUiForOther(List<String> modifiedKeys) {
    apiController.fetchSecondApiData(modifiedKeys); // Fetch second API data for other keys

    return Obx(() {
      if (apiController.secondApiResponse.value == null) {
        return const Center(child: CircularProgressIndicator());
      } else {
        List<double> allDailyValues = _getSummedDailyValues(apiController.secondApiResponse.value!, modifiedKeys);
        return LineChartScreen( alldailyvalues: allDailyValues,);
      }
    });
  }

  // Helper function to get modified keys with '_[kW]' suffix
  List<String> _getModifiedKeys(Iterable<String> keys) {
    return keys.map((key) => '$key\_[kW]').toList();
  }

  // Helper function to extract daily values for a specific key
  List<double> _getDailyValues(Map<String, dynamic> data, String key) {
    List<double> dailyValues = [];
    for (var value in data[key]) {
      dailyValues.add(apiController.parseDouble(value));
    }
    return dailyValues;
  }

  // Helper function to sum daily values across multiple keys
  List<double> _getSummedDailyValues(Map<String, dynamic> data, List<String> keys) {
    List<double> dailyValues = [];
    int minLength = _getMinLength(data, keys);

    for (int i = 0; i < minLength; i++) {
      double sum = 0.0;
      for (String key in keys) {
        if (data.containsKey(key)) {
          sum += apiController.parseDouble(data[key][i]);
        }
      }
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
