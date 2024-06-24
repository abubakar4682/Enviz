import 'dart:typed_data';
import 'package:connectivity/connectivity.dart';

import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controller/dailyanalysis/daily_analysis_controller.dart';
import '../../pdf/pdf_helper_function.dart';
import '../../widgets/box_with_icon.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/side_drawer.dart';
import 'line_chart_widget_tree.dart';

class DailyAnalysis extends StatefulWidget {
  @override
  State<DailyAnalysis> createState() => _DailyAnalysisState();
}

class _DailyAnalysisState extends State<DailyAnalysis> {
  final DailyAnalysisController apiController = Get.put(DailyAnalysisController());
  ScreenshotController scrnshotController
   = ScreenshotController();
  ScreenshotController screenshotController1 = ScreenshotController();
  DateTime _selectedDate = DateTime.now();
  bool _isGeneratingPDF = false;
  bool isOnline = true;

  @override
  void initState() {
    super.initState();
    apiController.fetchFirstApiData();  // Fetch initial data
    checkConnectivity();  // Check network connectivity
  }

  // Check network connectivity
  void checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      isOnline = connectivityResult != ConnectivityResult.none;
    });
  }

  // Fetch the username from SharedPreferences
  Future<String> getUserName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('username') ?? 'Your Name';
  }

  // Generate PDF with screenshots
  Future<void> generateCustomPdf() async {
    try {
      setState(() {
        _isGeneratingPDF = true;
      });

      await Future.delayed(const Duration(seconds: 2));

      List<Uint8List> images = [];
      Uint8List? image1 = await scrnshotController.capture();
      Uint8List? image2 = await screenshotController1.capture();

      if (image1 != null) images.add(image1);
      if (image2 != null) images.add(image2);

      if (images.isEmpty) {
        print("No images to add to PDF");
        return;
      }

      String userName = await getUserName();
      await PDFHelper.createCustomPdf(images, '$userName.pdf', userName);
    } catch (e) {
      print("Error generating custom PDF: $e");
    } finally {
      setState(() {
        _isGeneratingPDF = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Sidedrawer(context: context),
      appBar: buildAppBarForDailyAnalysis(),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CustomText(
                    texts: 'Select Date',
                    textColor: const Color(0xff002F46),
                  ),
                  const SizedBox(height: 20),
                  buildDateSelector(),
                  const SizedBox(height: 25),
                  const PowerDetailsMinMaxAvg(),
                  Obx(() {
                    if (apiController.firstApiResponse.value == null) {
                      return Center(child: CircularProgressIndicator());
                    } else if (apiController.firstApiResponse.value!.containsKey("Main")) {
                      return buildMainDataUI();
                    } else {
                      List<String> modifiedKeys = apiController.firstApiResponse.value!.keys
                          .map((key) => '$key\_[kW]')
                          .toList();
                      return buildOtherDataUI(modifiedKeys);
                    }
                  }),
                  const SizedBox(height: 24),
                  Screenshot(
                    controller: screenshotController1,
                    child: LineChartForDailyAnalysis(),
                  ),
                ],
              ),
            ),
          ),
          _isGeneratingPDF ? buildLoadingOverlay() : SizedBox(),
        ],
      ),
    );
  }

  // Build the AppBar
  AppBar buildAppBarForDailyAnalysis() {
    return AppBar(
      title: Center(
        child: CustomText(
          texts: 'Daily Analysis',
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

  // Build the date selector
  Widget buildDateSelector() {
    return Screenshot(
      controller: scrnshotController,
      child: Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 10, 0),
        padding: const EdgeInsets.fromLTRB(26, 4, 26, 0),
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xffffffff),
          borderRadius: BorderRadius.circular(60),
          boxShadow: const [
            BoxShadow(
              color: Color(0x26000000),
              offset: Offset(0, 11),
              blurRadius: 12,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('EEEE, MMM dd, yyyy').format(_selectedDate),
              style: TextStyle(fontSize: 16),
            ),
            IconButton(
              icon: const Icon(Icons.calendar_today, size: 20),
              onPressed: () {
                showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  builder: (BuildContext context, Widget? child) {
                    return Theme(
                      data: ThemeData.light(),
                      child: child!,
                    );
                  },
                ).then((selectedDate) {
                  if (selectedDate != null) {
                    setState(() {
                      _selectedDate = selectedDate;
                    });
                    String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
                    apiController.endDate.value = formattedDate;
                    apiController.fetchFirstApiData();
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  // Build UI for main data
  Widget buildMainDataUI() {
    apiController.fetchSecondApiData(["Main_[kW]"]);

    return Obx(() {
      if (apiController.secondApiResponse.value == null) {
        return const Center(child: CircularProgressIndicator());
      } else {
        List<double> dailyValues = apiController.secondApiResponse.value!["Main_[kW]"]
            .map<double>((value) => apiController.parseDouble(value))
            .toList();

        double totalSum = calculateTotalSum(dailyValues);
        double minSum = calculateMin(dailyValues);
        double maxSum = calculateMax(dailyValues);
        double avgSum = calculateAverage(dailyValues);

        return buildSummaryUI(totalSum, minSum, maxSum, avgSum);
      }
    });
  }

  // Build UI for other data
  Widget buildOtherDataUI(List<String> modifiedKeys) {
    apiController.fetchSecondApiData(modifiedKeys);

    return Obx(() {
      if (apiController.secondApiResponse.value == null) {
        return const Center(child: CircularProgressIndicator());
      } else {
        List<double> dailyValues = [];
        Map<String, dynamic> data = apiController.secondApiResponse.value!;

        int minLength = modifiedKeys
            .where((key) => data.containsKey(key))
            .map((key) => data[key].length)
            .reduce((a, b) => a < b ? a : b);

        for (int i = 0; i < minLength; i++) {
          double sum = modifiedKeys
              .where((key) => data.containsKey(key))
              .map((key) => apiController.parseDouble(data[key][i]))
              .reduce((a, b) => a + b);
          dailyValues.add(sum);
        }

        double totalSum = calculateTotalSum(dailyValues);
        double minSum = calculateMin(dailyValues);
        double maxSum = calculateMax(dailyValues);
        double avgSum = calculateAverage(dailyValues);

        return buildSummaryUI(totalSum, minSum, maxSum, avgSum);
      }
    });
  }

  // Build the summary UI
  Widget buildSummaryUI(double totalSum, double minSum, double maxSum, double avgSum) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 10, top: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildSummaryText(totalSum),
                buildSummaryText(avgSum),
                buildSummaryText(minSum),
                buildSummaryText(maxSum),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build summary text widget
  Text buildSummaryText(double value) {
    return Text(
      formatValue(value),
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 1.5,
        color: Color(0xff009f8d),
      ),
    );
  }

  // Utility functions to calculate total, min, max, and average
  double calculateTotalSum(List<double> values) => values.reduce((a, b) => a + b);
  double calculateMin(List<double> values) => values.reduce((a, b) => a < b ? a : b);
  double calculateMax(List<double> values) => values.reduce((a, b) => a > b ? a : b);
  double calculateAverage(List<double> values) => values.isEmpty ? 0 : values.reduce((a, b) => a + b) / values.length;

  // Format value for display
  String formatValue(double value) => value >= 1000
      ? '${(value / 1000).toStringAsFixed(2)} kW'
      : '${value.toStringAsFixed(2)} W';

  // Build the loading overlay
  Widget buildLoadingOverlay() {
    return BackdropFilter(
      filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
      child: Container(
        color: Colors.black.withOpacity(0.5),
        alignment: Alignment.center,
        child: const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(Color(0xff009F8D)),
        ),
      ),
    );
  }
}

class PowerDetailsMinMaxAvg extends StatelessWidget {
  const PowerDetailsMinMaxAvg({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextCustom(title: 'Energy'),
          TextCustom(title: 'Avg. Power'),
          TextCustom(title: 'Min'),
          TextCustom(title: 'Max'),
        ],
      ),
    );
  }
}

class TextCustom extends StatelessWidget {
  final String title;
  const TextCustom({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.5,
        color: Color(0xff002f46),
      ),
    );
  }
}
