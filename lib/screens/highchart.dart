import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
  import 'package:high_chart/high_chart.dart';

import 'package:http/http.dart' as http;

import '../controller/authcontroller/authcontroller.dart';

class StockColumn extends StatelessWidget {
  final RegisterViewController controllers;

  StockColumn({Key? key, required this.controllers}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      child: HighCharts(
        loader: const SizedBox(
          child: LinearProgressIndicator(),
          width: 200,
        ),
        size: const Size(400, 400),
        data: _getChartData(),
        scripts: const ["https://code.highcharts.com/highcharts.js"],
      ),
    );
  }

  String _getChartData() {
    List<Map<String, dynamic>> chartData = controllers.kwData;

    // Generate dynamic chart data based on the fetched data
    List<List<dynamic>> seriesData = [];
    Map<String, int> colorMap = {};

    for (var entry in chartData) {
      String date = entry['date'];
      List<Map<String, dynamic>> data = entry['data'];

      data.forEach((item) {
        String prefixName = item['prefixName'];
        List<double> values = item['values'];

        if (!colorMap.containsKey(prefixName)) {
          colorMap[prefixName] = colorMap.length;
        }

        for (int i = 0; i < values.length; i++) {
          seriesData.add([
            _getEpochMillis(date),
            values[i],
            colorMap[prefixName], // Color index for each appliance
          ]);
        }
      });
    }

    // Build series configuration for each appliance
    String seriesConfig = '';
    colorMap.forEach((prefixName, colorIndex) {
      seriesConfig += '''
      {
        type: 'column',
        name: '$prefixName',
        data: ${seriesData.where((data) => data[2] == colorIndex).map((data) => [data[0], data[1]]).toList()},
        color: Highcharts.getOptions().colors[$colorIndex],
      },
    ''';
    });

    return '''
    {
      accessibility: {
        enabled: false
      },
      chart: {
        alignTicks: false
      },
      rangeSelector: {
        selected: 1
      },
      title: {
        text: 'Stock Column'
      },
      xAxis: {
        type: 'datetime',
        dateTimeLabelFormats: {
          day: '%e %b',
        },
      },
      yAxis: {
        title: {
          text: 'Volume',
        },
      },
      series: [$seriesConfig]
    }
  ''';
  }


  // Convert date string to epoch milliseconds
  int _getEpochMillis(String date) {
    DateTime dateTime = DateTime.parse(date);
    return dateTime.millisecondsSinceEpoch;
  }
}


