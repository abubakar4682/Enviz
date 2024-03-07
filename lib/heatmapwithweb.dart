import 'package:flutter/material.dart';
import 'package:high_chart/high_chart.dart';

class HeatmapChartExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String heatmapChartData = '''
      {
        chart: {
          type: 'heatmap',
          marginTop: 40,
          marginBottom: 80,
          plotBorderWidth: 1
        },
        title: {
            text: 'Activity heatmap'
        },
        xAxis: {
            categories: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'],
        },
        yAxis: {
            categories: ['12 AM', '1 AM', '2 AM', '3 AM', '4 AM', '5 AM', '6 AM', '7 AM', '8 AM', '9 AM', '10 AM', '11 AM', '12 PM', '1 PM', '2 PM', '3 PM', '4 PM', '5 PM', '6 PM', '7 PM', '8 PM', '9 PM', '10 PM', '11 PM'],
            title: null,
            reversed: true
        },
        colorAxis: {
            min: 0,
            minColor: '#FFFFFF',
            maxColor: '#0066FF'
        },
        legend: {
            align: 'right',
            layout: 'vertical',
            margin: 0,
            verticalAlign: 'top',
            y: 25,
            symbolHeight: 280
        },
        tooltip: {
            formatter: function () {
                return '<b>' + this.series.xAxis.categories[this.point.x] + '</b> <br><b>' +
                    this.point.value + '</b> units at <b>' + this.series.yAxis.categories[this.point.y] + '</b>';
            }
        },
        series: [{
            name: 'Activity Level',
            borderWidth: 1,
            data: [[0, 0, 10], [1, 1, 19], [2, 2, 8], [3, 3, 24], [4, 4, 67], [5, 5, 92], [6, 6, 58], [0, 7, 78], [1, 8, 117], [2, 9, 48], [3, 10, 125], [4, 11, 74], [5, 12, 123], [6, 13, 87], [0, 14, 55], [1, 15, 56], [2, 16, 3]],
            dataLabels: {
                enabled: true,
                color: '#000000'
            }
        }]
      }
    ''';

    return Scaffold(
      appBar: AppBar(
        title: Text('HighCharts Heatmap Example'),
      ),
      body: Container(
        child: HighCharts(
          data: heatmapChartData,
          scripts: const [
            "https://code.highcharts.com/highcharts.js",
            "https://code.highcharts.com/modules/heatmap.js",
            "https://code.highcharts.com/modules/exporting.js",
          ],         size: const Size(400, 400),
        ),
      ),
    );
  }
}


