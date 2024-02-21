// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:high_chart/high_chart.dart';
// import 'package:http/http.dart' as http;
// class YourScreen extends StatefulWidget {
//   @override
//   _YourScreenState createState() => _YourScreenState();
// }
//
// class _YourScreenState extends State<YourScreen> {
//   List<Map<String, dynamic>> kwData = [];
//   final int pakistaniTimeZoneOffset = 5;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Your App Title'),
//       ),
//       body: ListView.builder(
//         itemCount: kwData.length,
//         itemBuilder: (context, index) {
//           Map<String, dynamic> dayData = kwData[index];
//           String formattedDate = dayData['date'];
//           List<Map<String, dynamic>> newData = dayData['data'];
//
//           return Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Card(
//                 margin: EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Text(
//                         'Date: $formattedDate',
//                         style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                     // Pass the fetched data to StockColumn
//                     StockColumnssss(data: newData, showMeanValue: true),
//                   ],
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: fetchData,
//         child: Icon(Icons.refresh),
//       ),
//     );
//   }
//
//   Future<void> fetchData() async {
//     final username = "ppjiq"; // Replace with your username
//
//     try {
//       // Get the current date
//       DateTime currentDate = DateTime.now();
//       DateTime pakistaniDateTime =
//       currentDate.toUtc().add(Duration(hours: pakistaniTimeZoneOffset));
//       String formattedDate = pakistaniDateTime.toString().split(' ')[0];
//
//       try {
//         // Make an HTTP GET request for today's data
//         final String apiUrl =
//             "http://203.135.63.22:8000/data?username=$username&mode=hour&start=$formattedDate&end=$formattedDate";
//         final response = await http.get(Uri.parse(apiUrl));
//
//         // Check if the request was successful (status code 200)
//         if (response.statusCode == 200) {
//           // Parse the JSON response
//           Map<String, dynamic> jsonData = json.decode(response.body);
//           Map<String, dynamic> data = jsonData['data'];
//
//           List<Map<String, dynamic>> newData = [];
//           data.forEach((itemName, values) {
//             if (itemName.endsWith("[kW]")) {
//               String prefixName = getMainPart(itemName);
//               List<double> numericValues =
//               (values as List<dynamic>).map((value) {
//                 if (value is num) {
//                   return value.toDouble();
//                 } else if (value is String) {
//                   return double.tryParse(value) ?? 0.0;
//                 } else {
//                   return 0.0;
//                 }
//               }).toList();
//
//               // Get the last 5 values
//               List<double> lastFiveValues = numericValues.length > 5
//                   ? numericValues.sublist(numericValues.length - 5)
//                   : numericValues;
//
//               // Calculate the mean of the last 5 values
//               double meanValue = lastFiveValues.isNotEmpty
//                   ? lastFiveValues.reduce((a, b) => a + b) / lastFiveValues.length
//                   : 0.0;
//
//               newData.add({
//                 'prefixName': prefixName,
//                 'values': numericValues,
//                 'lastIndexValue': meanValue, // Displaying mean value instead of last index
//               });
//             }
//           });
//
//           setState(() {
//             kwData.add({'date': formattedDate, 'data': newData});
//           });
//         } else {
//           // Handle unsuccessful response
//           print(
//               'Failed to fetch data for $formattedDate. Status code: ${response.statusCode}');
//           print('Response body: ${response.body}');
//         }
//       } catch (error) {
//         // Handle HTTP request error
//         print('Error fetching data for $formattedDate: $error');
//       }
//     } catch (error) {
//       // Handle general error
//       print('An unexpected error occurred: $error');
//     }
//   }
//
//   // Helper function to format the live value to KW
//   String formatToKW(double value) {
//     double valueInKW = value / 1000.0;
//     return valueInKW.toStringAsFixed(2) + '';
//   }
//
//   // Helper function to extract the main part of the prefixName
//   String getMainPart(String fullName) {
//     List<String> parts = fullName.split('_');
//     if (parts.isNotEmpty) {
//       return parts.first;
//     }
//     return fullName;
//   }
// }
//
// class StockColumnssss extends StatelessWidget {
//   const StockColumnssss({Key? key, required this.data, required this.showMeanValue}) : super(key: key);
//
//   final List<Map<String, dynamic>> data;
//   final bool showMeanValue;
//
//   @override
//   Widget build(BuildContext context) {
//     final String chartData = _generateChartData(data, showMeanValue);
//
//     return HighCharts(
//       loader: const SizedBox(
//         child: LinearProgressIndicator(),
//         width: 200,
//       ),
//       size: const Size(400, 400),
//       data: chartData,
//       scripts: const ["https://code.highcharts.com/highcharts.js"],
//     );
//   }
//
//   String _generateChartData(List<Map<String, dynamic>> data, bool showMeanValue) {
//     // Define a list of colors for each column
//     List<String> columnColors = ['#FF5733', '#33FF57', '#5733FF', '#FFFF33', '#33FFFF', '#FF33FF', '#FAD02E', '#B565A7', '#4DB6AC', '#EF5350'];
//
//     // Prepare the data for chart series with colors
//     List<Map<String, dynamic>> seriesData = data.asMap().entries.map((entry) {
//       int index = entry.key;
//       Map<String, dynamic> itemData = entry.value;
//
//       String prefixName = itemData['prefixName'];
//       double valueToShow = showMeanValue ? itemData['lastIndexValue'] : itemData['values'].last;
//       String color = columnColors[index % columnColors.length]; // Use modulo to repeat colors if needed
//
//       return {
//         'name': prefixName,
//         'y': valueToShow,
//         'color': color,
//       };
//     }).toList();
//
//     // Convert the series data to JSON format
//     String seriesDataJson = jsonEncode(seriesData);
//
//     return '''
//     {
//       chart: {
//         type: 'column',
//       },
//       title: {
//         text: 'Stock Column'
//       },
//       xAxis: {
//         type: 'category',
//       },
//       yAxis: {
//         title: {
//           text: 'Value',
//         },
//       },
//       plotOptions: {
//         column: {
//           colorByPoint: true,
//         },
//       },
//       series: [{
//         name: 'Live Data',
//         data: $seriesDataJson,
//       }],
//     }
//     ''';
//   }
// }




//
// class Stock extends StatelessWidget {
//   const Stock({Key? key, required this.stockColumnData}) : super(key: key);
//
//   final List<List<dynamic>> stockColumnData;
//
//   @override
//   Widget build(BuildContext context) {
//     final String _chartData = '''
//       {
//         accessibility: {
//           enabled: false
//         },
//         chart: {
//           alignTicks: false
//         },
//         rangeSelector: {
//           selected: 1
//         },
//         title: {
//           text: 'Stock Column'
//         },
//         series: [
//           {
//             type: 'column',
//             name: 'Your Data Name', // Customize this
//             data: $stockColumnData,
//             // Other configurations...
//           }
//         ]
//       }
//     ''';
//
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
//       child: HighCharts(
//         loader: const SizedBox(
//           child: LinearProgressIndicator(),
//           width: 200,
//         ),
//         size: const Size(400, 400),
//         data: _chartData,
//         scripts: const ["https://code.highcharts.com/highcharts.js"],
//       ),
//     );
//   }
// }




// void UserRegister() {
//   loading.value = true;
//   final username = usernamenameController.text.toString();
//   final password = passwordController.text;
//
//   if (username != null && password != null) {
//     repository.registerApi(username, password).then((value) async {
//       loading.value = false;
//
//       if (value['error'] == 'User not found') {
//         if (Get.overlayContext != null) {
//           Get.snackbar('Login Error', value['error']);
//         }
//       } else {
//         if (Get.overlayContext != null) {
//           Get.snackbar('Login', 'User Created Successfully');
//           print(
//             {'username': username, 'password': password},
//           );
//
//           Get.to(() => BottomPage());
//         }
//       }
//     }).onError((AppExceptions error, stackTrace) {
//       loading.value = false;
//       if (Get.overlayContext != null) {
//         Get.snackbar('Error', error.message ?? '');
//         print(error.message);
//       }
//     });
//   } else {
//     // Handle the case where either username or password is null
//     loading.value = false;
//     if (Get.overlayContext != null) {
//       Get.snackbar('Error', 'Username or password is null.');
//     }
//   }
// }

//   Future<void> fetchData() async {
//     Set<String> processedDates = Set();
//
//     DateTime now = DateTime.now();
//     DateTime endDate = now;
//     DateTime startDate = now.subtract(Duration(days: 6));
//
//
//     for (DateTime currentDate = startDate;
//     currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate);
//     currentDate = currentDate.add(Duration(days: 1))) {
//       String formattedDate = currentDate.toLocal().toString().split(' ')[0];
//
//       if (processedDates.contains(formattedDate)) {
//         continue;
//       }
//
//       final apiUrl =
//           'http://203.135.63.22:8000/data?username=ppjp2isl&mode=hour&start=&end=$endDate';
// print(startDate);
//       print(startDate);
//       try {
//         final response = await http.get(Uri.parse(apiUrl));
//
//         if (response.statusCode == 200) {
//           Map<String, dynamic> jsonData = json.decode(response.body);
//           Map<String, dynamic> data = jsonData['data'];
//
//           List<Map<String, dynamic>> newData = [];
//
//           data.forEach((itemName, values) {
//             if (itemName.endsWith("[kW]")) {
//               String prefixName = itemName.substring(0, itemName.length - 4);
//               List<double> numericValues = (values as List<dynamic>).map((value) {
//                 if (value is num) {
//                   return value.toDouble();
//                 } else if (value is String) {
//                   return double.tryParse(value) ?? 0.0;
//                 } else {
//                   return 0.0;
//                 }
//               }).toList();
//
//               newData.add({
//                 'prefixName': prefixName,
//                 'values': numericValues,
//               });
//             }
//           });
//
//           // Update kwData with the new data
//           kwData.add({'date': formattedDate, 'data': newData});
//
//           // Update lastMainKWValue with the last value of "Main_[kW]"
//           lastMainKWValue.value = newData
//               .where((item) => item['prefixName'] == 'Main_')
//               .map((item) => item['values'].last)
//               .first;
//
//           // Mark the date as processed to avoid duplicates
//           processedDates.add(formattedDate);
//         } else {
//           print(
//               'Failed to fetch data for $formattedDate. Status code: ${response.statusCode}');
//           print('Response body: ${response.body}');
//         }
//       } catch (error) {
//         print('Error fetching data for $formattedDate: $error');
//       }
//     }
//   }

// Future<void> login() async {
//   try {
//     final response = await http.post(
//       Uri.parse('http://203.135.63.22:8000/signin'),
//       headers: <String, String>{
//         'Content-Type': 'application/x-www-form-urlencoded',
//       },
//       body: {
//         'username': username.value,
//         'password': password.value,
//       },
//     );
//
//     if (response.statusCode == 200) {
//       // Successful login, call the second API
//       //  await fetchData(username.toString()); // Call fetchData here
//       Get.to(() => BottomPage());
//     } else {
//       // Handle login failure
//       print('Login failed. Status code: ${response.statusCode}, Response: ${response.body}');
//       Get.snackbar('Login Failed', 'Invalid credentials');
//     }
//   } catch (e) {
//     // Handle error
//     print(e);
//   }
// }

// Future<void> fetchData() async {
//   // Set to keep track of processed dates
//   Set<String> processedDates = Set();
//
//   try {
//     // Loop through the last seven days
//     for (int i = 6; i >= 0; i--) {
//       // Calculate the date for the current iteration
//       DateTime currentDate = DateTime.now().subtract(Duration(days: i));
//       String formattedDate =
//       currentDate.toLocal().toString().split(' ')[0];
//
//       // Skip fetching if the date has already been processed
//       if (processedDates.contains(formattedDate)) {
//         continue;
//       }
//
//       try {
//         // Make an HTTP GET request
//         final String apiUrl="http://203.135.63.22:8000/data?username=${usernamenameController.text}&mode=hour&start=$formattedDate&end=$formattedDate";
//         final response = await http.get(
//           Uri.parse(apiUrl),
//         );
//         print(apiUrl);
//         // final response = await http.get(Uri.parse(apiUrl));
//
//         // Check if the request was successful (status code 200)
//         if (response.statusCode == 200) {
//           // Parse the JSON response
//           Map<String, dynamic> jsonData = json.decode(response.body);
//           Map<String, dynamic> data = jsonData['data'];
//
//           // Extract and process relevant data
//           List<Map<String, dynamic>> newData = [];
//
//           data.forEach((itemName, values) {
//             if (itemName.endsWith("[kW]")) {
//               String prefixName = itemName.substring(0, itemName.length - 4);
//               List<double> numericValues =
//               (values as List<dynamic>).map((value) {
//                 if (value is num) {
//                   return value.toDouble();
//                 } else if (value is String) {
//                   return double.tryParse(value) ?? 0.0;
//                 } else {
//                   return 0.0;
//                 }
//               }).toList();
//
//               newData.add({
//                 'prefixName': prefixName,
//                 'values': numericValues,
//               });
//             }
//           });
//           // Update kwData with the new data
//           kwData.add({'date': formattedDate, 'data': newData});
//
//           // Update lastMainKWValue with the last value of "Main_[kW]"
//           lastMainKWValue.value = newData
//               .where((item) => item['prefixName'] == 'Main_')
//               .map((item) => item['values'].last)
//               .first;
//
//           // Mark the date as processed to avoid duplicates
//           processedDates.add(formattedDate);
//         } else {
//           // Handle unsuccessful response
//           print(
//               'Failed to fetch data for abubakar $formattedDate. Status code: ${response.statusCode}');
//           print('Response body: ${response.body}');
//         }
//       } catch (error) {
//         // Handle HTTP request error
//         print('Error fetching data for $formattedDate: $error');
//       }
//     }
//   } catch (error) {
//     // Handle general error
//     print('An unexpected error occurred: $error');
//   }
// }

// Future<void> fetchData() async {
//   // Set to keep track of processed dates
//   Set<String> processedDates = Set();
//
//   try {
//     // Loop through the last seven days
//     for (int i = 6; i >= 0; i--) {
//       // Calculate the date for the current iteration
//       DateTime currentDate = DateTime.now().subtract(Duration(days: i));
//       String formattedDate = currentDate.toLocal().toString().split(' ')[0];
//
//       // Skip fetching if the date has already been processed
//       if (processedDates.contains(formattedDate)) {
//         continue;
//       }
//
//       try {
//         // Make an API request using the repository
//         final response = await repository.fetchDataApi(
//           username: usernamenameController.text,
//           mode: 'hour',
//           start: formattedDate,
//           end: formattedDate,
//         );
//
//         print(response); // Print the response for debugging
//
//         // Check if the response is not null
//         if (response != null) {
//           // Check if the response has a key 'statusCode' and its value is 200
//           if (response.containsKey('statusCode') && response['statusCode'] == 200) {
//             // Parse the JSON response
//             Map<String, dynamic> jsonData = response['data'];
//             Map<String, dynamic> data = jsonData['data'];
//
//             // Extract and process relevant data
//             List<Map<String, dynamic>> newData = [];
//
//             data.forEach((itemName, values) {
//               if (itemName.endsWith("[kW]")) {
//                 String prefixName = itemName.substring(0, itemName.length - 4);
//                 List<double> numericValues = (values as List<dynamic>).map((value) {
//                   if (value is num) {
//                     return value.toDouble();
//                   } else if (value is String) {
//                     return double.tryParse(value) ?? 0.0;
//                   } else {
//                     return 0.0;
//                   }
//                 }).toList();
//
//                 newData.add({
//                   'prefixName': prefixName,
//                   'values': numericValues,
//                 });
//               }
//             });
//
//             // Update kwData with the new data
//             kwData.add({'date': formattedDate, 'data': newData});
//
//             // Update lastMainKWValue with the last value of "Main_[kW]"
//             lastMainKWValue.value = newData
//                 .where((item) => item['prefixName'] == 'Main_')
//                 .map((item) => item['values'].last)
//                 .first;
//
//             // Mark the date as processed to avoid duplicates
//             processedDates.add(formattedDate);
//           } else {
//             // Handle unsuccessful response
//             print('Failed to fetch data for $formattedDate. Status code: ${response['statusCode']}');
//             print('Response body: ${response['data']}');
//           }
//         } else {
//           // Handle unexpected response
//           print('Unexpected response format: $response');
//         }
//       } catch (error) {
//         // Handle API request error
//         print('Error fetching data for $formattedDate: $error');
//       }
//     }
//   } catch (error) {
//     // Handle general error
//     print('An unexpected error occurred: $error');
//   }
// }