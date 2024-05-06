import 'package:flutter/cupertino.dart';
import 'package:high_chart/high_chart.dart';

import '../controller/Summary_Controller/max_avg_min_controller.dart';




class PieChartFormonth extends StatelessWidget {
  final MinMaxAvgValueControllers controllers;

  PieChartFormonth({Key? key, required this.controllers}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      child: Column(
        children: [
          SizedBox(height: 10),
          HighCharts(
            loader: const SizedBox(
              child: Text('Loading'),
            ),
            size: const Size(400, 400),
            data: _getPieChartData(),
            scripts: const ["https://code.highcharts.com/highcharts.js"],
          ),
        ],
      ),
    );
  }
  String _getPieChartData() {
    List<Map<String, dynamic>> chartData = controllers.kwData;

    if (chartData.isEmpty) {
      return '''
    {
      chart: {
        type: 'pie',
        height: 400,
      },
      title: {
        text: 'No Data Available'
      },
      series: []
    }
  ''';
    }

    Map<String, double> pieChartData = {};

    for (var entry in chartData) {
      if (entry.containsKey('data')) {
        List<Map<String, dynamic>> data = entry['data'];

        if (data.isNotEmpty) {
          data.forEach((item) {
            if (item.containsKey('prefixName') && item.containsKey('values')) {
              String prefixName = item['prefixName'];
              List<double> values = item['values'];

              if (values.isNotEmpty) {
                double sum = values.reduce((value, element) => value + element);

                if (prefixName != 'Main_') {
                  pieChartData.update(prefixName, (value) => value + sum, ifAbsent: () => sum);
                }
              }
            }
          });
        }
      }
    }

    if (pieChartData.isEmpty) {
      return '''
    {
      chart: {
        type: 'pie',
        height: 400,
      },
      title: {
        text: 'No Data Available'
      },
      tooltip: {
        valueSuffix: '%'
      },
      series: []
    }
  ''';
    }

    String seriesConfig = '''
  {
    name: 'Percentage',
    colorByPoint: true,
    data: [
''';

    pieChartData.forEach((name, value) {
      // Convert value to kilowatts
      double valueInKW = value / 1000;

      seriesConfig += '''
    {
      name: '$name',
      y: $valueInKW
    },
  ''';
    });

    seriesConfig += '''
    ]
  }
''';

    // Remove underscores from the legend names
    seriesConfig = seriesConfig.replaceAll('_', ' ');

    return '''
  {
    chart: {
      type: 'pie',
      height: 400,
    },
    title: {
      text: 'Appliance Share'
    },
    tooltip: {
      formatter: function () {
        return '<b>' + this.point.name + '</b>: ' + this.y.toFixed(2) + ' kWh'; // Display values in kilowatts with two decimal places
      }
    },
    plotOptions: {
      pie: {
        allowPointSelect: true,
        cursor: 'pointer',
        dataLabels: {
          enabled: true,
          distance: 10,
          format: '{point.percentage:.1f}%',
        },
        showInLegend: true
      }
    },
    series: [$seriesConfig]
  }
''';
  }

}




