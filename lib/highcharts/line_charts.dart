import 'package:flutter/material.dart';
import 'package:high_chart/high_chart.dart';

class LineChart extends StatelessWidget {
  final List<double> allValues;

  const LineChart({Key? key, required this.allValues}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String chartData = _generateChartData();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      child: HighCharts(
        // Adjusted the size here to make the loader smaller
        loader: Center(
          child: Text('Loading...'),
        ),
        size: const Size(400, 400),
        data: chartData,
        scripts: const [
          "https://code.highcharts.com/highcharts.js",
        ],
      ),
    );
  }

  String _generateChartData() {
    final StringBuffer data = StringBuffer();

    data.writeln("{");
    data.writeln("  title: {");
    data.writeln("    text: ''");
    data.writeln("  },");
    data.writeln("  yAxis: {");
    data.writeln("    title: {");
    data.writeln("      text: 'Power'");
    data.writeln("    }");
    data.writeln("  },");
    data.writeln("  tooltip: {");
    data.writeln("    pointFormatter: function() {");
    data.writeln("      var value = this.y / 1000;");
    data.writeln("      value = Highcharts.numberFormat(value, 1) + ' kWh';");
    data.writeln("      return 'Power: ' + value;");
    data.writeln("    }");
    data.writeln("  },");
    data.writeln("  xAxis: {");
    data.writeln("    categories: ['12 AM', '1 AM', '2 AM', '3 AM', '4 AM', '5 AM', '6 AM', '7 AM', '8 AM', '9 AM', '10 AM', '11 AM', '12 PM', '1 PM', '2 PM', '3 PM', '4 PM', '5 PM', '6 PM', '7 PM', '8 PM', '9 PM', '10 PM', '11 PM'],");
    data.writeln("  },");
    data.writeln("  series: [{");
    data.writeln("    name: 'Your Daily Usage',");
    data.write("    data: [");

    // Adding values from allValues list
    for (int i = 0; i < allValues.length; i++) {
      data.write("${allValues[i]}");
      if (i != allValues.length - 1) {
        data.write(", ");
      }
    }

    data.writeln("]");
    data.writeln("  }]");
    data.writeln("}");

    return data.toString();
  }
}
