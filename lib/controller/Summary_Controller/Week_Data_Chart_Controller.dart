// import 'package:connectivity/connectivity.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class WeekDataController extends GetxController {
//   var isLoading = true.obs;
//   var data = <String, List<double>>{}.obs;
//   RxString errorMessage = ''.obs; // New observable for error messages
//   DateTime startDate = DateTime.now().subtract(Duration(days: 1));
//
//   @override
//   void onInit() {
//     super.onInit();
//     fetchData();
//   }
//
//
//   void resetData() {
//     data.clear();
//   }
//
//   Future<void> fetchData() async {
//     errorMessage.value = ''; // Reset error message on new fetch attempt
//     var connectivityResult = await Connectivity().checkConnectivity();
//     if (connectivityResult == ConnectivityResult.none) {
//       errorMessage.value = "No internet connection available.";
//       isLoading(false);
//       return;
//     }
//
//     isLoading(true);
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? storedUsername = prefs.getString('username');
//     if (storedUsername == null) {
//       errorMessage.value = "No username found in preferences.";
//       isLoading(false);
//       return;
//     }
//
//     DateTime endDate = DateTime.now();
//     DateTime startDate = endDate.subtract(Duration(days: 6));
//     String formattedStartDate = "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}";
//     String formattedEndDate = "${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}";
//
//     final Uri uri = Uri.parse('http://203.135.63.47:8000/data?username=$storedUsername&mode=hour&start=$formattedStartDate&end=$formattedEndDate');
//
//     try {
//       final response = await http.get(uri);
//       if (response.statusCode == 200) {
//         final jsonResponse = jsonDecode(response.body);
//         if (jsonResponse.containsKey('error')) {
//           errorMessage.value = jsonResponse['error'];
//           isLoading(false);
//           return;
//         }
//         final Map<String, dynamic> responseData = jsonResponse['data'];
//         final Map<String, List<double>> processedData = {};
//
//         responseData.forEach((key, value) {
//           if (key.endsWith('_[kW]')) {
//             List<double> listValues = (value as List).map((item) {
//               double val = 0.0;
//               if (item != null && item != 'NA' && item != '') {
//                 val = double.tryParse(item.toString()) ?? 0.0;
//               }
//               return double.parse((val / 1000).toStringAsFixed(2));
//             }).toList();
//             processedData[key] = [];
//             for (int i = 0; i < listValues.length; i += 24) {
//               processedData[key]!.add(listValues.sublist(i, i + 24 > listValues.length ? listValues.length : i + 24).reduce((a, b) => a + b));
//             }
//           }
//         });
//
//         data(processedData);
//         this.startDate = startDate;
//       } else {
//         errorMessage.value = 'Failed to load data with status code: ${response.statusCode}';
//       }
//     } catch (e) {
//       errorMessage.value = 'Failed to load data with error: $e';
//     } finally {
//       isLoading(false);
//     }
//   }
// }