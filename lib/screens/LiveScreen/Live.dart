import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:highcharts_demo/widgets/custom_text.dart';
import 'package:highcharts_demo/widgets/side_drawer.dart';
import '../../highcharts/Live_Screen_Charts/coloum_chart_for_live.dart';
import '../../highcharts/Live_Screen_Charts/pie_chart_for_live.dart';
import '../../controller/Live/live_controller.dart';

class LiveDataScreen extends StatefulWidget {
  const LiveDataScreen({Key? key}) : super(key: key);

  @override
  State<LiveDataScreen> createState() => _LiveDataScreenState();
}

class _LiveDataScreenState extends State<LiveDataScreen> {
  final LiveDataControllers _controller = Get.put(LiveDataControllers());
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _controller.fetchDataforlives();
    _timer = Timer.periodic(const Duration(minutes: 1), (Timer timer) {
      _controller.fetchDataforlives();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Sidedrawer(context: context),
      appBar: AppBar(
        title: Center(
          child: CustomText(
            texts: 'Live',
            textColor: const Color(0xff002F46),
          ),
        ),
        actions: [
          SizedBox(
            width: 40,
            height: 30,
            child: Image.asset('assets/images/Vector.png'),
          ),
        ],
      ),
      body: Obx(() {
        if (_controller.kwData.isEmpty) {
          return Center(
            child: Text(_controller.isOnline.value ? "Loading..." : "Displaying offline data"),
          );
        } else {
          return ListView(
            children: [
              ColumnChartForLive(data: _controller.kwData),
              const SizedBox(height: 40),
              PieChartForLive(data: _controller.kwData),
            ],
          );
        }
      }),
    );
  }
}
