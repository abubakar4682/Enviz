import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:screenshot/screenshot.dart';
import '../controller/dailyanalysis/daily_analysis_controller.dart';
import '../highcharts/line_charts.dart';
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

  @override
  void initState() {
    apiController.fetchFirstApiData();

    // TODO: implement initState
    super.initState();
  }
  Future<void> generateCustomPdf() async {
    try {
      List<Uint8List> images = [];
      Uint8List? image1 = await screenshotController.capture();
      images.add(image1!); // Repeat for other widgets if necessary

   //  String userName = await getUserName(); // Fetch the user's name from SharedPreferences

      await PDFHelper.createCustomPdf(images, 'custom_document.pdf', 'ahmad');
    } catch (e) {
      print("Error generating custom PDF: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        drawer: Sidedrawer(context: context),
        appBar: AppBar(
          title: Center(
            child: CustomText(
              texts: 'Daily Analysis',
              textColor: const Color(0xff002F46),
            ),
          ),
          actions:  [
            IconButton(
              icon: Icon(Icons.print),
              onPressed: (){},
            ),
            BoxwithIcon(),
          ],
        ),
        body: SingleChildScrollView(
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
                Container(
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
                              String formattedDate = DateFormat('yyyy-MM-dd')
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
                const SizedBox(
                  height: 25,
                ),
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'energy',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                          letterSpacing: 0,
                          color: Color(0xff002f46),
                        ),
                      ),
                      Text(
                        'avg.power',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                          letterSpacing: 0,
                          color: Color(0xff002f46),
                        ),
                      ),
                      Text(
                        'min',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                          letterSpacing: 0,
                          color: Color(0xff002f46),
                        ),
                      ),
                      Text(
                        'max',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                          letterSpacing: 0,
                          color: Color(0xff002f46),
                        ),
                      ),
                    ],
                  ),
                ),
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
              ],
            ),
          ),
        ),
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
        List<double> sumsList = [];
        Map<String, dynamic> mainApiData =
            apiController.secondApiResponse.value!;

        for (int i = 0; i < mainApiData["Main_[kW]"].length; i++) {
          double sum = apiController.parseDouble(mainApiData["Main_[kW]"][i]);
          sumsList.add(sum);
        }

        double totalSum = _calculateTotalSum(sumsList);
        double minSum = _calculateMin(sumsList);
        double maxSum = _calculateMax(sumsList);
        double avgSum = _calculateAverage(sumsList);

        return _buildSummaryUi(totalSum, minSum, maxSum, avgSum, sumsList);
      }
    });
  }

  Widget _buildUiForOther(List<String> modifiedKeys) {
    apiController.fetchSecondApiData(
        modifiedKeys); // Fetch second API data for other keys

    return Obx(() {
      if (apiController.secondApiResponse.value == null) {
        return Center(child: CircularProgressIndicator());
      } else {
        List<double> sumsList = [];
        Map<String, dynamic> filteredData =
            apiController.secondApiResponse.value!;

        for (int i = 0; i < filteredData['1st Floor_[kW]'].length; i++) {
          double sum = apiController
                  .parseDouble(filteredData['1st Floor_[kW]'][i]) +
              apiController.parseDouble(filteredData['Ground Floor_[kW]'][i]);
          sumsList.add(sum);
        }

        double totalSum = _calculateTotalSum(sumsList);
        double minSum = _calculateMin(sumsList);
        double maxSum = _calculateMax(sumsList);
        double avgSum = _calculateAverage(sumsList);

        return _buildSummaryUi(totalSum, minSum, maxSum, avgSum, sumsList);
      }
    });
  }

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

          Screenshot(
            controller: screenshotController,
            child: LineChart(
              allValues: allValues,
            ),
          )
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
