import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:high_chart/high_chart.dart';
import '../controller/Summary_Controller/max_avg_min_controller.dart';
import '../controller/datacontroller.dart';
import '../controller/summaryedController.dart';
class WeekChartforsummary extends StatelessWidget {
  final MinMaxAvgValueControllers controllers;
  WeekChartforsummary({Key? key, required this.controllers}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      child: HighCharts(
        loader:Text('Loading...'),
        size: const Size(400, 400),
        data: _getChartData(),
        scripts: const ["https://code.highcharts.com/highcharts.js"],
      ),
    );
  }
  String _getChartData() {
    // Extracting data from the DataControllers
    Map<String, Map<String, double>> dailyItemSumsMap = controllers.dailyItemSumsMap;
    // Generating dynamic chart data based on fetched data
    List<List<dynamic>> seriesData = [];
    Map<String, int> colorMap = {};
    dailyItemSumsMap.forEach((date, itemSums) {
      String formattedDate = date;
      itemSums.forEach((itemName, sum) {
        if (!colorMap.containsKey(itemName)) {
          colorMap[itemName] = colorMap.length;
        }
        // Adjusting date to Pakistani time zone
        DateTime dateTime = DateTime.parse(date);
        DateTime pakistaniDateTime = dateTime.toUtc().add(Duration(hours: 5));
        // Converting sum to kilowatts
        double sumInKW = sum / 1000;

        seriesData.add([
          _getEpochMillis(pakistaniDateTime), // Using adjusted time
          sumInKW, // Using converted value in kilowatts
          colorMap[itemName], // Color index for each item
        ]);
      });
    });

    String seriesConfig = '';
    colorMap.forEach((itemName, colorIndex) {
      // Removing underscores from the item name
      String cleanItemName = itemName.replaceAll('_', ' ');

      // Setting visibility to false for "Main" and "Generator" by default
      bool isVisible = itemName != 'Main_' && itemName != 'Generator_';

      seriesConfig += '''
  {
    type: 'column',
    name: '$cleanItemName', // Using cleaned item name
    data: ${seriesData.where((data) => data[2] == colorIndex).map((data) => [
        data[0],
        data[1],
      ]).toList()},
    color: Highcharts.getOptions().colors[$colorIndex],
    pointWidth: 25,
    borderRadius: 5,
    visible: $isVisible, // Setting visibility
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
    text: 'Daily Breakdown'
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
  series: [$seriesConfig], // Configuring series data
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