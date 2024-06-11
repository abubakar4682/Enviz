import 'dart:async';

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

import '../JS_Web_View/View/area_chart/area_chart_for_historical.dart';
import '../JS_Web_View/heat_map.dart';
import '../controller/historical/historical_controller.dart';
import '../pdf/pdf_helper_function.dart';
import '../widgets/box_with_icon.dart';
import '../widgets/custom_text.dart';
import '../widgets/side_drawer.dart';
import '../widgets/starting_nd_ending.dart';

class Historical extends StatefulWidget {
  const Historical({Key? key}) : super(key: key);

  @override
  State<Historical> createState() => _HistoricalState();
}

class _HistoricalState extends State<Historical> {
  final HistoricalController controller = Get.put(HistoricalController());
  final ScreenshotController screenshotController3 = ScreenshotController();
  final ScreenshotController screenshotController6 = ScreenshotController();
  final Logger logger = Logger();
  bool _isGeneratingPDF = false;

  late Timer _fetchDataTimer;

  @override
  void initState() {
    super.initState();
    logger.d('initState');
    _initializeData();
  }

  void _initializeData() {
    Future.delayed(Duration(seconds: 1), () {
      setState(() {

      }); // Trigger rebuild after delay
    });
    controller.fetchDataForAreaChart();
    controller.updateDateRange();
    controller.fetchDataForHeatmap();
    controller.checkInitialData();
    controller.kwData.clear();
    controller.update();
  }

  Future<String> getUserName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('username') ?? 'Your Name';
  }

  Future<void> generateCustomPdf() async {
    try {
      setState(() {
        _isGeneratingPDF = true;
      });

      logger.d("Generating PDF...");
      await Future.delayed(const Duration(seconds: 2));
      List<Uint8List> images = await _captureScreenshots();

      if (images.isEmpty) {
        logger.e("No images to add to PDF");
        return;
      }

      String userName = await getUserName();
      logger.d("Creating PDF...");
      await PDFHelper.createCustomPdf(images, '$userName.pdf', userName);
      logger.d("PDF generation completed.");
    } catch (e) {
      logger.e("Error generating custom PDF: $e");
    } finally {
      setState(() {
        _isGeneratingPDF = false;
      });
    }
  }

  Future<List<Uint8List>> _captureScreenshots() async {
    List<Uint8List> images = [];

    Uint8List? image1 = await screenshotController3.capture();
    if (image1 != null) {
      images.add(image1);
    } else {
      logger.e("Error: Failed to capture image 1");
    }

    Uint8List? image2 = await screenshotController6.capture();
    if (image2 != null) {
      images.add(image2);
    } else {
      logger.e("Error: Failed to capture image 2");
    }

    return images;
  }

  @override
  void dispose() {
    controller.kwData.clear();
    _fetchDataTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    logger.d('Building UI');
    return Stack(
      children: [
        Scaffold(
          body: ModalProgressHUD(
              inAsyncCall: _isGeneratingPDF, child: _buildUI()),
        ),
        _isGeneratingPDF ? _buildBlurLayer() : Container(),
      ],
    );
  }

  Widget _buildBlurLayer() {
    return BackdropFilter(
      filter: ui.ImageFilter.blur(sigmaX: 3, sigmaY: 3),
      child: Container(
        color: Colors.black.withOpacity(0.5),
        alignment: Alignment.center,
        child: const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(Color(0xff009F8D)),
        ),
      ),
    );
  }

  Widget _buildUI() {
    controller.fetchDataForAreaChart();
    return Scaffold(
      drawer: Sidedrawer(context: context),
      appBar: _appBarForHistorical(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildDateSelectionRow(),
            SelectStartAndEndDate(controller: controller, context: context),
            const SizedBox(height: 30),
            _buildDataDisplay(),
            const SizedBox(height: 20),
            Screenshot(
              controller: screenshotController3,
              child: AreaChartScreen(),
            ),
            const SizedBox(height: 20),
            Heatmap(),
          ],
        ),
      ),
    );
  }

  AppBar _appBarForHistorical() {
    return AppBar(
      title: Center(
        child: CustomText(
          texts: 'Historical',
          textColor: const Color(0xff002F46),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.receipt, color: Color(0xff009F8D)),
          onPressed: generateCustomPdf,
        ),
        const BoxwithIcon(),
      ],
    );
  }

  Widget _buildDateSelectionRow() {
    return Padding(
      padding: const EdgeInsets.only(left: 30, right: 50, top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(
            texts: 'Start date',
            textColor: const Color(0xff002F46),
          ),
          CustomText(
            texts: 'End date',
            textColor: const Color(0xff002F46),
          ),
        ],
      ),
    );
  }

  Widget _buildDataDisplay() {
    return Obx(() {
      if (controller.isLoading.value) {
        return CircularProgressIndicator();
      }

      final firstApiData = controller.firstApiData!.value;
      if (firstApiData == null || firstApiData.isEmpty) {
        return const Text('No data available');
      } else {
        if (firstApiData.containsKey("Main")) {
          return _buildUiForMain(firstApiData);
        } else {
          List<String> modifiedKeys =
          firstApiData.keys.map((key) => '$key\_[kW]').toList();
          return _buildUiForOther(modifiedKeys);
        }
      }
    });
  }

  Widget _buildUiForMain(Map<String, dynamic> firstApiResponse) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const CircularProgressIndicator();
      }

      final secondApiData = controller.secondApiData!.value;
      if (secondApiData == null || secondApiData.isEmpty) {
        return const Text('No data available');
      } else {
        List<double> sumsList = _getSumsList(secondApiData["Main_[kW]"]);
        double totalSum = controller.calculateTotalSum(sumsList);
        double minSum = controller.calculateMin(sumsList);
        double maxSum = controller.calculateMax(sumsList);
        double avgSum = controller.calculateAverage(sumsList);

        return _buildSummaryUi(totalSum, minSum, maxSum, avgSum);
      }
    });
  }

  List<double> _getSumsList(List<dynamic> data) {
    List<double> sumsList = [];
    for (var value in data) {
      double sum = controller.parseDouble(value);
      sumsList.add(sum);
    }
    return sumsList;
  }

  Widget _buildSummaryUi(
      double totalSum, double minSum, double maxSum, double avgSum) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildSummaryRow(totalSum, minSum, maxSum, avgSum),
          SizedBox(height: 30),
          _buildSummaryRow(minSum, maxSum, avgSum, totalSum, isMinMaxAvg: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(double value1, double value2, double value3, double value4,
      {bool isMinMaxAvg = false}) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: _buildSummaryBox(
                isMinMaxAvg ? 'Min' : 'cost',
                isMinMaxAvg ? controller.formatValue(value1) : 'Rs ${controller.formatValued(value1 * 70)}',
                isMinMaxAvg ? 'assets/images/Minus.png' : 'assets/images/moneylogo.png'
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 1,
            child: _buildSummaryBox(
                isMinMaxAvg ? 'Max' : 'power',
                isMinMaxAvg ? controller.formatValue(value2) : controller.formatValue(value1),
                isMinMaxAvg ? 'assets/images/Plus.png' : 'assets/images/Lightning Bolt.png'
            ),
          ),
          const SizedBox(width: 10),
          if (isMinMaxAvg)
            Expanded(
              flex: 1,
              child: _buildSummaryBox(
                  'Avg',
                  controller.formatValue(value3),
                  'assets/images/Disconnected.png'
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryBox(String label, String value, String photoPath) {
    return Container(
      height: 110,
      width: 150,
      decoration: BoxDecoration(
        color: Color(0xff002f46),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  texts: label,
                  textColor: Color(0xff009f8d),
                ),
                SizedBox(
                  width: 20,
                  height: 20,
                  child: Image.asset(photoPath),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                height: 1.5,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUiForOther(List<String> modifiedKeys) {
    return Obx(() {
      final secondApiData = controller.secondApiData!.value;
      if (secondApiData == null || secondApiData.isEmpty) {
        return const CircularProgressIndicator();
      } else {
        List<double> sumsList = _getModifiedSumsList(modifiedKeys, secondApiData);
        double totalSum = controller.calculateTotalSum(sumsList);
        double minSum = controller.calculateMin(sumsList);
        double maxSum = controller.calculateMax(sumsList);
        double avgSum = controller.calculateAverage(sumsList);

        return _buildSummaryUi(totalSum, minSum, maxSum, avgSum);
      }
    });
  }

  List<double> _getModifiedSumsList(List<String> modifiedKeys, Map<String, dynamic> data) {
    List<double> sumsList = [];

    int minLength = modifiedKeys
        .where((key) => data.containsKey(key))
        .map((key) => data[key].length)
        .reduce((a, b) => a < b ? a : b);

    for (int i = 0; i < minLength; i++) {
      double sum = 0.0;
      for (String key in modifiedKeys) {
        if (data.containsKey(key)) {
          sum += controller.parseDouble(data[key][i]);
        }
      }
      sumsList.add(sum);
    }
    return sumsList;
  }
}
