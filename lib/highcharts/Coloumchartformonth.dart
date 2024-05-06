
import 'package:flutter/material.dart';

import 'package:high_chart/high_chart.dart';

import '../controller/Summary_Controller/max_avg_min_controller.dart';


class StockColumnformonth extends StatelessWidget {
  final MinMaxAvgValueControllers controllers;

  StockColumnformonth({Key? key, required this.controllers}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      child: HighCharts(
        loader: const Center(
          child: SizedBox(
            child: Text('loading'),
            width: 2,
          ),
        ),
        size: const Size(400, 400),
        data: _getChartData(),
        scripts: const ["https://code.highcharts.com/highcharts.js"],
      ),
    );
  }

  String _getChartData() {
    // Extract the data from the DataControllers
    Map<String, Map<String, double>> dailyItemSumsMap =
        controllers.dailyItemSumsMapforMonth;

    // Generate dynamic chart data based on the fetched data
    List<List<dynamic>> seriesData = [];
    Map<String, int> colorMap = {};

    dailyItemSumsMap.forEach((date, itemSums) {
      String formattedDate = date;
      itemSums.forEach((itemName, sum) {
        if (!colorMap.containsKey(itemName)) {
          colorMap[itemName] = colorMap.length;
        }

        // Adjust the date to the Pakistani time zone
        DateTime dateTime = DateTime.parse(date);
        DateTime pakistaniDateTime = dateTime.toUtc().add(const Duration(hours: 5));

        // Convert sum to kilowatts
        double sumInKW = sum / 1000;

        seriesData.add([
          _getEpochMillis(pakistaniDateTime), // Use the adjusted time
          sumInKW, // Use the converted value in kilowatts
          colorMap[itemName], // Color index for each item
        ]);
      });
    });

    String seriesConfig = '';
    colorMap.forEach((itemName, colorIndex) {
      // Remove underscores from the item name
      String cleanItemName = itemName.replaceAll('_', ' ');
      bool isVisible = itemName != 'Main_' && itemName != 'Generator_';

      seriesConfig += '''
    {
      type: 'column',
      name: '$cleanItemName', // Use the cleaned item name
      data: ${seriesData.where((data) => data[2] == colorIndex).map((data) => [
        data[0],
        data[1],
      ]).toList()},
      color: Highcharts.getOptions().colors[$colorIndex],
      pointWidth: 10,
      borderRadius: 5,
          visible: $isVisible, 
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
    title: {
      text: 'Monthly Breakdown'
    },
    
    xAxis: {
      type: 'datetime',
      dateTimeLabelFormats: {
        day: '%e %b',
      },
    },
    yAxis: {
      allowDecimals: false,
      title: {
        text: 'Energy (kWh)',
      },
    },
    plotOptions: {
      column: {
        stacking: 'normal',
        tooltip: {
          pointFormat: '<span style="color:{point.color}">\u25CF</span> {series.name}: <b>{point.y:.2f} kWh</b><br/>'
        }
      }
    },
    series: [$seriesConfig],
  }
''';
  }



  void _onColumnClick(Map<String, dynamic> event) {
    // Handle the click event, you can access the clicked data using event['point']
    Map<String, dynamic> point = event['point'];
    double xValue = point['x'];
    double yValue = point['y'];

    print('Clicked on column at date: $xValue, value: $yValue');
  }

  int _getEpochMillis(DateTime dateTime) {
    return dateTime.millisecondsSinceEpoch;
  }
}


