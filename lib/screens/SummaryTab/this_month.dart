
import 'package:get/get.dart';

import 'package:flutter/material.dart';
import '../../controller/Summary_Page_Controller/Data_for_this_month_controller.dart';
import '../../highcharts/Summary_Tab_Charts/This_Month_Chart/coloum_chart_for_this_month.dart';
import '../../highcharts/Summary_Tab_Charts/This_Month_Chart/pie_chart_this_month.dart';

class DataViewForThisMonth extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final DataControllerForThisMonth controller =
        Get.put(DataControllerForThisMonth());

    return Column(
      children: [
        SizedBox(height: 400, child: ColumnChartSreenForMonth()),
        SizedBox(
          height: 400,
          child: PieChartScreenForMonth(),
        ),
      ],
    );
  }
}
