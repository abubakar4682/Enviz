import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../highcharts/Historical_Tab_Charts/area_chart_for_historical.dart';
import '../../highcharts/Historical_Tab_Charts/heat_map.dart';
import '../../controller/historical/historical_controller.dart';

import '../../widgets/box_with_icon.dart';
import '../../widgets/custom_text.dart';

import '../../widgets/side_drawer.dart';
import '../../widgets/starting_nd_ending.dart';


import 'dart:typed_data';

import '../../pdf/pdf_helper_function.dart';


import '../../widgets/side_drawer.dart';
class HistoricalTab extends StatefulWidget {
  const HistoricalTab({Key? key}) : super(key: key);

  @override
  State<HistoricalTab> createState() => _HistoricalTabState();
}

class _HistoricalTabState extends State<HistoricalTab> {
  final controller = Get.put(HistoricalController());

  late Timer _fetchDataTimer;
  ScreenshotController screenshotController1 = ScreenshotController();
  ScreenshotController screenshotController2 = ScreenshotController();
  ScreenshotController screenshotController3 = ScreenshotController();
  @override
  void initState() {
    super.initState();

    controller.kwData.clear();

    // Delay the fetchData calls to the next frame to avoid calling them during the build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.checkInitialData();
      controller.fetchDataForHeatmap();
      controller.fetchDataForAreaChart();
    });
  }

  Future<String> getUserName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('username') ?? 'Your Name';
  }
  Future<void> generateCustomPdf() async {
    try {
      List<Uint8List> images = [];

      // Capture images and check for null
      Uint8List? image1 = await screenshotController1.capture();
      if (image1 != null) images.add(image1);




      if (images.isEmpty) {
        print("No images to add to PDF");
        return;
      }

      String userName = await getUserName();  // Fetch the user's name from SharedPreferences
      await PDFHelper.createCustomPdf(images, 'custom_document.pdf', userName);
    } catch (e) {
      print("Error generating custom PDF: $e");
    }
  }
  @override
  void dispose() {
    controller.kwData.clear();
    _fetchDataTimer.cancel();
    super.dispose();
  }

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    controller.fetchDataForHeatmap();
    controller.fetchDataForAreaChart();
    print('heatmap ');
    return Scaffold(
      drawer: Sidedrawer(context: context),
      appBar: appBarForHistorical(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 30, right: 50, top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(
                    texts: 'Start date',
                    textColor: Color(0xff002F46),
                  ),
                  CustomText(
                    texts: 'End date',
                    textColor: Color(0xff002F46),
                  ),
                ],
              ),
            ),
            SelectStartAndEndDate(controller: controller, context: context),
            const SizedBox(
              height: 30,
            ),
            Obx(() {
              if (controller.isLoading.value) {
                return CircularProgressIndicator();
              }

              final firstApiData = controller.firstApiData!.value;
              if (firstApiData == null || firstApiData.isEmpty) {
                return Text('No data available');
              } else {
                if (firstApiData.containsKey("Main")) {
                  return _buildUiForMain(firstApiData);
                } else {
                  List<String> modifiedKeys =
                      firstApiData.keys.map((key) => '$key\_[kW]').toList();
                  return _buildUiForOther(modifiedKeys);
                }
              }
            }),
            const SizedBox(
              height: 20,
            ),
            Screenshot(
                controller: screenshotController1,
                child: AreaChartScreen()
            ),

            const SizedBox(
              height: 20,
            ),
            Screenshot(
              controller: screenshotController2,
              child: Heatmap(),
            ),
          ],
        ),
      ),
    );
  }

  AppBar appBarForHistorical() {
    return AppBar(
      title: Center(
        child: CustomText(
          texts: 'Historical',
          textColor: const Color(0xff002F46),
        ),
      ),
      actions: [
        IconButton(
          icon:  Icon(Icons.receipt, color: Color(0xff009F8D)),
          onPressed:  generateCustomPdf,
        ),
        const BoxwithIcon(),
      ],
    );
  }
  // Future<void> createAndDownloadPdf() async {
  //   try {
  //     final areaChartImage = await screenshotControllerAreaChart.capture();
  //     final heatmapImage = await screenshotControllerHeatmap.capture();
  //
  //     if (areaChartImage != null && heatmapImage != null) {
  //       final pdf = pw.Document();
  //
  //       pdf.addPage(
  //         pw.Page(
  //           build: (pw.Context context) {
  //             return pw.Column(
  //               children: [
  //                 pw.Text('Area Chart'),
  //                 pw.Image(pw.MemoryImage(areaChartImage)),
  //               ],
  //             );
  //           },
  //         ),
  //       );
  //
  //       pdf.addPage(
  //         pw.Page(
  //           build: (pw.Context context) {
  //             return pw.Column(
  //               children: [
  //                 pw.Text('Heatmap'),
  //                 pw.Image(pw.MemoryImage(heatmapImage)),
  //               ],
  //             );
  //           },
  //         ),
  //       );
  //
  //       final output = await getTemporaryDirectory();
  //       final file = File("${output.path}/example.pdf");
  //       await file.writeAsBytes(await pdf.save());
  //
  //       await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  //     } else {
  //       print('Failed to capture screenshots.');
  //     }
  //   } catch (e) {
  //     print('Error creating PDF: $e');
  //   }
  // }





  Widget _buildUiForMain(Map<String, dynamic> firstApiResponse) {
    return Obx(() {
      if (controller.isLoading.value) {
        return CircularProgressIndicator();
      }

      final secondApiData = controller.secondApiData!.value;
      if (secondApiData == null || secondApiData.isEmpty) {
        return Text('No data available');
      } else {
        List<double> sumsList = [];
        for (int i = 0; i < secondApiData["Main_[kW]"].length; i++) {
          double sum = controller.parseDouble(secondApiData["Main_[kW]"][i]);
          sumsList.add(sum);
        }

        double totalSum = controller.calculateTotalSum(sumsList);
        double minSum = controller.calculateMin(sumsList);
        double maxSum = controller.calculateMax(sumsList);
        double avgSum = controller.calculateAverage(sumsList);

        return _buildSummaryUi(totalSum, minSum, maxSum, avgSum);
      }
    });
  }

  Widget _buildSummaryUi(
      double totalSum, double minSum, double maxSum, double avgSum) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
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
                                texts: 'cost',
                                textColor: Color(0xff009f8d),
                              ),
                              SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    Image.asset('assets/images/moneylogo.png'),
                              ),
                            ],
                          ),
                          Text(
                            'Rs ${controller.formatValued(totalSum * 70)}',
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
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  flex: 1,
                  child: Container(
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
                                texts: 'power',
                                textColor: Color(0xff009f8d),
                              ),
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: Image.asset(
                                    'assets/images/Lightning Bolt.png'),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            controller.formatValue(totalSum),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              height: 1.5,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
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
                                texts: 'Min',
                                textColor: Color(0xff009f8d),
                              ),
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: Image.asset('assets/images/Minus.png'),
                              ),
                            ],
                          ),
                          Text(
                            controller.formatValue(minSum),
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
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  flex: 1,
                  child: Container(
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
                                texts: 'Max',
                                textColor: Color(0xff009f8d),
                              ),
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: Image.asset('assets/images/Plus.png'),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            controller.formatValue(maxSum),
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
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  flex: 1,
                  child: Container(
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
                                texts: 'Avg',
                                textColor: Color(0xff009f8d),
                              ),
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: Image.asset(
                                    'assets/images/Disconnected.png'),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            controller.formatValue(avgSum),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              height: 1.5,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBox(String label, String value, String photoPath) {
    // Parse the value as double
    //double parsedValue = double.parse(value);
    String formattedValue = value.replaceAll('kW', '').trim();
    double parsedValue = double.tryParse(formattedValue) ?? 0.0;
    return Container(
      height: 85,
      width: 120,
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
                Text(
                  label,
                  style: TextStyle(color: Color(0xff009f8d)),
                ),
                SizedBox(
                  width: 20,
                  height: 20,
                  child: Image.asset(photoPath),
                ),
              ],
            ),
            Text(
              // Format the value using the formatToKilo function
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
        return CircularProgressIndicator();
      } else {
        List<double> sumsList = [];

        // Find the minimum length of available data for consistency
        int minLength = modifiedKeys
            .where((key) => secondApiData.containsKey(key))
            .map((key) => secondApiData[key].length)
            .reduce((a, b) => a < b ? a : b);

        for (int i = 0; i < minLength; i++) {
          double sum = 0.0;
          for (String key in modifiedKeys) {
            if (secondApiData.containsKey(key)) {
              sum += controller.parseDouble(secondApiData[key][i]);
            }
          }
          sumsList.add(sum);
        }

        double totalSum = controller.calculateTotalSum(sumsList);
        double minSum = controller.calculateMin(sumsList);
        double maxSum = controller.calculateMax(sumsList);
        double avgSum = controller.calculateAverage(sumsList);

        return _buildSummaryUi(totalSum, minSum, maxSum, avgSum);
      }
    });
  }
}
