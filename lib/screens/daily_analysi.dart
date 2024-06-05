import 'dart:typed_data';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controller/dailyanalysis/daily_analysis_controller.dart';
import '../highcharts/line_charts.dart';
import '../linechartdata.dart';
import '../pdf/pdf_helper_function.dart';
import '../widgets/box_with_icon.dart';
import '../widgets/custom_text.dart';
import '../widgets/side_drawer.dart';

class Dailyanalusic extends StatefulWidget {
  @override
  State<Dailyanalusic> createState() => _DailyanalusicState();
}

class _DailyanalusicState extends State<Dailyanalusic> {
  final DailyAnalysisController apiController =
      Get.put(DailyAnalysisController());
  ScreenshotController screenshotController = ScreenshotController();
  ScreenshotController screenshotController1 = ScreenshotController();
  DateTime _selectedDate = DateTime.now();
  bool _isGeneratingPDF = false;
  bool isOnline = true;

  void checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        isOnline = false;
      });
    } else {
      setState(() {
        isOnline = true;
      });
    }
  }

  @override
  void initState() {
    apiController.fetchFirstApiData();

    // TODO: implement initState
    super.initState();
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
      await Future.delayed(Duration(seconds: 2));
      List<Uint8List> images = [];
      Uint8List? image1 = await screenshotController.capture();
      if (image1 != null) {
        images.add(image1);
      }
      Uint8List? image2 = await screenshotController1.capture();
      if (image2 != null) {
        images.add(image2);
      }

      if (images.isEmpty) {
        print("No images to add to PDF");
        return;
      }

      String userName =
          await getUserName(); // Fetch the user's name from SharedPreferences
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
                  const SizedBox(
                    height: 20,
                  ),
                  Screenshot(
                    controller: screenshotController,
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
                            DateFormat('EEEE, MMM dd, yyyy')
                                .format(_selectedDate),
                            // Format the date
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            icon: const Icon(
                              Icons.calendar_today,
                              size: 20,
                            ),
                            onPressed: () {
                              // Call showDatePicker function
                              showDatePicker(
                                context: context,
                                initialDate: _selectedDate,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                                builder: (BuildContext context, Widget? child) {
                                  return Theme(
                                    data: ThemeData.light(),
                                    // You can customize the theme here
                                    child: child!,
                                  );
                                },
                              ).then((selectedDate) {
                                if (selectedDate != null) {
                                  setState(() {
                                    _selectedDate = selectedDate;
                                  });
                                  String formattedDate =
                                      DateFormat('yyyy-MM-dd')
                                          .format(_selectedDate);
                                  apiController.endDate.value = formattedDate;
                                  apiController
                                      .fetchFirstApiData(); // Call fetchSecondApiData with keys if needed
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  const SizedBox(height: 24),

                  PowerDetailsMinMaxAvg(),
                  Obx(() {
                    if (apiController.firstApiResponse.value == null) {
                      return Center(child: CircularProgressIndicator());
                    } else if (apiController.firstApiResponse.value!
                        .containsKey("Main")) {
                      return _buildUiForMain();
                    } else {
                      List<String> modifiedKeys = apiController
                          .firstApiResponse.value!.keys
                          .map((key) => '$key\_[kW]')
                          .toList();
                      return _buildUiForOther(modifiedKeys);
                    }
                  }),
                  SizedBox(height: 24),
                  SizedBox(height: 24),
                  Screenshot(
                    controller: screenshotController1,
                    child:  LineChartForDailyAnalysis(),
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



  Widget _buildUiForMain() {
    apiController.fetchSecondApiData(
        ["Main_[kW]"]); // Fetch second API data for main key

    return Obx(() {
      if (apiController.secondApiResponse.value == null) {
        return Center(child: CircularProgressIndicator());
      } else {
        List<double> alldaliyvalues = [];
        Map<String, dynamic> mainApiData =
            apiController.secondApiResponse.value!;

        for (int i = 0; i < mainApiData["Main_[kW]"].length; i++) {
          double sum = apiController.parseDouble(mainApiData["Main_[kW]"][i]);
          alldaliyvalues.add(sum);
        }

        double totalSum = _calculateTotalSum(alldaliyvalues);
        double minSum = _calculateMin(alldaliyvalues);
        double maxSum = _calculateMax(alldaliyvalues);
        double avgSum = _calculateAverage(alldaliyvalues);

        return _buildSummaryUi(totalSum, minSum, maxSum, avgSum, alldaliyvalues);
      }
    });
  }
  Widget _buildUiForOther(List<String> modifiedKeys) {
    apiController.fetchSecondApiData(modifiedKeys); // Fetch second API data for other keys

    return Obx(() {
      if (apiController.secondApiResponse.value == null) {
        return Center(child: CircularProgressIndicator());
      } else {
        List<double> alldaliyvalues = [];
        Map<String, dynamic> filteredData = apiController.secondApiResponse.value!;

        // Find the minimum length of available data for consistency
        int minLength = modifiedKeys
            .where((key) => filteredData.containsKey(key))
            .map((key) => filteredData[key].length)
            .reduce((a, b) => a < b ? a : b);

        for (int i = 0; i < minLength; i++) {
          double sum = 0.0;
          for (String key in modifiedKeys) {
            if (filteredData.containsKey(key)) {
              sum += apiController.parseDouble(filteredData[key][i]);
            }
          }
          alldaliyvalues.add(sum);
        }

        double totalSum = _calculateTotalSum(alldaliyvalues);
        double minSum = _calculateMin(alldaliyvalues);
        double maxSum = _calculateMax(alldaliyvalues);
        double avgSum = _calculateAverage(alldaliyvalues);

        return _buildSummaryUi(totalSum, minSum, maxSum, avgSum, alldaliyvalues);
      }
    });
  }
  // Widget _buildUiForOther(List<String> modifiedKeys) {
  //   apiController.fetchSecondApiData(
  //       modifiedKeys); // Fetch second API data for other keys
  //
  //   return Obx(() {
  //     if (apiController.secondApiResponse.value == null) {
  //       return Center(child: CircularProgressIndicator());
  //     } else {
  //       List<double> sumsList = [];
  //       Map<String, dynamic> filteredData =
  //           apiController.secondApiResponse.value!;
  //
  //       for (int i = 0; i < filteredData['1st Floor_[kW]'].length; i++) {
  //         double sum = apiController
  //                 .parseDouble(filteredData['1st Floor_[kW]'][i]) +
  //             apiController.parseDouble(filteredData['Ground Floor_[kW]'][i]);
  //         sumsList.add(sum);
  //       }
  //
  //       double totalSum = _calculateTotalSum(sumsList);
  //       double minSum = _calculateMin(sumsList);
  //       double maxSum = _calculateMax(sumsList);
  //       double avgSum = _calculateAverage(sumsList);
  //
  //       return _buildSummaryUi(totalSum, minSum, maxSum, avgSum, sumsList);
  //     }
  //   });
  // }

  Widget _buildSummaryUi(double totalSum, double minSum, double maxSum,
      double avgSum, List<double> allValues) {
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
                TextwithValue(totalSum),
                TextwithValue(avgSum),
                TextwithValue(minSum),
                TextwithValue(maxSum),
              ],
            ),
          ),

          // Screenshot(
          //   controller: screenshotController1,
          //     child: LineChart(
          //       allValues: allValues,
          //     ),
          // ),


          //  _buildAllValuesText('All Values:', allValues),
        ],
      ),
    );
  }

  Text TextwithValue(double maxSum) {
    return Text(
      _formatValue(maxSum),
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 1.5,
        letterSpacing: 0,
        color: Color(0xff009f8d),
      ),
    );
  }

  double _calculateTotalSum(List<double> sums) =>
      sums.reduce((total, current) => total + current);

  double _calculateMin(List<double> sums) =>
      sums.reduce((min, current) => min < current ? min : current);

  double _calculateMax(List<double> sums) =>
      sums.reduce((max, current) => max > current ? max : current);

  double _calculateAverage(List<double> sums) => sums.isEmpty
      ? 0.0
      : sums.reduce((sum, current) => sum + current) / sums.length;

  String _formatValue(double value) => value >= 1000
      ? '${(value / 1000).toStringAsFixed(2)}kW'
      : '${(value / 1000).toStringAsFixed(2)}kW';
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
          icon: Icon(Icons.receipt, color: Color(0xff009F8D)),
          onPressed: () {
            generateCustomPdf();
          },
        ),
        BoxwithIcon(),
      ],
    );
  }

  Widget buildLoadingOverlay() {
    return BackdropFilter(
      filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
      child: Container(
        color: Colors.black.withOpacity(0.5),
        alignment: Alignment.center,
        child: const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(Color(0xff009F8D)), // Custom color
        ),
      ),
    );
  }
}

class PowerDetailsMinMaxAvg extends StatelessWidget {
  const PowerDetailsMinMaxAvg({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextCustom(
            title: 'energy',
          ),
          TextCustom(
            title: 'avg.power',
          ),
          TextCustom(
            title: 'min',
          ),
          TextCustom(
            title: 'max',
          ),
        ],
      ),
    );
  }
}

class TextCustom extends StatelessWidget {
  final String title;

  const TextCustom({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.5,
        letterSpacing: 0,
        color: Color(0xff002f46),
      ),
    );
  }
}

// Row(
// mainAxisAlignment: MainAxisAlignment.spaceBetween,
// children: [
// Padding(
// padding: const EdgeInsets.only(left: 20),
// child: CustomText(
// texts: 'start time',
// textColor: const Color(0xff002F46),
// ),
// ),
// Padding(
// padding: const EdgeInsets.only(right: 50),
// child: CustomText(
// texts: 'end time',
// textColor: const Color(0xff002F46),
// ),
// ),
// ],
// ),
// Row(
// children: [
// Expanded(
// child: Container(
// margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
// padding: EdgeInsets.fromLTRB(26, 4, 26, 0),
// height: 40,
// decoration: BoxDecoration(
// color: Color(0xffffffff),
// borderRadius: BorderRadius.circular(60),
// boxShadow: [
// BoxShadow(
// color: Color(0x26000000),
// offset: Offset(0, 11),
// blurRadius: 12,
// ),
// ],
// ),
// child: TextFormField(
// initialValue: '10',
// decoration: InputDecoration(
// border: InputBorder
//     .none, // Remove the default border of the input field
// ),
// ),
// ),
// ),
// Expanded(
// child: Container(
// margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
// padding: EdgeInsets.fromLTRB(26, 4, 26, 0),
// height: 40,
// decoration: BoxDecoration(
// color: Color(0xffffffff),
// borderRadius: BorderRadius.circular(60),
// boxShadow: [
// BoxShadow(
// color: Color(0x26000000),
// offset: Offset(0, 11),
// blurRadius: 12,
// ),
// ],
// ),
// child: TextFormField(
// initialValue: '10',
// decoration: InputDecoration(
// border: InputBorder
//     .none, // Remove the default border of the input field
// ),
// ),
// ),
// )
// ],
// ),
//       Container(
//       margin: const EdgeInsets.fromLTRB(0, 0, 10, 0),
//   padding: const EdgeInsets.fromLTRB(26, 4, 26, 0),
//   height: 40,
//   decoration: BoxDecoration(
//     color: const Color(0xffffffff),
//     borderRadius: BorderRadius.circular(60),
//     boxShadow: const [
//       BoxShadow(
//         color: Color(0x26000000),
//         offset: Offset(0, 11),
//         blurRadius: 12,
//       ),
//     ],
//   ),
//   child: Row(
//     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//     children: [
//       Text(
//         DateFormat('EEEE, MMM dd, yyyy').format(_selectedDate),
//         // Format the date
//         style: TextStyle(fontSize: 16),
//       ),
//       const SizedBox(width: 10),
//       IconButton(
//         icon: const Icon(
//           Icons.calendar_today,
//           size: 20,
//         ),
//         onPressed: () {
//           // Call showDatePicker function
//           showDatePicker(
//             context: context,
//             initialDate: _selectedDate,
//             firstDate: DateTime(2000),
//             lastDate: DateTime(2100),
//             builder: (BuildContext context, Widget? child) {
//               return Theme(
//                 data: ThemeData.light(),
//                 // You can customize the theme here
//                 child: child!,
//               );
//             },
//           ).then((selectedDate) {
//             if (selectedDate != null) {
//               // Ensure setState is called to update the UI
//               setState(() {
//                 _selectedDate = selectedDate;
//               });
//             }
//           });
//         },
//       ),
//     ],
//   ),
// ),
