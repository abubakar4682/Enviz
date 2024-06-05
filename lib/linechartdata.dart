import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import 'JS_Web_View/View/LineChart/line_chart.dart';
import 'controller/dailyanalysis/daily_analysis_controller.dart';


class LineChartForDailyAnalysis extends StatefulWidget {
  @override
  State<LineChartForDailyAnalysis> createState() => _LineChartForDailyAnalysisState();
}

class _LineChartForDailyAnalysisState extends State<LineChartForDailyAnalysis> {
  final DailyAnalysisController apiController = Get.put(DailyAnalysisController());

  @override
  void initState() {
    apiController.fetchFirstApiData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (apiController.firstApiResponse.value == null) {
        return Center(child: CircularProgressIndicator());
      } else if (apiController.firstApiResponse.value!.containsKey("Main")) {
        return _buildUiForMain();
      } else {
        List<String> modifiedKeys = apiController
            .firstApiResponse.value!.keys
            .map((key) => '$key\_[kW]')
            .toList();
        return _buildUiForOther(modifiedKeys);
      }
    });
  }

  Widget _buildUiForMain() {
    apiController.fetchSecondApiData(["Main_[kW]"]);

    return Obx(() {
      if (apiController.secondApiResponse.value == null) {
        return Center(child: CircularProgressIndicator());
      } else {
        List<double> alldailyvalues = [];
        Map<String, dynamic> mainApiData = apiController.secondApiResponse.value!;

        for (int i = 0; i < mainApiData["Main_[kW]"].length; i++) {
          double sum = apiController.parseDouble(mainApiData["Main_[kW]"][i]);
          alldailyvalues.add(sum);
        }

        return LineChartScreen(alldailyvalues: alldailyvalues);
      }
    });
  }

  Widget _buildUiForOther(List<String> modifiedKeys) {
    apiController.fetchSecondApiData(modifiedKeys);

    return Obx(() {
      if (apiController.secondApiResponse.value == null) {
        return Center(child: CircularProgressIndicator());
      } else {
        List<double> alldailyvalues = [];
        Map<String, dynamic> filteredData = apiController.secondApiResponse.value!;

        int minLength = modifiedKeys
            .where((key) => filteredData.containsKey(key))
            .map((key) => filteredData[key].length)
            .reduce((a, b) => a < b ? a : b);

        for (int i = 0; i < minLength; i++) {
          double sum = 0.0;
          for (String key in modifiedKeys) {
            if (filteredData.containsKey(key)) {
              sum += apiController.parseDouble(filteredData[key][i]);
            }
          }
          alldailyvalues.add(sum);
        }

        return LineChartScreen(alldailyvalues: alldailyvalues);
      }
    });
  }
}
