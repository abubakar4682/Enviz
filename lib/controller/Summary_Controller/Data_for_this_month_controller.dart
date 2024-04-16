// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
//
//
// class DataControllerForThisMonth extends GetxController {
//   var isLoading = true.obs;
//   var data = <String, List<double>>{}.obs;
//   DateTime startDate = DateTime.now().subtract(Duration(days: 1));
//
//   @override
//   void onInit() {
//     super.onInit();
//     fetchData();
//   }
//   void resetController() {
//     data.clear(); // Clears all loaded data
//     isLoading.value = false; // Resets the loading state
//     startDate = DateTime.now().subtract(Duration(days: 1)); // Resets the startDate
//     clearSharedPreferences(); // Optionally clear any shared preferences related to the session
//   }
//
//   Future<void> clearSharedPreferences() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.clear(); // This will clear all data in SharedPreferences, adjust if needed
//   }
//
//   Future<void> fetchData() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? storedUsername = prefs.getString('username');
//     isLoading(true);
//     DateTime now = DateTime.now();
//     DateTime endDate = DateTime(now.year, now.month, now.day); // Ensures the time is set to 00:00:00 of today
//     // Set startDate to the first day of the current month
//     DateTime startDate = DateTime(now.year, now.month, 1);
//
//     // Format the dates to 'YYYY-MM-DD' format
//     String formattedStartDate = "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}";
//     String formattedEndDate = "${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}";
//
//     final Uri uri = Uri.parse('http://203.135.63.47:8000/data?username=$storedUsername&mode=hour&start=$formattedStartDate&end=$formattedEndDate');
//
//     try {
//       final response = await http.get(uri);
//       if (response.statusCode == 200) {
//         final jsonResponse = jsonDecode(response.body);
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
//         print('Failed to load data with status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Failed to load data with error: $e');
//     } finally {
//       isLoading(false);
//     }
//   }
//
// }