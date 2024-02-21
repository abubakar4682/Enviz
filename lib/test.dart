import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MyHomePage extends StatefulWidget {

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final String firstApiUrl = 'http://203.135.63.22:8000/buildingmap?username=ahmad';
  final String secondApiUrl = 'http://203.135.63.22:8000/data?username=ahmad&mode=hour&start=2024-02-11&end=2024-02-11';

  Future<Map<String, dynamic>> fetchFirstApiData() async {
    final response = await http.get(Uri.parse(firstApiUrl));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data from the first API');
    }
  }

  Future<Map<String, dynamic>> fetchSecondApiData(List<String> keys) async {
    final response = await http.get(Uri.parse(secondApiUrl));

    if (response.statusCode == 200) {
      Map<String, dynamic> secondApiResponse = json.decode(response.body);
      Map<String, dynamic> filteredData = {};

      keys.forEach((key) {
        if (secondApiResponse['data'].containsKey(key)) {
          if (secondApiResponse['data'][key].isEmpty) {
            filteredData[key] = List<double>.filled(24, 0.0);
          } else {
            List<dynamic> dataList = secondApiResponse['data'][key];
            List<double> sanitizedDataList = dataList.map((value) {
              if (value == null || value == "NA") {
                return 0.0;
              }
              return double.tryParse(value.toString()) ?? 0.0;
            }).toList();

            filteredData[key] = sanitizedDataList;
          }
        }
      });

      return filteredData;
    } else {
      throw Exception('Failed to load data from the second API');
    }
  }

  double parseDouble(dynamic value) {
    if (value == null || value == "NA") {
      return 0.0;
    }
    return double.tryParse(value.toString()) ?? 0.0;
  }

  double calculateTotalSum(List<double> sums) => sums.reduce((total, current) => total + current);

  double calculateMin(List<double> sums) => sums.reduce((min, current) => min < current ? min : current);

  double calculateMax(List<double> sums) => sums.reduce((max, current) => max > current ? max : current);

  double calculateAverage(List<double> sums) => sums.isEmpty ? 0.0 : sums.reduce((sum, current) => sum + current) / sums.length;

  String formatValue(double value) => value >= 1000 ? '${(value / 1000).toStringAsFixed(2)}kW' : '${(value / 1000).toStringAsFixed(2)}kW';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('API Response'),
      ),
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: fetchFirstApiData(),
          builder: (context, firstApiSnapshot) {
            if (firstApiSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (firstApiSnapshot.hasError) {
              return Center(child: Text('Error: ${firstApiSnapshot.error}'));
            } else if (firstApiSnapshot.data == null) {
              return Center(child: Text('No data available from the first API'));
            } else {
              Map<String, dynamic> firstApiResponse = firstApiSnapshot.data! as Map<String, dynamic>;

              if (firstApiResponse.containsKey("Main")) {
                return _buildUiForMain(firstApiResponse);
              } else {
                List<String> modifiedKeys = firstApiResponse.keys.map((key) => '$key\_[kW]').toList();
                return _buildUiForOther(modifiedKeys);
              }
            }
          },
        ),
      ),
    );
  }

  Widget _buildUiForMain(Map<String, dynamic> firstApiResponse) {
    return FutureBuilder(
      future: fetchSecondApiData(["Main_[kW]"]),
      builder: (context, mainApiSnapshot) {
        if (mainApiSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (mainApiSnapshot.hasError) {
          return Center(child: Text('Error: ${mainApiSnapshot.error}'));
        } else if (mainApiSnapshot.data == null) {
          print('Main API data is null.');
          return Center(child: Text('No data available for the Main_[kW] key'));
        } else {
          List<double> sumsList = [];
          Map<String, dynamic> mainApiData = mainApiSnapshot.data! as Map<String, dynamic>;

          for (int i = 0; i < mainApiData["Main_[kW]"].length; i++) {
            double sum = parseDouble(mainApiData["Main_[kW]"][i]);
            sumsList.add(sum);
          }

          double totalSum = calculateTotalSum(sumsList);
          double minSum = calculateMin(sumsList);
          double maxSum = calculateMax(sumsList);
          double avgSum = calculateAverage(sumsList);

          return _buildSummaryUi(totalSum, minSum, maxSum, avgSum, sumsList);
        }
      },
    );
  }

  Widget _buildUiForOther(List<String> modifiedKeys) {
    return FutureBuilder(
      future: fetchSecondApiData(modifiedKeys),
      builder: (context, secondApiSnapshot) {
        if (secondApiSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (secondApiSnapshot.hasError) {
          return Center(child: Text('Error: ${secondApiSnapshot.error}'));
        } else if (secondApiSnapshot.data == null) {
          print('Second API data is null.');
          return Center(child: Text('No data available from the second API'));
        } else {
          List<double> sumsList = [];
          Map<String, dynamic> filteredData = secondApiSnapshot.data! as Map<String, dynamic>;

          for (int i = 0; i < filteredData['1st Floor_[kW]'].length; i++) {
            double sum = parseDouble(filteredData['1st Floor_[kW]'][i]) + parseDouble(filteredData['Ground Floor_[kW]'][i]);
            sumsList.add(sum);
          }

          double totalSum = calculateTotalSum(sumsList);
          double minSum = calculateMin(sumsList);
          double maxSum = calculateMax(sumsList);
          double avgSum = calculateAverage(sumsList);

          return _buildSummaryUi(totalSum, minSum, maxSum, avgSum, sumsList);
        }
      },
    );
  }

  Widget _buildSummaryUi(double totalSum, double minSum, double maxSum, double avgSum, List<double> allValues) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // _buildSummaryText('Total Power:', formatValue(totalSum)),
          // _buildSummaryText('Min Power:', formatValue(minSum)),
          // _buildSummaryText('Max Power:', formatValue(maxSum)),
          // _buildSummaryText('Average Power:', formatValue(avgSum)),
          _buildAllValuesText('All Values:', allValues),
        ],
      ),
    );
  }

  Widget _buildSummaryText(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          'Value: $value',
          style: TextStyle(fontSize: 18),
        ),
        Divider(),
      ],
    );
  }

  Widget _buildAllValuesText(String title, List<double> values) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Column(
          children: values.map((value) {
            return Text(
              formatValue(value),
              style: TextStyle(fontSize: 18),
            );
          }).toList(),
        ),
        Divider(),
      ],
    );
  }
}


// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
//
// class MyHomePage extends StatefulWidget {
//
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   // SharedPreferences prefs =  SharedPreferences.getInstance() as SharedPreferences;
//   // String? storedUsername = prefs.getString('username');
//
//   final String firstApiUrl = 'http://203.135.63.22:8000/buildingmap?username=ppjp7isl';
//   final String secondApiUrl = 'http://203.135.63.22:8000/data?username=ppjp7isl&mode=hour&start=2024-01-11&end=2024-02-14';
//
//   Future<Map<String, dynamic>> fetchFirstApiData() async {
//     final response = await http.get(Uri.parse(firstApiUrl));
//
//     if (response.statusCode == 200) {
//       return json.decode(response.body);
//     } else {
//       throw Exception('Failed to load data from the first API');
//     }
//   }
//
//   Future<Map<String, dynamic>> fetchSecondApiData(List<String> keys) async {
//     final response = await http.get(Uri.parse(secondApiUrl));
//
//     if (response.statusCode == 200) {
//       Map<String, dynamic> secondApiResponse = json.decode(response.body);
//       Map<String, dynamic> filteredData = {};
//
//       keys.forEach((key) {
//         if (secondApiResponse['data'].containsKey(key)) {
//           // Check if the list is empty
//           if (secondApiResponse['data'][key].isEmpty) {
//             // Handle empty list by setting all values to 0.0
//             filteredData[key] = List<double>.filled(24, 0.0); // Assuming list length is 24
//           } else {
//             // Replace null, "NA", and empty lists with zeros
//             List<dynamic> dataList = secondApiResponse['data'][key];
//             List<double> sanitizedDataList = dataList.map((value) {
//               if (value == null || value == "NA") {
//                 return 0.0;
//               }
//               return double.tryParse(value.toString()) ?? 0.0;
//             }).toList();
//
//             filteredData[key] = sanitizedDataList;
//           }
//         }
//       });
//
//       return filteredData;
//     } else {
//       throw Exception('Failed to load data from the second API');
//     }
//   }
//
//
//
//
//
//   double parseDouble(dynamic value) {
//     if (value == null || value == "NA") {
//       return 0.0;
//     }
//     return double.tryParse(value.toString()) ?? 0.0;
//   }
//
//   double calculateTotalSum(List<double> sums) => sums.reduce((total, current) => total + current);
//
//   double calculateMin(List<double> sums) => sums.reduce((min, current) => min < current ? min : current);
//
//   double calculateMax(List<double> sums) => sums.reduce((max, current) => max > current ? max : current);
//
//   double calculateAverage(List<double> sums) => sums.isEmpty ? 0.0 : sums.reduce((sum, current) => sum + current) / sums.length;
//
//   String formatValue(double value) => value >= 1000 ? '${(value / 1000).toStringAsFixed(2)}kW' : '${(value / 1000).toStringAsFixed(2)}kW';
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('API Response'),
//       ),
//       body: FutureBuilder(
//         future: fetchFirstApiData(),
//         builder: (context, firstApiSnapshot) {
//           if (firstApiSnapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           } else if (firstApiSnapshot.hasError) {
//             return Center(child: Text('Error: ${firstApiSnapshot.error}'));
//           } else if (firstApiSnapshot.data == null) {
//             return Center(child: Text('No data available from the first API'));
//           } else {
//             Map<String, dynamic> firstApiResponse = firstApiSnapshot.data! as Map<String, dynamic>;
//
//             if (firstApiResponse.containsKey("Main")) {
//               return _buildUiForMain(firstApiResponse);
//             } else {
//               List<String> modifiedKeys = firstApiResponse.keys.map((key) => '$key\_[kW]').toList();
//               return _buildUiForOther(modifiedKeys);
//             }
//           }
//         },
//       ),
//     );
//   }
//
//   Widget _buildUiForMain(Map<String, dynamic> firstApiResponse) {
//     return FutureBuilder(
//       future: fetchSecondApiData(["Main_[kW]"]),
//       builder: (context, mainApiSnapshot) {
//         if (mainApiSnapshot.connectionState == ConnectionState.waiting) {
//           return Center(child: CircularProgressIndicator());
//         } else if (mainApiSnapshot.hasError) {
//           return Center(child: Text('Error: ${mainApiSnapshot.error}'));
//         } else if (mainApiSnapshot.data == null) {
//           print('Main API data is null.');
//           return Center(child: Text('No data available for the Main_[kW] key'));
//         } else {
//           List<double> sumsList = [];
//           Map<String, dynamic> mainApiData = mainApiSnapshot.data! as Map<String, dynamic>;
//
//           for (int i = 0; i < mainApiData["Main_[kW]"].length; i++) {
//             double sum = parseDouble(mainApiData["Main_[kW]"][i]);
//             sumsList.add(sum);
//           }
//
//           double totalSum = calculateTotalSum(sumsList);
//           double minSum = calculateMin(sumsList);
//           double maxSum = calculateMax(sumsList);
//           double avgSum = calculateAverage(sumsList);
//
//           return _buildSummaryUi(totalSum, minSum, maxSum, avgSum);
//         }
//       },
//     );
//   }
//
//   Widget _buildUiForOther(List<String> modifiedKeys) {
//     return FutureBuilder(
//       future: fetchSecondApiData(modifiedKeys),
//       builder: (context, secondApiSnapshot) {
//         if (secondApiSnapshot.connectionState == ConnectionState.waiting) {
//           return Center(child: CircularProgressIndicator());
//         } else if (secondApiSnapshot.hasError) {
//           return Center(child: Text('Error: ${secondApiSnapshot.error}'));
//         } else if (secondApiSnapshot.data == null) {
//           print('Second API data is null.');
//           return Center(child: Text('No data available from the second API'));
//         } else {
//           List<double> sumsList = [];
//           Map<String, dynamic> filteredData = secondApiSnapshot.data! as Map<String, dynamic>;
//
//           for (int i = 0; i < filteredData['1st Floor_[kW]'].length; i++) {
//             double sum = parseDouble(filteredData['1st Floor_[kW]'][i]) + parseDouble(filteredData['Ground Floor_[kW]'][i]);
//             sumsList.add(sum);
//           }
//
//           double totalSum = calculateTotalSum(sumsList);
//           double minSum = calculateMin(sumsList);
//           double maxSum = calculateMax(sumsList);
//           double avgSum = calculateAverage(sumsList);
//
//           return _buildSummaryUi(totalSum, minSum, maxSum, avgSum);
//         }
//       },
//     );
//   }
//
//   Widget _buildSummaryUi(double totalSum, double minSum, double maxSum, double avgSum,List<double> allValues) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           _buildSummaryText('Total Power:', formatValue(totalSum)),
//           _buildSummaryText('Min Power:', formatValue(minSum)),
//           _buildSummaryText('Max Power:', formatValue(maxSum)),
//           _buildSummaryText('Average Power:', formatValue(avgSum)),
//
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSummaryText(String title, String value) {
//     return Column(
//       children: [
//         Text(
//           title,
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         Text(
//           'Value: $value',
//           style: TextStyle(fontSize: 18),
//         ),
//         Divider(),
//       ],
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
//
// class MyHomePage extends StatefulWidget {
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   final String firstApiUrl = 'http://203.135.63.22:8000/buildingmap?username=ahmad';
//   final String secondApiUrl = 'http://203.135.63.22:8000/data?username=ahmad&mode=hour&start=2024-01-01&end=2024-02-10';
//
//   Future<Map<String, dynamic>> fetchFirstApiData() async {
//     final response = await http.get(Uri.parse(firstApiUrl));
//
//     if (response.statusCode == 200) {
//       return json.decode(response.body);
//     } else {
//       throw Exception('Failed to load data from the first API');
//     }
//   }
//
//   Future<Map<String, dynamic>> fetchSecondApiData(List<String> keys) async {
//     final response = await http.get(Uri.parse(secondApiUrl));
//
//     if (response.statusCode == 200) {
//       Map<String, dynamic> secondApiResponse = json.decode(response.body);
//
//       Map<String, dynamic> filteredData = {};
//       keys.forEach((key) {
//         if (secondApiResponse['data'].containsKey(key)) {
//           filteredData[key] = secondApiResponse['data'][key];
//         }
//       });
//
//       return filteredData;
//     } else {
//       throw Exception('Failed to load data from the second API');
//     }
//   }
//
//   double parseDouble(dynamic value) {
//     if (value == null || value == "NA") {
//       return 0.0;
//     }
//     return double.tryParse(value.toString()) ?? 0.0;
//   }
//
//   double calculateTotalSum(List<double> sums) {
//     return sums.reduce((total, current) => total + current);
//   }
//
//   double calculateMin(List<double> sums) {
//     return sums.reduce((min, current) => min < current ? min : current);
//   }
//
//   double calculateMax(List<double> sums) {
//     return sums.reduce((max, current) => max > current ? max : current);
//   }
//
//   double calculateAverage(List<double> sums) {
//     if (sums.isEmpty) return 0.0;
//     return sums.reduce((sum, current) => sum + current) / sums.length;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('API Response'),
//       ),
//       body: FutureBuilder(
//         future: fetchFirstApiData(),
//         builder: (context, firstApiSnapshot) {
//           if (firstApiSnapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           } else if (firstApiSnapshot.hasError) {
//             return Center(child: Text('Error: ${firstApiSnapshot.error}'));
//           } else if (firstApiSnapshot.data == null) {
//             return Center(child: Text('No data available from the first API'));
//           } else {
//             Map<String, dynamic> firstApiResponse = firstApiSnapshot.data! as Map<String, dynamic>;
//
//             if (firstApiResponse.containsKey("Main")) {
//               return FutureBuilder(
//                 future: fetchSecondApiData(["Main_[kW]"]),
//                 builder: (context, mainApiSnapshot) {
//                   if (mainApiSnapshot.connectionState == ConnectionState.waiting) {
//                     return Center(child: CircularProgressIndicator());
//                   } else if (mainApiSnapshot.hasError) {
//                     return Center(child: Text('Error: ${mainApiSnapshot.error}'));
//                   } else if (mainApiSnapshot.data == null) {
//                     print('Main API data is null.');
//                     return Center(child: Text('No data available for the Main_[kW] key'));
//                   } else {
//                     List<double> sumsList = [];
//
//                     Map<String, dynamic> mainApiData = mainApiSnapshot.data! as Map<String, dynamic>;
//
//                     for (int i = 0; i < mainApiData["Main_[kW]"].length; i++) {
//                       double sum = parseDouble(mainApiData["Main_[kW]"][i]);
//                       sumsList.add(sum);
//                     }
//
//                     double totalSum = calculateTotalSum(sumsList);
//                     double minSum = calculateMin(sumsList);
//                     double maxSum = calculateMax(sumsList);
//                     double avgSum = calculateAverage(sumsList);
//
//                     // Display Total Sum, Min, Max, and Avg on the UI
//                     return Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           Text(
//                             'Total Sum:',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           Text(
//                             'Value: $totalSum',
//                             style: TextStyle(fontSize: 18),
//                           ),
//                           Divider(),
//                           Text(
//                             'Min Sum:',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           Text(
//                             'Value: $minSum',
//                             style: TextStyle(fontSize: 18),
//                           ),
//                           Divider(),
//                           Text(
//                             'Max Sum:',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           Text(
//                             'Value: $maxSum',
//                             style: TextStyle(fontSize: 18),
//                           ),
//                           Divider(),
//                           Text(
//                             'Average Sum:',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           Text(
//                             'Value: $avgSum',
//                             style: TextStyle(fontSize: 18),
//                           ),
//                         ],
//                       ),
//                     );
//                   }
//                 },
//               );
//             } else {
//               List<String> modifiedKeys = firstApiResponse.keys.map((key) => '$key\_[kW]').toList();
//
//               return FutureBuilder(
//                 future: fetchSecondApiData(modifiedKeys),
//                 builder: (context, secondApiSnapshot) {
//                   if (secondApiSnapshot.connectionState == ConnectionState.waiting) {
//                     return Center(child: CircularProgressIndicator());
//                   } else if (secondApiSnapshot.hasError) {
//                     return Center(child: Text('Error: ${secondApiSnapshot.error}'));
//                   } else if (secondApiSnapshot.data == null) {
//                     print('Second API data is null.');
//                     return Center(child: Text('No data available from the second API'));
//                   } else {
//                     List<double> sumsList = [];
//
//                     Map<String, dynamic> filteredData = secondApiSnapshot.data! as Map<String, dynamic>;
//
//                     for (int i = 0; i < filteredData['1st Floor_[kW]'].length; i++) {
//                       double sum = parseDouble(filteredData['1st Floor_[kW]'][i]) +
//                           parseDouble(filteredData['Ground Floor_[kW]'][i]);
//                       sumsList.add(sum);
//                     }
//
//                     double totalSum = calculateTotalSum(sumsList);
//                     double minSum = calculateMin(sumsList);
//                     double maxSum = calculateMax(sumsList);
//                     double avgSum = calculateAverage(sumsList);
//
//                     // Display Total Sum, Min, Max, and Avg on the UI
//                     return Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           Text(
//                             'Total Sum:',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           Text(
//                             'Value: $totalSum',
//                             style: TextStyle(fontSize: 18),
//                           ),
//                           Divider(),
//                           Text(
//                             'Min Sum:',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           Text(
//                             'Value: $minSum',
//                             style: TextStyle(fontSize: 18),
//                           ),
//                           Divider(),
//                           Text(
//                             'Max Sum:',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           Text(
//                             'Value: $maxSum',
//                             style: TextStyle(fontSize: 18),
//                           ),
//                           Divider(),
//                           Text(
//                             'Average Sum:',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           Text(
//                             'Value: $avgSum',
//                             style: TextStyle(fontSize: 18),
//                           ),
//                         ],
//                       ),
//                     );
//                   }
//                 },
//               );
//             }
//           }
//         },
//       ),
//     );
//   }
// }



//
// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
//
// class MyHomePage extends StatefulWidget {
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   final String firstApiUrl = 'http://203.135.63.22:8000/buildingmap?username=ahmad';
//   final String secondApiUrl = 'http://203.135.63.22:8000/data?username=ahmad&mode=hour&start=2024-02-10&end=2024-02-10';
//
//   Future<Map<String, dynamic>> fetchFirstApiData() async {
//     final response = await http.get(Uri.parse(firstApiUrl));
//
//     if (response.statusCode == 200) {
//       return json.decode(response.body);
//     } else {
//       throw Exception('Failed to load data from the first API');
//     }
//   }
//
//   Future<Map<String, dynamic>> fetchSecondApiData(List<String> keys) async {
//     final response = await http.get(Uri.parse(secondApiUrl));
//
//     if (response.statusCode == 200) {
//       Map<String, dynamic> secondApiResponse = json.decode(response.body);
//
//       Map<String, dynamic> filteredData = {};
//       keys.forEach((key) {
//         if (secondApiResponse['data'].containsKey(key)) {
//           filteredData[key] = secondApiResponse['data'][key];
//         }
//       });
//
//       return filteredData;
//     } else {
//       throw Exception('Failed to load data from the second API');
//     }
//   }
//
//   double calculateTotalSum(List<double> sums) {
//     return sums.reduce((total, current) => total + current);
//   }
//
//   double calculateMin(List<double> sums) {
//     return sums.reduce((min, current) => min < current ? min : current);
//   }
//
//   double calculateMax(List<double> sums) {
//     return sums.reduce((max, current) => max > current ? max : current);
//   }
//
//   double calculateAverage(List<double> sums) {
//     if (sums.isEmpty) return 0.0;
//     return sums.reduce((sum, current) => sum + current) / sums.length;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('API Response'),
//       ),
//       body: FutureBuilder(
//         future: fetchFirstApiData(),
//         builder: (context, firstApiSnapshot) {
//           if (firstApiSnapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           } else if (firstApiSnapshot.hasError) {
//             return Center(child: Text('Error: ${firstApiSnapshot.error}'));
//           } else if (firstApiSnapshot.data == null) {
//             return Center(child: Text('No data available from the first API'));
//           } else {
//             Map<String, dynamic> firstApiResponse = firstApiSnapshot.data! as Map<String, dynamic>;
//
//             if (firstApiResponse.containsKey("Main")) {
//               return FutureBuilder(
//                 future: fetchSecondApiData(["Main_[kW]"]),
//                 builder: (context, mainApiSnapshot) {
//                   if (mainApiSnapshot.connectionState == ConnectionState.waiting) {
//                     return Center(child: CircularProgressIndicator());
//                   } else if (mainApiSnapshot.hasError) {
//                     return Center(child: Text('Error: ${mainApiSnapshot.error}'));
//                   } else if (mainApiSnapshot.data == null) {
//                     print('Main API data is null.');
//                     return Center(child: Text('No data available for the Main_[kW] key'));
//                   } else {
//                     List<double> sumsList = [];
//
//                     Map<String, dynamic> mainApiData = mainApiSnapshot.data! as Map<String, dynamic>;
//
//                     for (int i = 0; i < mainApiData["Main_[kW]"].length; i++) {
//                       double sum = (mainApiData["Main_[kW]"][i] ?? 0);
//                       sumsList.add(sum);
//                     }
//
//                     double totalSum = calculateTotalSum(sumsList);
//                     double minSum = calculateMin(sumsList);
//                     double maxSum = calculateMax(sumsList);
//                     double avgSum = calculateAverage(sumsList);
//
//                     // Display Total Sum, Min, Max, and Avg on the UI
//                     return Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           Text(
//                             'Total Sum:',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           Text(
//                             'Value: $totalSum',
//                             style: TextStyle(fontSize: 18),
//                           ),
//                           Divider(),
//                           Text(
//                             'Min Sum:',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           Text(
//                             'Value: $minSum',
//                             style: TextStyle(fontSize: 18),
//                           ),
//                           Divider(),
//                           Text(
//                             'Max Sum:',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           Text(
//                             'Value: $maxSum',
//                             style: TextStyle(fontSize: 18),
//                           ),
//                           Divider(),
//                           Text(
//                             'Average Sum:',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           Text(
//                             'Value: $avgSum',
//                             style: TextStyle(fontSize: 18),
//                           ),
//                         ],
//                       ),
//                     );
//                   }
//                 },
//               );
//             } else {
//               List<String> modifiedKeys = firstApiResponse.keys.map((key) => '$key\_[kW]').toList();
//
//               return FutureBuilder(
//                 future: fetchSecondApiData(modifiedKeys),
//                 builder: (context, secondApiSnapshot) {
//                   if (secondApiSnapshot.connectionState == ConnectionState.waiting) {
//                     return Center(child: CircularProgressIndicator());
//                   } else if (secondApiSnapshot.hasError) {
//                     return Center(child: Text('Error: ${secondApiSnapshot.error}'));
//                   } else if (secondApiSnapshot.data == null) {
//                     print('Second API data is null.');
//                     return Center(child: Text('No data available from the second API'));
//                   } else {
//                     List<double> sumsList = [];
//
//                     Map<String, dynamic> filteredData = secondApiSnapshot.data! as Map<String, dynamic>;
//
//                     for (int i = 0; i < filteredData['1st Floor_[kW]'].length; i++) {
//                       double sum = (filteredData['1st Floor_[kW]'][i] ?? 0) +
//                           (filteredData['Ground Floor_[kW]'][i] ?? 0);
//                       sumsList.add(sum);
//                     }
//
//                     double totalSum = calculateTotalSum(sumsList);
//                     double minSum = calculateMin(sumsList);
//                     double maxSum = calculateMax(sumsList);
//                     double avgSum = calculateAverage(sumsList);
//
//                     // Display Total Sum, Min, Max, and Avg on the UI
//                     return Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           Text(
//                             'Total Sum:',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           Text(
//                             'Value: $totalSum',
//                             style: TextStyle(fontSize: 18),
//                           ),
//                           Divider(),
//                           Text(
//                             'Min Sum:',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           Text(
//                             'Value: $minSum',
//                             style: TextStyle(fontSize: 18),
//                           ),
//                           Divider(),
//                           Text(
//                             'Max Sum:',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           Text(
//                             'Value: $maxSum',
//                             style: TextStyle(fontSize: 18),
//                           ),
//                           Divider(),
//                           Text(
//                             'Average Sum:',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           Text(
//                             'Value: $avgSum',
//                             style: TextStyle(fontSize: 18),
//                           ),
//                         ],
//                       ),
//                     );
//                   }
//                 },
//               );
//             }
//           }
//         },
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
//
// class MyHomePage extends StatefulWidget {
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   final String firstApiUrl = 'http://203.135.63.22:8000/buildingmap?username=ppjiq';
//
//   // Default date range, you can adjust this as needed
//   DateTime? startDate;
//   DateTime? endDate;
//
//   Future<Map<String, dynamic>> fetchFirstApiData() async {
//     final response = await http.get(Uri.parse(firstApiUrl));
//
//     if (response.statusCode == 200) {
//       return json.decode(response.body);
//     } else {
//       throw Exception('Failed to load data from the first API');
//     }
//   }
//
//   Future<Map<String, dynamic>> fetchSecondApiData(List<String> keys) async {
//     // Check if start and end date are selected
//     if (startDate == null || endDate == null) {
//       throw Exception('Please select start and end dates.');
//     }
//
//     // Format the dates as required by your API
//     String formattedStartDate = startDate!.toIso8601String();
//     String formattedEndDate = endDate!.toIso8601String();
//
//     // Update the second API URL with dynamic dates
//     String dynamicSecondApiUrl =
//         'http://203.135.63.22:8000/data?username=ppjiq&mode=hour&start=$formattedStartDate&end=$formattedEndDate';
//
//     final response = await http.get(Uri.parse(dynamicSecondApiUrl));
//
//     if (response.statusCode == 200) {
//       Map<String, dynamic> secondApiResponse = json.decode(response.body);
//
//       Map<String, dynamic> filteredData = {};
//       keys.forEach((key) {
//         if (secondApiResponse['data'].containsKey(key)) {
//           filteredData[key] = secondApiResponse['data'][key];
//         }
//       });
//
//       return filteredData;
//     } else {
//       throw Exception('Failed to load data from the second API');
//     }
//   }
//
//   // Function to show date range picker
//   Future<void> _selectDateRange() async {
//     DateTimeRange? picked = await showDateRangePicker(
//       context: context,
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2101),
//       initialDateRange: DateTimeRange(
//         start: startDate ?? DateTime.now().subtract(Duration(days: 7)),
//         end: endDate ?? DateTime.now(),
//       ),
//     );
//
//     if (picked != null) {
//       setState(() {
//         startDate = picked.start;
//         endDate = picked.end;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('API Response'),
//       ),
//       body: FutureBuilder(
//         future: fetchFirstApiData(),
//         builder: (context, firstApiSnapshot) {
//           if (firstApiSnapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           } else if (firstApiSnapshot.hasError) {
//             return Center(child: Text('Error: ${firstApiSnapshot.error}'));
//           } else if (firstApiSnapshot.data == null) {
//             return Center(child: Text('No data available from the first API'));
//           } else {
//             Map<String, dynamic> firstApiResponse = firstApiSnapshot.data! as Map<String, dynamic>;
//
//             if (firstApiResponse.containsKey("Main")) {
//               return FutureBuilder(
//                 future: fetchSecondApiData(["Main_[kW]"]),
//                 builder: (context, mainApiSnapshot) {
//                   if (mainApiSnapshot.connectionState == ConnectionState.waiting) {
//                     return Center(child: CircularProgressIndicator());
//                   } else if (mainApiSnapshot.hasError) {
//                     return Center(child: Text('Error: ${mainApiSnapshot.error}'));
//                   } else if (mainApiSnapshot.data == null) {
//                     print('Main API data is null.');
//                     return Center(child: Text('No data available for the Main_[kW] key'));
//                   } else {
//                     List<double> sumsList = [];
//
//                     Map<String, dynamic> mainApiData = mainApiSnapshot.data! as Map<String, dynamic>;
//
//                     for (int i = 0; i < mainApiData["Main_[kW]"].length; i++) {
//                       double sum = (mainApiData["Main_[kW]"][i] ?? 0);
//                       sumsList.add(sum);
//                     }
//
//                     double totalSum = calculateTotalSum(sumsList);
//                     double minSum = calculateMin(sumsList);
//                     double maxSum = calculateMax(sumsList);
//                     double avgSum = calculateAverage(sumsList);
//
//                     // Display Total Sum, Min, Max, and Avg on the UI
//                     return Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           Text(
//                             'Total Sum:',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           Text(
//                             'Value: $totalSum',
//                             style: TextStyle(fontSize: 18),
//                           ),
//                           Divider(),
//                           Text(
//                             'Min Sum:',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           Text(
//                             'Value: $minSum',
//                             style: TextStyle(fontSize: 18),
//                           ),
//                           Divider(),
//                           Text(
//                             'Max Sum:',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           Text(
//                             'Value: $maxSum',
//                             style: TextStyle(fontSize: 18),
//                           ),
//                           Divider(),
//                           Text(
//                             'Average Sum:',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           Text(
//                             'Value: $avgSum',
//                             style: TextStyle(fontSize: 18),
//                           ),
//                         ],
//                       ),
//                     );
//                   }
//                 },
//               );
//             } else {
//               List<String> modifiedKeys = firstApiResponse.keys.map((key) => '$key\_[kW]').toList();
//
//               return FutureBuilder(
//                 future: fetchSecondApiData(modifiedKeys),
//                 builder: (context, secondApiSnapshot) {
//                   if (secondApiSnapshot.connectionState == ConnectionState.waiting) {
//                     return Center(child: CircularProgressIndicator());
//                   } else if (secondApiSnapshot.hasError) {
//                     return Center(child: Text('Error: ${secondApiSnapshot.error}'));
//                   } else if (secondApiSnapshot.data == null) {
//                     print('Second API data is null.');
//                     return Center(child: Text('No data available from the second API'));
//                   } else {
//                     List<double> sumsList = [];
//
//                     Map<String, dynamic> filteredData = secondApiSnapshot.data! as Map<String, dynamic>;
//
//                     for (int i = 0; i < filteredData['1st Floor_[kW]'].length; i++) {
//                       double sum = (filteredData['1st Floor_[kW]'][i] ?? 0) +
//                           (filteredData['Ground Floor_[kW]'][i] ?? 0);
//                       sumsList.add(sum);
//                     }
//
//                     double totalSum = calculateTotalSum(sumsList);
//                     double minSum = calculateMin(sumsList);
//                     double maxSum = calculateMax(sumsList);
//                     double avgSum = calculateAverage(sumsList);
//
//                     // Display Total Sum, Min, Max, and Avg on the UI
//                     return Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           Text(
//                             'Total Sum:',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           Text(
//                             'Value: $totalSum',
//                             style: TextStyle(fontSize: 18),
//                           ),
//                           Divider(),
//                           Text(
//                             'Min Sum:',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           Text(
//                             'Value: $minSum',
//                             style: TextStyle(fontSize: 18),
//                           ),
//                           Divider(),
//                           Text(
//                             'Max Sum:',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           Text(
//                             'Value: $maxSum',
//                             style: TextStyle(fontSize: 18),
//                           ),
//                           Divider(),
//                           Text(
//                             'Average Sum:',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           Text(
//                             'Value: $avgSum',
//                             style: TextStyle(fontSize: 18),
//                           ),
//                         ],
//                       ),
//                     );
//                   }
//                 },
//               );
//             }
//           }
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _selectDateRange,
//         tooltip: 'Select Date Range',
//         child: Icon(Icons.calendar_today),
//       ),
//     );
//   }
//
//   double calculateTotalSum(List<double> sums) {
//     return sums.reduce((total, current) => total + current);
//   }
//
//   double calculateMin(List<double> sums) {
//     return sums.reduce((min, current) => min < current ? min : current);
//   }
//
//   double calculateMax(List<double> sums) {
//     return sums.reduce((max, current) => max > current ? max : current);
//   }
//
//   double calculateAverage(List<double> sums) {
//     if (sums.isEmpty) return 0.0;
//     return sums.reduce((sum, current) => sum + current) / sums.length;
//   }
// }



// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
//
// class MyHomePage extends StatefulWidget {
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   final String firstApiUrl =
//       'http://203.135.63.22:8000/buildingmap?username=ppjiq';
//   final String secondApiUrl =
//       'http://203.135.63.22:8000/data?username=ppjiq&mode=hour&start=2023-12-07&end=2023-12-08';
//
//   double calculateMin(List<double> sums) {
//     return sums.reduce((min, current) => min < current ? min : current);
//   }
//
//   double calculateMax(List<double> sums) {
//     return sums.reduce((max, current) => max > current ? max : current);
//   }
//
//   double calculateAverage(List<double> sums) {
//     if (sums.isEmpty) return 0.0;
//     return sums.reduce((sum, current) => sum + current) / sums.length;
//   }
//   double calculateTotalSum(List<double> sums) {
//     if (sums.isEmpty) return 0.0;
//     return sums.reduce((sum, current) => sum + current);
//   }
//
//   Future<Map<String, dynamic>> fetchFirstApiData() async {
//     final response = await http.get(Uri.parse(firstApiUrl));
//
//     if (response.statusCode == 200) {
//       return json.decode(response.body);
//     } else {
//       throw Exception('Failed to load data from the first API');
//     }
//   }
//
//   Future<Map<String, dynamic>> fetchSecondApiData(List<String> keys) async {
//     final response = await http.get(Uri.parse(secondApiUrl));
//
//     if (response.statusCode == 200) {
//       Map<String, dynamic> secondApiResponse = json.decode(response.body);
//
//       Map<String, dynamic> filteredData = {};
//       keys.forEach((key) {
//         if (secondApiResponse['data'].containsKey(key)) {
//           filteredData[key] = secondApiResponse['data'][key];
//         }
//       });
//
//       return filteredData;
//     } else {
//       throw Exception('Failed to load data from the second API');
//     }
//   }
//
//   Map<String, double> calculateSum(Map<String, dynamic> filteredData) {
//     Map<String, double> sumMap = {};
//
//     filteredData.forEach((key, values) {
//       if (values is List<double?>) {
//         for (int i = 0; i < values.length; i++) {
//           if (values[i] != null) {
//             if (!sumMap.containsKey('Sum $i')) {
//               sumMap['Sum $i'] = values[i]!;
//             } else {
//               sumMap['Sum $i'] = sumMap['Sum $i']! + values[i]!;
//             }
//           }
//         }
//       }
//     });
//
//     return sumMap;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('API Response'),
//       ),
//       body: FutureBuilder(
//         future: fetchFirstApiData(),
//         builder: (context, firstApiSnapshot) {
//           if (firstApiSnapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           } else if (firstApiSnapshot.hasError) {
//             return Center(child: Text('Error: ${firstApiSnapshot.error}'));
//           } else if (firstApiSnapshot.data == null) {
//             return Center(child: Text('No data available from the first API'));
//           } else {
//             Map<String, dynamic> firstApiResponse =
//             firstApiSnapshot.data! as Map<String, dynamic>;
//
//             if (firstApiResponse.containsKey("Main")) {
//               return FutureBuilder(
//                 future: fetchSecondApiData(["Main_[kW]"]),
//                 builder: (context, mainApiSnapshot) {
//                   if (mainApiSnapshot.connectionState ==
//                       ConnectionState.waiting) {
//                     return Center(child: CircularProgressIndicator());
//                   } else if (mainApiSnapshot.hasError) {
//                     return Center(
//                         child: Text('Error: ${mainApiSnapshot.error}'));
//                   } else if (mainApiSnapshot.data == null) {
//                     print('Main API data is null.');
//                     return Center(
//                         child:
//                         Text('No data available for the Main_[kW] key'));
//                   } else {
//                     List<Widget> responseWidgets = [];
//
//                     Map<String, dynamic> mainApiData =
//                     mainApiSnapshot.data! as Map<String, dynamic>;
//
//                     responseWidgets.add(
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Key: Main_[kW]',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           if (mainApiData.containsKey("Main_[kW]"))
//                             for (var value in mainApiData["Main_[kW]"])
//                               Text('Value: $value'),
//                           Divider(),
//                         ],
//                       ),
//                     );
//
//                     List<double> sumsList = [];
//
//                     for (int i = 0; i < mainApiData["Main_[kW]"].length; i++) {
//                       double sum = (mainApiData["Main_[kW]"][i] ?? 0);
//                       sumsList.add(sum);
//
//                       responseWidgets.add(
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Sum $i',
//                               style: TextStyle(fontWeight: FontWeight.bold),
//                             ),
//                             Text('Value: $sum'),
//                             Divider(),
//                           ],
//                         ),
//                       );
//
//                       print('Sum $i: $sum');
//                     }
//
//                     Map<String, double> sumMap = calculateSum(mainApiData);
//
//                     for (int i = 0; i < mainApiData["Main_[kW]"].length; i++) {
//                       double sum = sumMap['Sum $i'] ?? 0;
//
//                       responseWidgets.add(
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Sum $i',
//                               style: TextStyle(fontWeight: FontWeight.bold),
//                             ),
//                             Text('Value: $sum'),
//                             Divider(),
//                           ],
//                         ),
//                       );
//
//                       print('Sum $i: $sum');
//                     }
//
//                     double minSum = calculateMin(sumsList);
//                     double maxSum = calculateMax(sumsList);
//                     double avgSum = calculateAverage(sumsList);
//
//                     responseWidgets.add(
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Min Sum:',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           Text('Value: $minSum'),
//                           Divider(),
//                           Text(
//                             'Max Sum:',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           Text('Value: $maxSum'),
//                           Divider(),
//                           Text(
//                             'Average Sum:',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           Text('Value: $avgSum'),
//                         ],
//                       ),
//                     );
//
//                     return ListView(
//                       padding: EdgeInsets.all(16.0),
//                       children: responseWidgets,
//                     );
//                   }
//                 },
//               );
//             } else {
//               List<String> modifiedKeys = firstApiResponse.keys
//                   .map((key) => '$key\_[kW]')
//                   .toList();
//
//               return FutureBuilder(
//                 future: fetchSecondApiData(modifiedKeys),
//                 builder: (context, secondApiSnapshot) {
//                   if (secondApiSnapshot.connectionState ==
//                       ConnectionState.waiting) {
//                     return Center(child: CircularProgressIndicator());
//                   } else if (secondApiSnapshot.hasError) {
//                     return Center(
//                         child: Text('Error: ${secondApiSnapshot.error}'));
//                   } else if (secondApiSnapshot.data == null) {
//                     print('Second API data is null.');
//                     return Center(
//                         child:
//                         Text('No data available from the second API'));
//                   } else {
//                     Map<String, dynamic> filteredData =
//                     secondApiSnapshot.data! as Map<String, dynamic>;
//
//                     List<Widget> responseWidgets = [];
//
//                     filteredData.forEach((key, values) {
//                       print('Key: $key, Values: $values');
//                       responseWidgets.add(
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Key: $key',
//                               style: TextStyle(fontWeight: FontWeight.bold),
//                             ),
//                             if (values is List)
//                               for (int i = 0; i < values.length; i++)
//                                 Text('Value ${i + 1}: ${values[i]}'),
//                             Divider(),
//                           ],
//                         ),
//                       );
//                     });
//
//                     List<double> sumsList = [];
//
//                     for (int i = 0;
//                     i < filteredData['1st Floor_[kW]'].length;
//                     i++) {
//                       double sum = (filteredData['1st Floor_[kW]'][i] ?? 0) +
//                           (filteredData['Ground Floor_[kW]'][i] ?? 0);
//                       sumsList.add(sum);
//
//                       responseWidgets.add(
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Sum $i',
//                               style: TextStyle(fontWeight: FontWeight.bold),
//                             ),
//                             Text('Value: $sum'),
//                             Divider(),
//                           ],
//                         ),
//                       );
//
//                       print('Sum $i: $sum');
//                     }
//
//                     Map<String, double> sumMap = calculateSum(filteredData);
//
//                     for (int i = 0;
//                     i < filteredData['1st Floor_[kW]'].length;
//                     i++) {
//                       double sum = sumMap['Sum $i'] ?? 0;
//
//                       responseWidgets.add(
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Sum $i',
//                               style: TextStyle(fontWeight: FontWeight.bold),
//                             ),
//                             Text('Value: $sum'),
//                             Divider(),
//                           ],
//                         ),
//                       );
//
//                       print('Sum $i: $sum');
//                     }
//
//                     double minSum = calculateMin(sumsList);
//                     double maxSum = calculateMax(sumsList);
//                     double avgSum = calculateAverage(sumsList);
//                     double Sum = calculateTotalSum(sumsList);
//
//
//                     responseWidgets.add(
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Min Sum:',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           Text('Value: $minSum'),
//                           Divider(),
//                           Text(
//                             'Max Sum:',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           Text('Value: $maxSum'),
//                           Divider(),
//                           Text(
//                             'Average Sum:',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           Text('Value: $avgSum'),
//                           Text(
//                             ' Total',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           Divider(),
//
//                           // Text('Value: $Sum'),
//
//                         ],
//                       ),
//                     );
//
//                     return ListView(
//                       padding: EdgeInsets.all(16.0),
//                       children: responseWidgets,
//                     );
//                   }
//                 },
//               );
//             }
//           }
//         },
//       ),
//     );
//   }
// }
//done for min max and avg
// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
//
// class MyHomePage extends StatefulWidget {
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   final String firstApiUrl =
//       'http://203.135.63.22:8000/buildingmap?username=ahmad';
//   final String secondApiUrl =
//       'http://203.135.63.22:8000/data?username=ahmad&mode=hour&start=2023-12-07&end=2023-12-07';
//
//   double calculateMin(List<double> sums) {
//     return sums.reduce((min, current) => min < current ? min : current);
//   }
//
//   double calculateMax(List<double> sums) {
//     return sums.reduce((max, current) => max > current ? max : current);
//   }
//
//   double calculateAverage(List<double> sums) {
//     if (sums.isEmpty) return 0.0;
//     return sums.reduce((sum, current) => sum + current) / sums.length;
//   }
//
//   Future<Map<String, dynamic>> fetchFirstApiData() async {
//     final response = await http.get(Uri.parse(firstApiUrl));
//
//     if (response.statusCode == 200) {
//       return json.decode(response.body);
//     } else {
//       throw Exception('Failed to load data from the first API');
//     }
//   }
//
//   Future<Map<String, dynamic>> fetchSecondApiData(List<String> keys) async {
//     final response = await http.get(Uri.parse(secondApiUrl));
//
//     if (response.statusCode == 200) {
//       Map<String, dynamic> secondApiResponse = json.decode(response.body);
//
//       Map<String, dynamic> filteredData = {};
//       keys.forEach((key) {
//         if (secondApiResponse['data'].containsKey(key)) {
//           filteredData[key] = secondApiResponse['data'][key];
//         }
//       });
//
//       return filteredData;
//     } else {
//       throw Exception('Failed to load data from the second API');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('API Response'),
//       ),
//       body: FutureBuilder(
//         future: fetchFirstApiData(),
//         builder: (context, firstApiSnapshot) {
//           if (firstApiSnapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           } else if (firstApiSnapshot.hasError) {
//             return Center(child: Text('Error: ${firstApiSnapshot.error}'));
//           } else if (firstApiSnapshot.data == null) {
//             return Center(child: Text('No data available from the first API'));
//           } else {
//             Map<String, dynamic> firstApiResponse =
//             firstApiSnapshot.data! as Map<String, dynamic>;
//
//             if (firstApiResponse.containsKey("Main")) {
//               return FutureBuilder(
//                 future: fetchSecondApiData(["Main_[kW]"]),
//                 builder: (context, mainApiSnapshot) {
//                   if (mainApiSnapshot.connectionState ==
//                       ConnectionState.waiting) {
//                     return Center(child: CircularProgressIndicator());
//                   } else if (mainApiSnapshot.hasError) {
//                     return Center(
//                         child: Text('Error: ${mainApiSnapshot.error}'));
//                   } else if (mainApiSnapshot.data == null) {
//                     print('Main API data is null.');
//                     return Center(
//                         child:
//                         Text('No data available for the Main_[kW] key'));
//                   } else {
//                     List<Widget> responseWidgets = [];
//
//                     Map<String, dynamic> mainApiData =
//                     mainApiSnapshot.data! as Map<String, dynamic>;
//
//                     List<double> sumsList = [];
//
//                     for (int i = 0; i < mainApiData["Main_[kW]"].length; i++) {
//                       double sum = (mainApiData["Main_[kW]"][i] ?? 0);
//                       sumsList.add(sum);
//                     }
//
//                     double minSum = calculateMin(sumsList);
//                     double maxSum = calculateMax(sumsList);
//                     double avgSum = calculateAverage(sumsList);
//
//                     responseWidgets.add(
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Min Sum:',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           Text('Value: $minSum'),
//                           Divider(),
//                           Text(
//                             'Max Sum:',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           Text('Value: $maxSum'),
//                           Divider(),
//                           Text(
//                             'Average Sum:',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           Text('Value: $avgSum'),
//                         ],
//                       ),
//                     );
//
//                     return ListView(
//                       padding: EdgeInsets.all(16.0),
//                       children: responseWidgets,
//                     );
//                   }
//                 },
//               );
//             } else {
//               List<String> modifiedKeys = firstApiResponse.keys
//                   .map((key) => '$key\_[kW]')
//                   .toList();
//
//               return FutureBuilder(
//                 future: fetchSecondApiData(modifiedKeys),
//                 builder: (context, secondApiSnapshot) {
//                   if (secondApiSnapshot.connectionState ==
//                       ConnectionState.waiting) {
//                     return Center(child: CircularProgressIndicator());
//                   } else if (secondApiSnapshot.hasError) {
//                     return Center(
//                         child: Text('Error: ${secondApiSnapshot.error}'));
//                   } else if (secondApiSnapshot.data == null) {
//                     print('Second API data is null.');
//                     return Center(
//                         child:
//                         Text('No data available from the second API'));
//                   } else {
//                     Map<String, dynamic> filteredData =
//                     secondApiSnapshot.data! as Map<String, dynamic>;
//
//                     List<Widget> responseWidgets = [];
//
//                     List<double> sumsList = [];
//
//                     for (int i = 0;
//                     i < filteredData['1st Floor_[kW]'].length;
//                     i++) {
//                       double sum =
//                           (filteredData['1st Floor_[kW]'][i] ?? 0) +
//                               (filteredData['Ground Floor_[kW]'][i] ?? 0);
//                       sumsList.add(sum);
//                     }
//
//                     double minSum = calculateMin(sumsList);
//                     double maxSum = calculateMax(sumsList);
//                     double avgSum = calculateAverage(sumsList);
//
//                     responseWidgets.add(
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Min Value:',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           Text('Value: $minSum'),
//                           Divider(),
//                           Text(
//                             'Max Value:',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           Text('Value: $maxSum'),
//                           Divider(),
//                           Text(
//                             'Average Value:',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           Text('Value: $avgSum'),
//                         ],
//                       ),
//                     );
//
//                     return ListView(
//                       padding: EdgeInsets.all(16.0),
//                       children: responseWidgets,
//                     );
//                   }
//                 },
//               );
//             }
//           }
//         },
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
//
// class MyHomePage extends StatefulWidget {
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   final String firstApiUrl =
//       'http://203.135.63.22:8000/buildingmap?username=ppjiq';
//   final String secondApiUrl =
//       'http://203.135.63.22:8000/data?username=ppjiq&mode=hour&start=2023-12-07&end=2023-12-07';
//
//   double calculateMin(List<double> sums) {
//     return sums.reduce((min, current) => min < current ? min : current);
//   }
//
//   double calculateMax(List<double> sums) {
//     return sums.reduce((max, current) => max > current ? max : current);
//   }
//
//   double calculateAverage(List<double> sums) {
//     if (sums.isEmpty) return 0.0;
//     return sums.reduce((sum, current) => sum + current) / sums.length;
//   }
//
//   Future<Map<String, dynamic>> fetchFirstApiData() async {
//     final response = await http.get(Uri.parse(firstApiUrl));
//
//     if (response.statusCode == 200) {
//       return json.decode(response.body);
//     } else {
//       throw Exception('Failed to load data from the first API');
//     }
//   }
//
//   Future<Map<String, dynamic>> fetchSecondApiData(List<String> keys) async {
//     final response = await http.get(Uri.parse(secondApiUrl));
//
//     if (response.statusCode == 200) {
//       Map<String, dynamic> secondApiResponse = json.decode(response.body);
//
//       Map<String, dynamic> filteredData = {};
//       keys.forEach((key) {
//         if (secondApiResponse['data'].containsKey(key)) {
//           filteredData[key] = secondApiResponse['data'][key];
//         }
//       });
//
//       return filteredData;
//     } else {
//       throw Exception('Failed to load data from the second API');
//     }
//   }
//
//   Map<String, double> calculateSum(Map<String, dynamic> filteredData) {
//     Map<String, double> sumMap = {};
//
//     filteredData.forEach((key, values) {
//       if (values is List<double?>) {
//         for (int i = 0; i < values.length; i++) {
//           if (values[i] != null) {
//             if (!sumMap.containsKey('Sum $i')) {
//               sumMap['Sum $i'] = values[i]!;
//             } else {
//               sumMap['Sum $i'] = sumMap['Sum $i']! + values[i]!;
//             }
//           }
//         }
//       }
//     });
//
//     return sumMap;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('API Response'),
//       ),
//       body: FutureBuilder(
//         future: fetchFirstApiData(),
//         builder: (context, firstApiSnapshot) {
//           if (firstApiSnapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           } else if (firstApiSnapshot.hasError) {
//             return Center(child: Text('Error: ${firstApiSnapshot.error}'));
//           } else if (firstApiSnapshot.data == null) {
//             return Center(child: Text('No data available from the first API'));
//           } else {
//             Map<String, dynamic> firstApiResponse =
//             firstApiSnapshot.data! as Map<String, dynamic>;
//
//             if (firstApiResponse.containsKey("Main")) {
//               return FutureBuilder(
//                 future: fetchSecondApiData(["Main_[kW]"]),
//                 builder: (context, mainApiSnapshot) {
//                   if (mainApiSnapshot.connectionState ==
//                       ConnectionState.waiting) {
//                     return Center(child: CircularProgressIndicator());
//                   } else if (mainApiSnapshot.hasError) {
//                     return Center(
//                         child: Text('Error: ${mainApiSnapshot.error}'));
//                   } else if (mainApiSnapshot.data == null) {
//                     print('Main API data is null.');
//                     return Center(
//                         child:
//                         Text('No data available for the Main_[kW] key'));
//                   } else {
//                     List<Widget> responseWidgets = [];
//
//                     Map<String, dynamic> mainApiData =
//                     mainApiSnapshot.data! as Map<String, dynamic>;
//
//                     responseWidgets.add(
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Key: Main_[kW]',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           if (mainApiData.containsKey("Main_[kW]"))
//                             for (var value in mainApiData["Main_[kW]"])
//                               Text('Value: $value'),
//                           Divider(),
//                         ],
//                       ),
//                     );
//
//                     List<double> sumsList = [];
//
//                     for (int i = 0; i < mainApiData["Main_[kW]"].length; i++) {
//                       double sum = (mainApiData["Main_[kW]"][i] ?? 0);
//                       sumsList.add(sum);
//
//                       responseWidgets.add(
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Sum $i',
//                               style: TextStyle(fontWeight: FontWeight.bold),
//                             ),
//                             Text('Value: $sum'),
//                             Divider(),
//                           ],
//                         ),
//                       );
//
//                       print('Sum $i: $sum');
//                     }
//
//                     Map<String, double> sumMap = calculateSum(mainApiData);
//
//                     for (int i = 0; i < mainApiData["Main_[kW]"].length; i++) {
//                       double sum = sumMap['Sum $i'] ?? 0;
//
//                       responseWidgets.add(
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Sum $i',
//                               style: TextStyle(fontWeight: FontWeight.bold),
//                             ),
//                             Text('Value: $sum'),
//                             Divider(),
//                           ],
//                         ),
//                       );
//
//                       print('Sum $i: $sum');
//                     }
//
//                     double minSum = calculateMin(sumsList);
//                     double maxSum = calculateMax(sumsList);
//                     double avgSum = calculateAverage(sumsList);
//
//                     responseWidgets.add(
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Min Sum:',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           Text('Value: $minSum'),
//                           Divider(),
//                           Text(
//                             'Max Sum:',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           Text('Value: $maxSum'),
//                           Divider(),
//                           Text(
//                             'Average Sum:',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           Text('Value: $avgSum'),
//                         ],
//                       ),
//                     );
//
//                     return ListView(
//                       padding: EdgeInsets.all(16.0),
//                       children: responseWidgets,
//                     );
//                   }
//                 },
//               );
//             } else {
//               List<String> modifiedKeys = firstApiResponse.keys
//                   .map((key) => '$key\_[kW]')
//                   .toList();
//
//               return FutureBuilder(
//                 future: fetchSecondApiData(modifiedKeys),
//                 builder: (context, secondApiSnapshot) {
//                   if (secondApiSnapshot.connectionState ==
//                       ConnectionState.waiting) {
//                     return Center(child: CircularProgressIndicator());
//                   } else if (secondApiSnapshot.hasError) {
//                     return Center(
//                         child: Text('Error: ${secondApiSnapshot.error}'));
//                   } else if (secondApiSnapshot.data == null) {
//                     print('Second API data is null.');
//                     return Center(
//                         child:
//                         Text('No data available from the second API'));
//                   } else {
//                     Map<String, dynamic> filteredData =
//                     secondApiSnapshot.data! as Map<String, dynamic>;
//
//                     List<Widget> responseWidgets = [];
//
//                     filteredData.forEach((key, values) {
//                       print('Key: $key, Values: $values');
//                       responseWidgets.add(
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Key: $key',
//                               style: TextStyle(fontWeight: FontWeight.bold),
//                             ),
//                             if (values is List)
//                               for (int i = 0; i < values.length; i++)
//                                 Text('Value ${i + 1}: ${values[i]}'),
//                             Divider(),
//                           ],
//                         ),
//                       );
//                     });
//
//                     List<double> sumsList = [];
//
//                     for (int i = 0;
//                     i < filteredData['1st Floor_[kW]'].length;
//                     i++) {
//                       double sum = (filteredData['1st Floor_[kW]'][i] ?? 0) +
//                           (filteredData['Ground Floor_[kW]'][i] ?? 0);
//                       sumsList.add(sum);
//
//                       responseWidgets.add(
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Sum $i',
//                               style: TextStyle(fontWeight: FontWeight.bold),
//                             ),
//                             Text('Value: $sum'),
//                             Divider(),
//                           ],
//                         ),
//                       );
//
//                       print('Sum $i: $sum');
//                     }
//
//                     Map<String, double> sumMap = calculateSum(filteredData);
//
//                     for (int i = 0;
//                     i < filteredData['1st Floor_[kW]'].length;
//                     i++) {
//                       double sum = sumMap['Sum $i'] ?? 0;
//
//                       responseWidgets.add(
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Sum $i',
//                               style: TextStyle(fontWeight: FontWeight.bold),
//                             ),
//                             Text('Value: $sum'),
//                             Divider(),
//                           ],
//                         ),
//                       );
//
//                       print('Sum $i: $sum');
//                     }
//
//                     double minSum = calculateMin(sumsList);
//                     double maxSum = calculateMax(sumsList);
//                     double avgSum = calculateAverage(sumsList);
//
//                     responseWidgets.add(
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Min Sum:',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           Text('Value: $minSum'),
//                           Divider(),
//                           Text(
//                             'Max Sum:',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           Text('Value: $maxSum'),
//                           Divider(),
//                           Text(
//                             'Average Sum:',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           Text('Value: $avgSum'),
//                         ],
//                       ),
//                     );
//
//                     return ListView(
//                       padding: EdgeInsets.all(16.0),
//                       children: responseWidgets,
//                     );
//                   }
//                 },
//               );
//             }
//           }
//         },
//       ),
//     );
//   }
// }





// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
//
// class MyHomePage extends StatefulWidget {
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   final String firstApiUrl =
//       'http://203.135.63.22:8000/buildingmap?username=ppjiq';
//   final String secondApiUrl =
//       'http://203.135.63.22:8000/data?username=ppjiq&mode=hour&start=2023-12-07&end=2023-12-07';
//
//   Future<Map<String, dynamic>> fetchFirstApiData() async {
//     final response = await http.get(Uri.parse(firstApiUrl));
//
//     if (response.statusCode == 200) {
//       return json.decode(response.body);
//     } else {
//       throw Exception('Failed to load data from the first API');
//     }
//   }
//
//   Future<Map<String, dynamic>> fetchSecondApiData(List<String> keys) async {
//     final response = await http.get(Uri.parse(secondApiUrl));
//
//     if (response.statusCode == 200) {
//       Map<String, dynamic> secondApiResponse = json.decode(response.body);
//
//       // Filter out values using the modified keys obtained from the first API
//       Map<String, dynamic> filteredData = {};
//       keys.forEach((key) {
//         if (secondApiResponse['data'].containsKey(key)) {
//           filteredData[key] = secondApiResponse['data'][key];
//         }
//       });
//
//       return filteredData;
//     } else {
//       throw Exception('Failed to load data from the second API');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('API Response'),
//       ),
//       body: FutureBuilder(
//         future: fetchFirstApiData(),
//         builder: (context, firstApiSnapshot) {
//           if (firstApiSnapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           } else if (firstApiSnapshot.hasError) {
//             return Center(child: Text('Error: ${firstApiSnapshot.error}'));
//           } else if (firstApiSnapshot.data == null) {
//             return Center(child: Text('No data available from the first API'));
//           } else {
//             // Explicitly cast to Map<String, dynamic>
//             Map<String, dynamic> firstApiResponse =
//             firstApiSnapshot.data! as Map<String, dynamic>;
//             List<String> modifiedKeys =
//             firstApiResponse.keys.map((key) => '$key\_[kW]').toList();
//
//             return FutureBuilder(
//               future: fetchSecondApiData(modifiedKeys),
//               builder: (context, secondApiSnapshot) {
//                 if (secondApiSnapshot.connectionState ==
//                     ConnectionState.waiting) {
//                   return Center(child: CircularProgressIndicator());
//                 } else if (secondApiSnapshot.hasError) {
//                   return Center(
//                       child: Text('Error: ${secondApiSnapshot.error}'));
//                 } else if (secondApiSnapshot.data == null) {
//                   print('Second API data is null.');
//                   return Center(
//                       child: Text('No data available from the second API'));
//                 } else {
//                   // Explicitly cast to Map<String, dynamic>
//                   Map<String, dynamic> filteredData =
//                   secondApiSnapshot.data! as Map<String, dynamic>;
//
//                   // Display filtered data in the UI
//                   List<Widget> responseWidgets = [];
//
//                   filteredData.forEach((key, values) {
//                     print('Key: $key, Values: $values');
//                     responseWidgets.add(
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Key: $key',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           if (values is List)
//                             for (int i = 0; i < values.length; i++)
//                               Text('Value ${i + 1}: ${values[i]}'),
//                           Divider(), // Add a divider for separation
//                         ],
//                       ),
//                     );
//                   });
//
//                   return ListView(
//                     padding: EdgeInsets.all(16.0),
//                     children: responseWidgets,
//                   );
//                 }
//               },
//             );
//           }
//         },
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
//
// class MyHomePage extends StatefulWidget {
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   final String apiUrl = 'http://203.135.63.22:8000/buildingmap?username=ahmad';
//
//   Future<Map<String, dynamic>> fetchData() async {
//     final response = await http.get(Uri.parse(apiUrl));
//
//     if (response.statusCode == 200) {
//       return json.decode(response.body);
//     } else {
//       throw Exception('Failed to load data');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('API Response'),
//       ),
//       body: FutureBuilder(
//         future: fetchData(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else if (snapshot.data == null) {
//             return Center(child: Text('No data available'));
//           } else {
//             // Explicitly cast snapshot.data to Map<String, dynamic>
//             Map<String, dynamic> responseData =
//                 snapshot.data! as Map<String, dynamic>;
//
//             // Check if "Main" key exists
//             if (responseData.containsKey("Main")) {
//               // Display only "Main" key with the added "_[kW]" suffix
//               return Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Key: Main_[kW]',
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   Divider(), // Add a divider for separation
//                 ],
//               );
//             } else {
//               // Display other keys with the added "_[kW]" suffix
//               List<String> otherKeysWithSuffix =
//                   responseData.keys.map((key) => '$key\_[kW]').toList();
//
//               // Convert the list of key names into a list of widgets
//               List<Widget> responseWidgets = [];
//
//               for (String key in otherKeysWithSuffix) {
//                 responseWidgets.add(
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         '$key',
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                       Divider(), // Add a divider for separation
//                     ],
//                   ),
//                 );
//               }
//
//               return ListView(
//                 padding: EdgeInsets.all(16.0),
//                 children: responseWidgets,
//               );
//             }
//           }
//         },
//       ),
//     );
//   }
// }
//
//
//
//
//
//
//
// // import 'dart:convert';
// // import 'package:flutter/material.dart';
// // import 'package:http/http.dart' as http;
// //
// // class MyHomePagess extends StatefulWidget {
// //   @override
// //   _MyHomePagessState createState() => _MyHomePagessState();
// // }
// //
// // class _MyHomePagessState extends State<MyHomePagess> {
// //   List<String> result = [];
// //   String startDate = '2023-12-07';
// //   String endDate = '2023-12-07';
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     fetchData();
// //   }
// //
// //   Future<void> fetchData() async {
// //     String appUrl='http://203.135.63.22:8000/data?username=ahmad&mode=hour&start=$startDate&end=$endDate';
// //     print(appUrl);
// //     final response = await http.get(Uri.parse(
// //         appUrl));
// //
// //
// //     if (response.statusCode == 200) {
// //       Map<String, dynamic> jsonData = json.decode(response.body);
// //       processData(jsonData['data']);
// //     } else {
// //       print('Failed to load data');
// //     }
// //   }
// //
// //   void processData(Map<String, dynamic> jsonData) {
// //     if (jsonData.containsKey("Main_[kW]")) {
// //       showMainKwValues(jsonData["Main_[kW]"]);
// //     } else {
// //       showOtherKwValues(jsonData);
// //     }
// //   }
// //
// //   void showMainKwValues(List<dynamic> mainKwValues) {
// //     if (mainKwValues is List && mainKwValues.isNotEmpty) {
// //       List<double> numericValues = mainKwValues
// //           .where((value) => value is num || value is String && double.tryParse(value) != null)
// //           .map((value) => value is num ? value.toDouble() : double.parse(value))
// //           .toList();
// //
// //       if (numericValues.isNotEmpty) {
// //         double minValue = numericValues.reduce((value, element) => value < element ? value : element);
// //         double maxValue = numericValues.reduce((value, element) => value > element ? value : element);
// //         double averageValue = numericValues.reduce((a, b) => a + b) / numericValues.length;
// //
// //         result = [
// //           'Main_[kW] Min Value: $minValue',
// //           'Main_[kW] Max Value: $maxValue',
// //           'Main_[kW] Average Value: $averageValue',
// //         ];
// //       } else {
// //         result = ['No matching keys found.'];
// //       }
// //     } else {
// //       result = ['No matching keys found.'];
// //     }
// //
// //     setState(() {}); // Trigger a rebuild to update the UI
// //   }
// //
// //
// //   void showOtherKwValues(Map<String, dynamic> jsonData) {
// //     Map<String, double> sumValuesMap = {};
// //
// //     jsonData.forEach((key, value) {
// //       if (key.endsWith("[kW]") && value is List) {
// //         double sum = 0;
// //
// //         for (var item in value) {
// //           if (item is num) {
// //             sum += item.toDouble();
// //           }
// //         }
// //
// //         sumValuesMap[key] = sum;
// //       }
// //     });
// //
// //     if (sumValuesMap.isNotEmpty) {
// //       result = sumValuesMap.entries
// //           .map((entry) => '${entry.key}: Sum = ${entry.value}')
// //           .toList();
// //     } else {
// //       result = ['No matching keys found.'];
// //     }
// //
// //     setState(() {}); // Trigger a rebuild to update the UI
// //   }
// //
// //   Future<void> _selectStartDate(BuildContext context) async {
// //     DateTime? picked = await showDatePicker(
// //       context: context,
// //       initialDate: DateTime.now(),
// //       firstDate: DateTime(2023),
// //       lastDate: DateTime(2025),
// //     );
// //     if (picked != null) setState(() => startDate = picked.toLocal().toString().split(' ')[0]);
// //   }
// //
// //   Future<void> _selectEndDate(BuildContext context) async {
// //     DateTime? picked = await showDatePicker(
// //       context: context,
// //       initialDate: DateTime.now(),
// //       firstDate: DateTime(2023),
// //       lastDate: DateTime(2025),
// //     );
// //     if (picked != null) setState(() => endDate = picked.toLocal().toString().split(' ')[0]);
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text('Key Value Display'),
// //       ),
// //       body: Padding(
// //         padding: const EdgeInsets.all(16.0),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Row(
// //               children: [
// //                 Text('Start Date: $startDate'),
// //                 IconButton(
// //                   icon: Icon(Icons.calendar_today),
// //                   onPressed: () => _selectStartDate(context),
// //                 ),
// //               ],
// //             ),
// //             Row(
// //               children: [
// //                 Text('End Date: $endDate'),
// //                 IconButton(
// //                   icon: Icon(Icons.calendar_today),
// //                   onPressed: () => _selectEndDate(context),
// //                 ),
// //               ],
// //             ),
// //             SizedBox(height: 16),
// //             ElevatedButton(
// //               onPressed: fetchData,
// //               child: Text('Fetch Data'),
// //             ),
// //             SizedBox(height: 16),
// //             if (result.isNotEmpty)
// //               Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: result.map((value) => Text(value)).toList(),
// //               )
// //             else
// //               Center(
// //                 child: Text('No matching keys found.'),
// //               ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
//
//
//
//
// // import 'dart:convert';
// // import 'package:flutter/material.dart';
// // import 'package:http/http.dart' as http;
// //
// // class MyHomePagess extends StatefulWidget {
// //   @override
// //   _MyHomePagessState createState() => _MyHomePagessState();
// // }
// //
// // class _MyHomePagessState extends State<MyHomePagess> {
// //   List<String> result = [];
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     fetchData();
// //   }
// //
// //   Future<void> fetchData() async {
// //     final response = await http.get(Uri.parse(
// //         'http://203.135.63.22:8000/data?username=ppjiq&mode=hour&start=2023-12-07&end=2023-12-26'));
// //
// //     if (response.statusCode == 200) {
// //       Map<String, dynamic> jsonData = json.decode(response.body);
// //       processData(jsonData['data']);
// //     } else {
// //       print('Failed to load data');
// //     }
// //   }
// //
// //   void processData(Map<String, dynamic> jsonData) {
// //     List<double> mainKwValues = [];
// //
// //     if (jsonData.containsKey("Main_[kW]")) {
// //       mainKwValues = (jsonData["Main_[kW]"] as List<dynamic>).map((value) {
// //         if (value is num) {
// //           return value.toDouble();
// //         }
// //         return 0.0; // Default value if the item is not a number
// //       }).toList();
// //     }
// //
// //     if (mainKwValues.isNotEmpty) {
// //       double maxValue = mainKwValues.reduce((value, element) => value > element ? value : element);
// //       double minValue = mainKwValues.reduce((value, element) => value < element ? value : element);
// //       double averageValue = mainKwValues.isNotEmpty ? mainKwValues.reduce((a, b) => a + b) / mainKwValues.length : 0;
// //
// //       result = [
// //         'Main_[kW] Max Value: $maxValue',
// //         'Main_[kW] Min Value: $minValue',
// //         'Main_[kW] Average Value: $averageValue',
// //       ];
// //     } else {
// //       result = ['No matching keys found.'];
// //     }
// //
// //     setState(() {}); // Trigger a rebuild to update the UI
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text('Key Value Display'),
// //       ),
// //       body: Padding(
// //         padding: const EdgeInsets.all(16.0),
// //         child: result.isNotEmpty
// //             ? Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: result
// //               .map((value) => Text(value))
// //               .toList(),
// //         )
// //             : Center(
// //           child: Text('No matching keys found.'),
// //         ),
// //       ),
// //     );
// //   }
// // }
//
//
//
//
//
//
//
//
// // import 'dart:convert';
// // import 'package:flutter/material.dart';
// // import 'package:http/http.dart' as http;
// //
// //
// // class MyHomePagess extends StatefulWidget {
// //   @override
// //   _MyHomePagessState createState() => _MyHomePagessState();
// // }
// //
// // class _MyHomePagessState extends State<MyHomePagess> {
// //   List<String> result = [];
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     fetchData();
// //   }
// //
// //   Future<void> fetchData() async {
// //     final response = await http.get(Uri.parse(
// //         'http://203.135.63.22:8000/data?username=ppjiq&mode=hour&start=2023-12-07&end=2023-12-07'));
// //
// //     if (response.statusCode == 200) {
// //       Map<String, dynamic> jsonData = json.decode(response.body);
// //       processData(jsonData);
// //     } else {
// //       print('Failed to load data');
// //     }
// //   }
// //
// //   void processData(Map<String, dynamic> jsonData) {
// //     jsonData['data'].forEach((key, value) {
// //       if (key.endsWith("[kW]")) {
// //         var lastValue = value[value.length - 1];
// //         result.add('$key = $lastValue');
// //       }
// //     });
// //
// //     if (result.isNotEmpty) {
// //       setState(() {}); // Trigger a rebuild to update the UI
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text('Key Value Display'),
// //       ),
// //       body: Padding(
// //         padding: const EdgeInsets.all(16.0),
// //         child: result.isNotEmpty
// //             ? ListView.builder(
// //           itemCount: result.length,
// //           itemBuilder: (context, index) => ListTile(
// //             title: Text(result[index]),
// //           ),
// //         )
// //             : Center(
// //           child: Text('No keys ending with [kW] found.'),
// //         ),
// //       ),
// //     );
// //   }
// // }
//
//
//
//
//
//
//
//
//
// // import 'dart:convert';
// // import 'package:flutter/material.dart';
// // import 'package:http/http.dart' as http;
// //
// // class MyHomePagess extends StatefulWidget {
// //   @override
// //   _MyHomePagessState createState() => _MyHomePagessState();
// // }
// //
// // class _MyHomePagessState extends State<MyHomePagess> {
// //   Map<String, dynamic> data = {};
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     fetchData();
// //   }
// //
// //   Future<void> fetchData() async {
// //     try {
// //       print('Fetching data...');
// //       http.Response response = await http.get(Uri.parse('http://203.135.63.22:8000/data?username=ppjiq&mode=hour&start=2023-12-07&end=2023-12-07'));
// //
// //       print('API Response: ${response.body}');
// //
// //       if (response.statusCode == 200) {
// //         print('Data fetched successfully');
// //         Map<String, dynamic> jsonData = json.decode(response.body);
// //         setState(() {
// //           data = processJson(jsonData);
// //         });
// //       } else {
// //         print('Failed to fetch data. Status code: ${response.statusCode}');
// //         print('Response body: ${response.body}');
// //       }
// //     } catch (e) {
// //       print('Error: $e');
// //     }
// //   }
// //
// //   Map<String, dynamic> processJson(Map<String, dynamic> json) {
// //     if (json.containsKey("MainKw")) {
// //       double mainKwValue = (json["MainKw"] as List).last.toDouble();
// //       return {"MainKw": mainKwValue};
// //     } else {
// //       Map<String, dynamic> kwValues = {};
// //       json.forEach((key, value) {
// //         if (key.endsWith("Kw")) {
// //           kwValues[key] = (value as List).last.toDouble();
// //         }
// //       });
// //       return kwValues;
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text('API Data Example'),
// //       ),
// //       body: Center(
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: <Widget>[
// //             if (data.containsKey("MainKw"))
// //               ListTile(
// //                 title: Text('MainKw'),
// //                 subtitle: Text('${data["MainKw"]}'),
// //               ),
// //             if (data.isEmpty)
// //               CircularProgressIndicator()
// //             else
// //               ...data.entries.map(
// //                     (entry) => ListTile(
// //                   title: Text(entry.key),
// //                   subtitle: Text('${entry.value}'),
// //                 ),
// //               ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
//
//
//
// // import 'dart:convert';
// // import 'package:flutter/material.dart';
// // import 'package:http/http.dart' as http;
// //
// // class MyHomePagess extends StatefulWidget {
// //   @override
// //   _MyHomePagessState createState() => _MyHomePagessState();
// // }
// //
// // class _MyHomePagessState extends State<MyHomePagess> {
// //   Map<String, dynamic> data = {};
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     fetchData();
// //   }
// //
// //   Future<void> fetchData() async {
// //     try {
// //       print('Fetching data...');
// //       http.Response response = await http.get(Uri.parse('http://203.135.63.22:8000/data?username=ppjiq&mode=hour&start=2023-12-07&end=2023-12-07'));
// //
// //       print('API Response: ${response.body}');
// //
// //       if (response.statusCode == 200) {
// //         print('Data fetched successfully');
// //         Map<String, dynamic> jsonData = json.decode(response.body);
// //         setState(() {
// //           data = processJson(jsonData);
// //         });
// //       } else {
// //         print('Failed to fetch data. Status code: ${response.statusCode}');
// //         print('Response body: ${response.body}');
// //       }
// //     } catch (e) {
// //       print('Error: $e');
// //     }
// //   }
// //
// //   Map<String, dynamic> processJson(Map<String, dynamic> json) {
// //     if (json.containsKey("MainKw")) {
// //       double mainKwValue = (json["MainKw"] as List).last.toDouble();
// //       return {"MainKw": mainKwValue};
// //     } else {
// //       Map<String, dynamic> kwValues = {};
// //       json.forEach((key, value) {
// //         if (key.endsWith("Kw")) {
// //           kwValues[key] = (value as List).last.toDouble();
// //         }
// //       });
// //       return kwValues;
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text('API Data Example'),
// //       ),
// //       body: Center(
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: <Widget>[
// //             if (data.containsKey("MainKw"))
// //               Text('MainKw: ${data["MainKw"]}'),
// //             if (data.isEmpty)
// //               CircularProgressIndicator()
// //             else
// //               ...data.entries.map((entry) => Text('${entry.key}: ${entry.value}')),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
//
//
//
//
//
//
//
//
//
//
//
//
// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// // import 'controller/datacontroller.dart';
// // // Replace with the correct import path
// //
// // class DataDisplayWidget extends StatelessWidget {
// //   final DataControllers dataController = Get.put(DataControllers());
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text('Data Display'),
// //       ),
// //       body: Obx(() {
// //         // Check if data is still loading
// //         if (dataController.loading.value) {
// //           return Center(child: CircularProgressIndicator());
// //         }
// //
// //         // Check if there is no data
// //         if (dataController.kwData.isEmpty) {
// //           return Center(child: Text('No data available.'));
// //         }
// //
// //         // Display the data using ListView.builder
// //         return ListView.builder(
// //           itemCount: dataController.kwData.length,
// //           itemBuilder: (context, index) {
// //             final data = dataController.kwData[index];
// //             final date = data['date'];
// //             final newData = data['data'];
// //
// //             return Card(
// //               margin: EdgeInsets.all(10),
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Padding(
// //                     padding: const EdgeInsets.all(8.0),
// //                     child: Text('Date: $date'),
// //                   ),
// //                   for (var item in newData)
// //                     ListTile(
// //                       title: Text('Name: ${item['prefixName']}'),
// //                       trailing: Text(
// //                           'Sum: ${(item['values'] as List<double>).reduce((a, b) => a + b)}'),
// //                     ),
// //                 ],
// //               ),
// //             );
// //           },
// //         );
// //       }),
// //     );
// //   }
// // }
// //
// // // import 'dart:async';
// // // import 'dart:convert';
// // // import 'package:http/http.dart' as http;
// // // import 'package:flutter/material.dart';
// // // import 'package:get/get.dart';
// // // import 'package:intl/intl.dart';
// // // import '../controller/datacontroller.dart';
// // // import '../highcharts/stock_column.dart';
// // // import '../pichart.dart';
// // // import '../widgets/CustomText.dart';
// // // import '../widgets/SideDrawer.dart';
// // // import '../widgets/switch_button.dart';
// // //
// // // class Summary extends StatefulWidget {
// // //   const Summary({Key? key}) : super(key: key);
// // //
// // //   @override
// // //   State<Summary> createState() => _SummaryState();
// // // }
// // //
// // // class _SummaryState extends State<Summary> {
// // //   final summaryController = Get.put(DatasControllers());
// // //   bool isDataFetched = false;
// // //
// // //   late Timer _fetchDataTimer;
// // //
// // //   @override
// // //   void initState() {
// // //     _fetchDataTimer = Timer.periodic(Duration(minutes: 1), (timer) {
// // //       print('Timer callback abubakar');
// // //       _fetchAllData();
// // //     });
// // //     super.initState();
// // //     _fetchAllData();
// // //   }
// // //
// // //   @override
// // //   void dispose() {
// // //     // Cancel the timer when the widget is disposed
// // //     _fetchDataTimer.cancel();
// // //     super.dispose();
// // //   }
// // //
// // //   Future<void> _fetchAllData({bool fetchLast7Days = true, bool fetchThisMonth = false}) async {
// // //     if (!isDataFetched) {
// // //       try {
// // //         await summaryController.fetchData(
// // //           fetchLast7Days: fetchLast7Days,
// // //           fetchThisMonth: fetchThisMonth,
// // //         );
// // //         summaryController.update();
// // //         isDataFetched = true;
// // //       } catch (error) {
// // //         print('Error fetching data: $error');
// // //       }
// // //     }
// // //   }
// // //
// // //   int selectedIndex = 0;
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       body: FutureBuilder(
// // //         builder: (context, snapshot) {
// // //           if (snapshot.connectionState == ConnectionState.waiting) {
// // //             // Display a loading indicator or placeholder UI
// // //             return Text('Loading');
// // //           } else if (snapshot.hasError) {
// // //             // Display an error message
// // //             return Text('Error loading data: ${snapshot.error}');
// // //           } else {
// // //             return _buildUI();
// // //           }
// // //         },
// // //         future: _fetchAllData(fetchThisMonth: selectedIndex == 1),
// // //       ),
// // //     );
// // //   }
// // //
// // //   Widget _buildUI() {
// // //     return Scaffold(
// // //       drawer: Sidedrawer(context: context),
// // //       appBar: AppBar(
// // //         title: Center(
// // //           child: CustomText(
// // //             texts: 'Summary',
// // //             textColor: const Color(0xff002F46),
// // //           ),
// // //         ),
// // //         actions: [
// // //           SizedBox(
// // //             width: 40,
// // //             height: 30,
// // //             child: Image.asset('assets/images/Vector.png'),
// // //           ),
// // //         ],
// // //       ),
// // //       body: SingleChildScrollView(
// // //         child: Column(
// // //           children: [
// // //             SwitchWidget(
// // //               selectedIndex: selectedIndex,
// // //               onToggle: (index) {
// // //                 setState(() {
// // //                   selectedIndex = index!;
// // //                   isDataFetched = false; // Reset flag when switching between tabs
// // //                 });
// // //                 _fetchAllData(fetchThisMonth: selectedIndex == 1);
// // //               },
// // //             ),
// // //             Visibility(
// // //               visible: selectedIndex == 0,
// // //               child: Column(
// // //                 children: [
// // //                   Obx(() {
// // //                     return Text(
// // //                       'Rs. ${(summaryController.lastMainKWValue * 70 / 1000).toStringAsFixed(2)}',
// // //                       style: const TextStyle(
// // //                         fontSize: 24,
// // //                         fontWeight: FontWeight.w700,
// // //                         height: 1.5,
// // //                         color: Color(0xff009f8d),
// // //                       ),
// // //                     );
// // //                   }),
// // //                   Padding(
// // //                     padding: const EdgeInsets.only(left: 10, right: 10),
// // //                     child: Row(
// // //                       children: [
// // //                         Expanded(
// // //                           flex: 1,
// // //                           child: Container(
// // //                             height: 130,
// // //                             width: 150,
// // //                             decoration: BoxDecoration(
// // //                               color: Color(0xff002f46),
// // //                               borderRadius: BorderRadius.circular(20),
// // //                             ),
// // //                             child: Padding(
// // //                               padding: const EdgeInsets.all(8.0),
// // //                               child: Column(
// // //                                 mainAxisAlignment: MainAxisAlignment.start,
// // //                                 crossAxisAlignment: CrossAxisAlignment.start,
// // //                                 children: [
// // //                                   Row(
// // //                                     mainAxisAlignment:
// // //                                     MainAxisAlignment.spaceBetween,
// // //                                     crossAxisAlignment:
// // //                                     CrossAxisAlignment.start,
// // //                                     children: [
// // //                                       CustomText(
// // //                                         texts: 'cost of usage',
// // //                                         textColor: Color(0xff009f8d),
// // //                                       ),
// // //                                       SizedBox(
// // //                                         width: 20,
// // //                                         height: 20,
// // //                                         child: Image.asset(
// // //                                             'assets/images/Vector.png'),
// // //                                       ),
// // //                                     ],
// // //                                   ),
// // //                                   Obx(() {
// // //                                     return Text(
// // //                                       'Rs. ${(summaryController.lastMainKWValue * 70 / 1000).toStringAsFixed(2)}',
// // //                                       style: const TextStyle(
// // //                                         fontSize: 24,
// // //                                         fontWeight: FontWeight.w700,
// // //                                         height: 1.5,
// // //                                         color: Color(0xb2ffffff),
// // //                                       ),
// // //                                     );
// // //                                   }),
// // //                                   CustomText(
// // //                                     texts: 'per hour',
// // //                                     textColor: Color(0xb2ffffff),
// // //                                   ),
// // //                                 ],
// // //                               ),
// // //                             ),
// // //                           ),
// // //                         ),
// // //                         const SizedBox(
// // //                           width: 10,
// // //                         ),
// // //                         Expanded(
// // //                           flex: 1,
// // //                           child: Container(
// // //                             height: 130,
// // //                             width: 150,
// // //                             decoration: BoxDecoration(
// // //                               color: Color(0xff002f46),
// // //                               borderRadius: BorderRadius.circular(20),
// // //                             ),
// // //                             child: Padding(
// // //                               padding: const EdgeInsets.all(8.0),
// // //                               child: Column(
// // //                                 mainAxisAlignment: MainAxisAlignment.start,
// // //                                 crossAxisAlignment: CrossAxisAlignment.start,
// // //                                 children: [
// // //                                   Row(
// // //                                     mainAxisAlignment:
// // //                                     MainAxisAlignment.spaceBetween,
// // //                                     crossAxisAlignment:
// // //                                     CrossAxisAlignment.start,
// // //                                     children: [
// // //                                       CustomText(
// // //                                         texts: 'power',
// // //                                         textColor: Color(0xff009f8d),
// // //                                       ),
// // //                                       SizedBox(
// // //                                         width: 20,
// // //                                         height: 20,
// // //                                         child: Image.asset(
// // //                                             'assets/images/Vector.png'),
// // //                                       ),
// // //                                     ],
// // //                                   ),
// // //                                   Obx(() {
// // //                                     return Text(
// // //                                       '${(summaryController.lastMainKWValue / 1000).toStringAsFixed(2)} KW',
// // //                                       style: const TextStyle(
// // //                                         fontSize: 24,
// // //                                         fontWeight: FontWeight.w700,
// // //                                         height: 1.5,
// // //                                         color: Color(0xb2ffffff),
// // //                                       ),
// // //                                     );
// // //                                   }),
// // //                                   CustomText(
// // //                                     texts:
// // //                                     'as of ${DateFormat('HH:mm').format(DateTime.now())}',
// // //                                     textColor: Color(0xb2ffffff),
// // //                                   ),
// // //                                 ],
// // //                               ),
// // //                             ),
// // //                           ),
// // //                         ),
// // //                       ],
// // //                     ),
// // //                   ),
// // //                   Container(
// // //                       height: 400,
// // //                       child: StockColumn(
// // //                         controllers: summaryController,
// // //                       )),
// // //                   const SizedBox(
// // //                     height: 30,
// // //                   ),
// // //                   PieChart(controllers: summaryController),
// // //                 ],
// // //               ),
// // //             ),
// // //             Visibility(
// // //               visible: selectedIndex == 1,
// // //               child: LastMonthWidget(),
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }
// // //
// // // class LastMonthWidget extends StatelessWidget {
// // //   // Implement the UI for the Last Month tab here
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Container(
// // //       padding: EdgeInsets.all(16),
// // //       child: Text(
// // //         'Last Month Data',
// // //         style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
// // //       ),
// // //     );
// // //   }
// // // }
// // // class DatasControllers extends GetxController {
// // //   RxList<Map<String, dynamic>> kwData = <Map<String, dynamic>>[].obs;
// // //   RxDouble lastMainKWValue = 0.0.obs;
// // //   RxBool loading = false.obs;
// // //   final usernamenameController = TextEditingController();
// // //   final passwordController = TextEditingController();
// // //   var username = ''.obs;
// // //   var password = ''.obs;
// // //
// // //   Future<void> fetchData({bool fetchLast7Days = true, bool fetchThisMonth = false}) async {
// // //     final username = usernamenameController.text.toString();
// // //
// // //     Set<String> processedDates = Set();
// // //
// // //     try {
// // //       DateTime startDate;
// // //       DateTime endDate;
// // //
// // //       if (fetchLast7Days) {
// // //         // Fetch data for the last 7 days
// // //         endDate = DateTime.now();
// // //         startDate = endDate.subtract(Duration(days: 6));
// // //       } else if (fetchThisMonth) {
// // //         // Fetch data for the current month
// // //         endDate = DateTime.now();
// // //         startDate = DateTime(endDate.year, endDate.month, 1);
// // //       }
// // //
// // //       // Loop through the days within the specified range
// // //       for (DateTime date = startDate; date.isBefore(endDate); date = date.add(Duration(days: 1))) {
// // //         String formattedDate = date.toLocal().toString().split(' ')[0];
// // //
// // //         // Skip fetching if the date has already been processed
// // //         if (processedDates.contains(formattedDate)) {
// // //           continue;
// // //         }
// // //
// // //         try {
// // //           // Make an HTTP GET request
// // //           final String apiUrl =
// // //               "http://203.135.63.22:8000/data?username=$username&mode=hour&start=$formattedDate&end=$formattedDate";
// // //           final response = await http.get(
// // //             Uri.parse(apiUrl),
// // //           );
// // //           print(apiUrl);
// // //
// // //           // Check if the request was successful (status code 200)
// // //           if (response.statusCode == 200) {
// // //             // Parse the JSON response
// // //             Map<String, dynamic> jsonData = json.decode(response.body);
// // //             Map<String, dynamic> data = jsonData['data'];
// // //
// // //             // Extract and process relevant data
// // //             List<Map<String, dynamic>> newData = [];
// // //
// // //             data.forEach((itemName, values) {
// // //               if (itemName.endsWith("[kW]")) {
// // //                 String prefixName = itemName.substring(0, itemName.length - 4);
// // //                 List<double> numericValues =
// // //                 (values as List<dynamic>).map((value) {
// // //                   if (value is num) {
// // //                     return value.toDouble();
// // //                   } else if (value is String) {
// // //                     return double.tryParse(value) ?? 0.0;
// // //                   } else {
// // //                     return 0.0;
// // //                   }
// // //                 }).toList();
// // //
// // //                 newData.add({
// // //                   'prefixName': prefixName,
// // //                   'values': numericValues,
// // //                 });
// // //               }
// // //             });
// // //             // Update kwData with the new data
// // //             kwData.add({'date': formattedDate, 'data': newData});
// // //
// // //             // Update lastMainKWValue with the last value of "Main_[kW]"
// // //             lastMainKWValue.value = newData
// // //                 .where((item) => item['prefixName'] == 'Main_')
// // //                 .map((item) => item['values'].last)
// // //                 .first;
// // //
// // //             // Mark the date as processed to avoid duplicates
// // //             processedDates.add(formattedDate);
// // //           } else {
// // //             // Handle unsuccessful response
// // //             print(
// // //                 'Failed to fetch data for $formattedDate. Status code: ${response.statusCode}');
// // //             print('Response body: ${response.body}');
// // //           }
// // //         } catch (error) {
// // //           // Handle HTTP request error
// // //           print('Error fetching data for $formattedDate: $error');
// // //         }
// // //       }
// // //     } catch (error) {
// // //       // Handle general error
// // //       print('An unexpected error occurred: $error');
// // //     }
// // //   }
// // // }
// // //
// // //
// // // // import 'package:flutter/material.dart';
// // // // import 'package:get/get.dart';
// // // // import 'package:http/http.dart' as http;
// // // //
// // // //
// // // // class UserController extends GetxController {
// // // //   var username = ''.obs;
// // // //   var password = ''.obs;
// // // //
// // // //   // Function to handle login
// // // //   Future<void> login() async {
// // // //     try {
// // // //       final response = await http.post(
// // // //         Uri.parse('http://203.135.63.22:8000/signin'),
// // // //         headers: <String, String>{
// // // //           'Content-Type': 'application/x-www-form-urlencoded',
// // // //         },
// // // //         body: {
// // // //           'username': username.value,
// // // //           'password': password.value,
// // // //         },
// // // //       );
// // // //
// // // //       if (response.statusCode == 200) {
// // // //         // Successful login, call the second API
// // // //         getData();
// // // //       } else {
// // // //         // Handle login failure
// // // //         print('Login failed. Status code: ${response.statusCode}, Response: ${response.body}');
// // // //         Get.snackbar('Login Failed', 'Invalid credentials');
// // // //       }
// // // //     } catch (e) {
// // // //       // Handle error
// // // //       print(e);
// // // //     }
// // // //   }
// // // //
// // // //
// // // //   // Function to get data after successful login
// // // //   Future<void> getData() async {
// // // //     try {
// // // //       final response = await http.get(
// // // //         Uri.parse('http://203.135.63.22:8000/data?username=${username.value}&mode=hour&start=2023-12-07&end=2023-12-07'),
// // // //       );
// // // //
// // // //       if (response.statusCode == 200) {
// // // //         // Process data as needed
// // // //         print('Data: ${response.body}');
// // // //       } else {
// // // //         // Handle data retrieval failure
// // // //         Get.snackbar('Data Retrieval Failed', 'Failed to fetch data');
// // // //       }
// // // //     } catch (e) {
// // // //       // Handle error
// // // //       print(e);
// // // //     }
// // // //   }
// // // // }
// // // //
// // // // class getxlogin extends StatelessWidget {
// // // //   final UserController userController = Get.put(UserController());
// // // //
// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return MaterialApp(
// // // //       home: Scaffold(
// // // //         appBar: AppBar(
// // // //           title: Text('Getx Login Example'),
// // // //         ),
// // // //         body: Center(
// // // //           child: Padding(
// // // //             padding: const EdgeInsets.all(16.0),
// // // //             child: Column(
// // // //               mainAxisAlignment: MainAxisAlignment.center,
// // // //               children: [
// // // //                 TextField(
// // // //                   onChanged: (value) => userController.username.value = value,
// // // //                   decoration: InputDecoration(labelText: 'Username'),
// // // //                 ),
// // // //                 SizedBox(height: 16),
// // // //                 TextField(
// // // //                   onChanged: (value) => userController.password.value = value,
// // // //                   obscureText: true,
// // // //                   decoration: InputDecoration(labelText: 'Password'),
// // // //                 ),
// // // //                 SizedBox(height: 32),
// // // //                 ElevatedButton(
// // // //                   onPressed: () => userController.login(),
// // // //                   child: Text('Login'),
// // // //                 ),
// // // //               ],
// // // //             ),
// // // //           ),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // // }
// // //
// // // // import 'dart:convert';
// // // //
// // // // import 'package:flutter/material.dart';
// // // // import 'package:high_chart/high_chart.dart';
// // // // import 'package:http/http.dart' as http;
// // // //
// // // // class PieChartWidget extends StatelessWidget {
// // // //   final List<Map<String, dynamic>> todayData;
// // // //
// // // //   PieChartWidget({Key? key, required this.todayData}) : super(key: key);
// // // //
// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return Padding(
// // // //       padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
// // // //       child: HighCharts(
// // // //         loader: const SizedBox(
// // // //           child: LinearProgressIndicator(),
// // // //           width: 200,
// // // //         ),
// // // //         size: const Size(400, 400),
// // // //         data: _getPieChartData(),
// // // //         scripts: const ["https://code.highcharts.com/highcharts.js"],
// // // //       ),
// // // //     );
// // // //   }
// // // //
// // // //   String _getPieChartData() {
// // // //     // Generate dynamic chart data based on today's data
// // // //     List<List<dynamic>> seriesData = [];
// // // //     Map<String, int> colorMap = {};
// // // //
// // // //     todayData.forEach((item) {
// // // //       String prefixName = item['prefixName'];
// // // //       List<double> values = item['values'];
// // // //
// // // //       if (!colorMap.containsKey(prefixName)) {
// // // //         colorMap[prefixName] = colorMap.length;
// // // //       }
// // // //
// // // //       for (int i = 0; i < values.length; i++) {
// // // //         seriesData.add([
// // // //           prefixName,
// // // //           values[i],
// // // //           colorMap[prefixName], // Color index for each appliance
// // // //         ]);
// // // //       }
// // // //     });
// // // //
// // // //     // Build series configuration for the pie chart
// // // //     String seriesConfig = '''
// // // //       {
// // // //         type: 'pie',
// // // //         name: 'Today',
// // // //         data: ${seriesData.map((data) => [data[0], data[1]]).toList()},
// // // //       }
// // // //     ''';
// // // //
// // // //     return '''
// // // //       {
// // // //         accessibility: {
// // // //           enabled: false
// // // //         },
// // // //         chart: {
// // // //           plotBackgroundColor: null,
// // // //           plotBorderWidth: null,
// // // //           plotShadow: false,
// // // //           type: 'pie'
// // // //         },
// // // //         title: {
// // // //           text: 'Today\'s Breakdown'
// // // //         },
// // // //         series: [$seriesConfig]
// // // //       }
// // // //     ''';
// // // //   }
// // // // }
// // // //
// // // // // import 'package:flutter/material.dart';
// // // // // import 'package:http/http.dart' as http;
// // // // // import 'dart:convert';
// // // // // import 'package:syncfusion_flutter_charts/charts.dart';
// // // // //
// // // // //
// // // // // class MyHomePage extends StatefulWidget {
// // // // //   @override
// // // // //   _MyHomePageState createState() => _MyHomePageState();
// // // // // }
// // // // //
// // // // // class _MyHomePageState extends State<MyHomePage> {
// // // // //   String selectedStartDate = '2023-12-07';
// // // // //   String selectedEndDate = '2023-12-07';
// // // // //   List<double> mainKWData = [];
// // // // //   List<double> mainAData = [];
// // // // //   List<double> mainPFData = [];
// // // // //   double sumMainKW = 0.0;
// // // // //   double sumMainA = 0.0;
// // // // //   double sumMainPF = 0.0;
// // // // //   double lastMainKWValue = 0.0;
// // // // //   double lastFreshAirValue = 0.0;
// // // // //   int selectedDateTimeIndex = 0;
// // // // //   String apiUrl = 'http://203.135.63.22:8000/data';
// // // // //   int touchedIndex = -1;
// // // // // //  late List<MyDataModel> data;
// // // // //   late TooltipBehavior _tooltip;
// // // // //
// // // // //   Map<String, dynamic> responseData = {};
// // // // //
// // // // //   Future<void> fetchData() async {
// // // // //     try {
// // // // //       DateTime now = DateTime.now();
// // // // //       selectedEndDate = now.toIso8601String().split('T')[0];
// // // // //       DateTime twentyFourHoursAgo = now.subtract(Duration(hours: 24));
// // // // //       selectedStartDate = twentyFourHoursAgo.toIso8601String().split('T')[0];
// // // // //       final response = await http.get(Uri.parse(
// // // // //           '$apiUrl?username=ppjiq&mode=hour&start=$selectedStartDate&end=$selectedEndDate'));
// // // // //
// // // // //       // final response = await http.get(Uri.parse(
// // // // //       //     '$apiUrl?username=ppjiq&mode=hour&start=$selectedStartDate&end=$selectedEndDate'));
// // // // //
// // // // //
// // // // //
// // // // //
// // // // //
// // // // //       if (response.statusCode == 200) {
// // // // //         responseData = json.decode(response.body);
// // // // //         if (responseData['data'] != null) {
// // // // //           setState(() {
// // // // //             mainKWData = List<double>.from(responseData['data']['Main_[kW]']);
// // // // //             mainAData = List<double>.from(responseData['data']['Main_[A]']);
// // // // //             mainPFData = List<double>.from(responseData['data']['Main_[PF]']);
// // // // //
// // // // //             sumMainKW = mainKWData.reduce((value, element) => value + element);
// // // // //             sumMainA = mainAData.reduce((value, element) => value + element);
// // // // //             sumMainPF = mainPFData.reduce((value, element) => value + element);
// // // // //
// // // // //             // Extract the last value of "Main_[kW]" within the selected date range
// // // // //             lastMainKWValue = mainKWData.isNotEmpty ? mainKWData.last : 0.0;
// // // // //
// // // // //             // Extract the last value of "Fresh Air_[V]" within the selected date range
// // // // //             // lastFreshAirValue =
// // // // //             // mainFreshAirData.isNotEmpty ? mainFreshAirData.last : 0.0;
// // // // //           });
// // // // //         }
// // // // //       } else {
// // // // //         print('Failed to load data: ${response.statusCode}');
// // // // //       }
// // // // //     } catch (e) {
// // // // //       print('Error: $e');
// // // // //     }
// // // // //   }
// // // // //
// // // // //   Future<void> _selectDate(BuildContext context, bool isStartDate) async {
// // // // //     DateTime initialDate =
// // // // //     DateTime.parse(isStartDate ? selectedStartDate : selectedEndDate);
// // // // //     DateTime? pickedDate = await showDatePicker(
// // // // //       context: context,
// // // // //       initialDate: initialDate,
// // // // //       firstDate: DateTime(2020),
// // // // //       lastDate: DateTime(2025),
// // // // //     );
// // // // //
// // // // //     if (pickedDate != null && pickedDate != initialDate) {
// // // // //       setState(() {
// // // // //         if (isStartDate) {
// // // // //           selectedStartDate = pickedDate.toIso8601String().split('T')[0];
// // // // //         } else {
// // // // //           selectedEndDate = pickedDate.toIso8601String().split('T')[0];
// // // // //         }
// // // // //       });
// // // // //       fetchData();
// // // // //     }
// // // // //   }
// // // // //
// // // // //   @override
// // // // //   void initState() {
// // // // //     fetchData(); // Call the method to fetch data
// // // // //     _tooltip = TooltipBehavior(enable: true);
// // // // //     super.initState();
// // // // //   }
// // // // //
// // // // //   @override
// // // // //   Widget build(BuildContext context) {
// // // // //     return Scaffold(
// // // // //       appBar: AppBar(
// // // // //         title: Text('Main Data in Flutter'),
// // // // //       ),
// // // // //       body: SingleChildScrollView(
// // // // //         child: Padding(
// // // // //           padding: const EdgeInsets.all(16.0),
// // // // //           child: Column(
// // // // //             crossAxisAlignment: CrossAxisAlignment.start,
// // // // //             children: [
// // // // //               Row(
// // // // //                 children: [
// // // // //                   Expanded(
// // // // //                     child: InkWell(
// // // // //                       onTap: () => _selectDate(context, true),
// // // // //                       child: Row(
// // // // //                         children: [
// // // // //                           Icon(Icons.calendar_today),
// // // // //                           SizedBox(width: 8),
// // // // //                           Text(selectedStartDate),
// // // // //                         ],
// // // // //                       ),
// // // // //                     ),
// // // // //                   ),
// // // // //                   SizedBox(width: 16),
// // // // //                   Expanded(
// // // // //                     child: InkWell(
// // // // //                       onTap: () => _selectDate(context, false),
// // // // //                       child: Row(
// // // // //                         children: [
// // // // //                           Icon(Icons.calendar_today),
// // // // //                           SizedBox(width: 8),
// // // // //                           Text(selectedEndDate),
// // // // //                         ],
// // // // //                       ),
// // // // //                     ),
// // // // //                   ),
// // // // //                 ],
// // // // //               ),
// // // // //               ElevatedButton(
// // // // //                 onPressed: () {
// // // // //                   fetchData();
// // // // //                 },
// // // // //                 child: Text('Fetch Data'),
// // // // //               ),
// // // // //               SizedBox(height: 16),
// // // // //               mainKWData.isNotEmpty
// // // // //                   ? Column(
// // // // //                   children: [
// // // // //                     Text('Last Main_[kW]: $lastMainKWValue'),
// // // // //                     SizedBox(height: 16),
// // // // //                     Text('Last lastFreshAirValue: $lastFreshAirValue'),
// // // // //                     SizedBox(height: 16),
// // // // //                     SfCartesianChart(
// // // // //                       primaryXAxis: CategoryAxis(),
// // // // //                       primaryYAxis: NumericAxis(
// // // // //                           minimum: 0, maximum: lastMainKWValue, interval: 10),
// // // // //                       tooltipBehavior: _tooltip,
// // // // //                       series: <CartesianSeries>[
// // // // //                         ColumnSeries<double, String>(
// // // // //                           dataSource: [
// // // // //                             lastMainKWValue,
// // // // //                             sumMainA,
// // // // //                             sumMainPF,
// // // // //                           ],
// // // // //                           xValueMapper: (_, index) {
// // // // //                             if (index == 0) {
// // // // //                               return 'Main_[kW]';
// // // // //                             } else if (index == 1) {
// // // // //                               return 'Main_[A]';
// // // // //                             } else {
// // // // //                               return '';
// // // // //                             }
// // // // //                           },
// // // // //                           yValueMapper: (value, _) => value,
// // // // //                           name: 'Gold',
// // // // //                           color: Color.fromRGBO(8, 142, 255, 1),
// // // // //                         ),
// // // // //                       ],
// // // // //                     ),
// // // // //                   ]
// // // // //               )
// // // // //                   : SizedBox.shrink(),
// // // // //             ],
// // // // //           ),
// // // // //         ),
// // // // //       ),
// // // // //     );
// // // // //   }
// // // // // }
