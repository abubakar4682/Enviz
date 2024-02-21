import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:high_chart/high_chart.dart';

import '../controller/datacontroller.dart';

class Livechart extends StatelessWidget {
  final DataControllers controllers;

  Livechart({Key? key, required this.controllers}) : super(key: key);

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
    // Extract the data from the DataControllers
    List<Map<String, dynamic>> kwData = controllers.kwData;

    // Generate dynamic chart data based on the fetched data
    List<List<dynamic>> seriesData = [];
    Map<String, int> colorMap = {};

    // Assume that kwData has only one entry for the latest date
    if (kwData.isNotEmpty) {
      Map<String, dynamic> latestData = kwData.last;
      String formattedDate = latestData['date'];
      List<Map<String, dynamic>> newData = latestData['data'];

      newData.forEach((item) {
        String itemName = item['prefixName'];
        List<double> numericValues = item['values'];

        // Assuming you want to use the last index value for each key
        double lastIndexValue = item['lastIndexValue'];

        if (!colorMap.containsKey(itemName)) {
          colorMap[itemName] = colorMap.length;
        }

        // Adjust the date to the Pakistani time zone
        DateTime dateTime = DateTime.parse(formattedDate);
        DateTime pakistaniDateTime = dateTime.toUtc().add(Duration(hours: 5));

        seriesData.add([
          _getEpochMillis(pakistaniDateTime), // Use the adjusted time
          lastIndexValue,
          colorMap[itemName], // Color index for each item
        ]);
      });
    }

    String seriesConfig = '';
    colorMap.forEach((itemName, colorIndex) {
      seriesConfig += '''
        {
          type: 'column',
          name: '$itemName',
          data: ${seriesData.where((data) => data[2] == colorIndex).map((data) => [
        data[0],
        data[1],

      ]).toList()},
          color: Highcharts.getOptions().colors[$colorIndex],
          pointWidth: 35,
          borderRadius: 5,
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
        legend: {
        enabled: false
    },
        title: {
          text: 'Live'
        },
          accessibility: {
        announceNewData: {
            enabled: true
        }
    },
    
      plotOptions: {
        series: {
          borderWidth: 0,
          dataLabels: {
            enabled: true,
            format: '{point.y:,.1f}k', // Use , to format as thousand separator and :,.1f to show one decimal place
          }
        }
      },
        xAxis: {
          type: 'datetime',
          dateTimeLabelFormats: {
            day: '%e %b',
          },
              labels: {
            autoRotation: [-45, -90],
            style: {
                fontSize: '13px',
                fontFamily: 'Verdana, sans-serif'
            }
        }
        },
        yAxis: {
        min: 0,
          allowDecimals: false,
          title: {
            text: 'Value',
          },
        },
         colorByPoint: true,
        groupPadding: 0,
         plotOptions: {
        series: {
            borderWidth: 0,
            dataLabels: {
                enabled: true,
                format: '{point.y:.1f}'
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
