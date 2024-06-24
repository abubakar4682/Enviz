import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import 'package:flutter/material.dart';



import '../../controller/Summary_Page_Controller/Week_Data_Chart_Controller.dart';
import '../../highcharts/Summary_Tab_Charts/This_Week_Charts/coloum_chart_for_this_week.dart';
import '../../highcharts/Summary_Tab_Charts/This_Week_Charts/pie_chart_for_this_week.dart';

class WeeklyCharts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        SizedBox(height: 400, child: ColumnChartScreenForThisWeek()),
        SizedBox(height: 400, child: PieChartForThisWeek()),
      ],
    );
  }
}
