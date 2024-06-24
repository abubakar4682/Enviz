import 'package:connectivity/connectivity.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';


class DataControllerForThisMonth extends GetxController {
  var isLoading = true.obs;
  var pieChartData = ''.obs;
  var data = <String, List<double>>{}.obs;
  DateTime startDate = DateTime.now().subtract(Duration(days: 1));
  var hasError = false.obs;
  RxString errorMessage = ''.obs;
  var chartData = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchChartData();
  }

  void resetController() {
    isLoading(true); // Assuming default is loading
    data(<String, List<double>>{}); // Clear all data
    errorMessage(''); // Clear any error messages
    startDate =
        DateTime.now().subtract(Duration(days: 1)); // Reset the start date
  }

  Future<void> fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUsername = prefs.getString('username');
    isLoading(true);
    DateTime now = DateTime.now();
    DateTime endDate = DateTime(now.year, now.month,
        now.day); // Ensures the time is set to 00:00:00 of today
    // Set startDate to the first day of the current month
    DateTime startDate = DateTime(now.year, now.month, 1);

    // Format the dates to 'YYYY-MM-DD' format
    String formattedStartDate =
        "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}";
    String formattedEndDate =
        "${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}";

    final Uri uri = Uri.parse(
        'http://203.135.63.47:8000/data?username=$storedUsername&mode=hour&start=$formattedStartDate&end=$formattedEndDate');

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final Map<String, dynamic> responseData = jsonResponse['data'];
        final Map<String, List<double>> processedData = {};

        responseData.forEach((key, value) {
          if (key.endsWith('_[kW]')) {
            List<double> listValues = (value as List).map((item) {
              double val = 0.0;
              if (item != null && item != 'NA' && item != '') {
                val = double.tryParse(item.toString()) ?? 0.0;
              }
              return double.parse((val / 1000).toStringAsFixed(2));
            }).toList();
            processedData[key] = [];
            for (int i = 0; i < listValues.length; i += 24) {
              processedData[key]!.add(listValues
                  .sublist(i,
                  i + 24 > listValues.length ? listValues.length : i + 24)
                  .reduce((a, b) => a + b));
            }
          }
        });

        data(processedData);
        this.startDate = startDate;
      } else {
        print('Failed to load data with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to load data with error: $e');
    } finally {
      isLoading(false);
    }
  }

  void fetchChartData() async {
    errorMessage.value = '';
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      errorMessage.value = "No internet connection available.";
      isLoading(false);
      return;
    }

    isLoading(true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUsername = prefs.getString('username');
    if (storedUsername == null) {
      errorMessage.value = "No username found in preferences.";
      isLoading(false);
      return;
    }
    DateTime now = DateTime.now();
    DateTime endDate = DateTime(now.year, now.month,
        now.day); // Ensures the time is set to 00:00:00 of today
    // Set startDate to the first day of the current month
    DateTime startDate = DateTime(now.year, now.month, 1);
    String formattedStartDate =
        "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}";
    String formattedEndDate =
        "${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}";

    try {
      isLoading(true);
      final response = await http.get(Uri.parse(
          'http://203.135.63.47:8000/data?username=$storedUsername&mode=day&start=$formattedStartDate&end=$formattedEndDate'));
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        chartData(parseChartData(jsonResponse));
        pieChartData(
            parsePieChartData(jsonResponse)); // Generate pie chart data
      } else {
        errorMessage.value =
        'Failed to load data with status code: ${response.statusCode}';
        hasError(true);
        throw Exception('Failed to load chart data');
      }
    } catch (e) {
      errorMessage.value = 'Failed to load data with error: $e';
      hasError(true);
    } finally {
      isLoading(false);
    }
  }

  String parseChartData(Map<String, dynamic> jsonResponse) {
    List<String> categories =
    List<String>.from(jsonResponse['data']['Date & Time']);
    List<dynamic> series = [];
    jsonResponse['data'].forEach((key, value) {
      if (key.endsWith('_[kW]')) {
        List convertedData = (value as List)
            .map((item) => item is int ? item.toDouble() : item / 1000)
            .toList();
        series.add({
          'name': key.replaceAll('_[kW]', ''),
          'data': convertedData,
          "visible": !(key.startsWith('Main') || key.startsWith('Generator')),
        });
      }
    });

    return json.encode({
      'chart': {'type': 'column'},
      "title": {"text": 'Daily Breakdown'},
      'xAxis': {'categories': categories},
      "yAxis": {
        "min": 0,
        "title": {"text": 'Energy (kWh)'},
        "stackLabels": {"enabled": false}
      },
      "tooltip": {
        "headerFormat": '{point.key:%A, %e %b %Y}</b><br/>',
        "pointFormat": '<b>{series.name}: {point.y:.2f} kWh</b>'
      },
      "plotOptions": {
        "column": {
          "stacking": 'normal',
          "dataLabels": {"enabled": false},
          "pointWidth": 15,
          "borderRadius": 5
        }
      },
      'series': series
    });
  }

  String parsePieChartData(Map<String, dynamic> jsonResponse) {
    List<dynamic> data = [];
    double total = 0;

    // Calculate total to compute percentages
    jsonResponse['data'].forEach((key, value) {
      if (key.endsWith('_[kW]')) {
        double sum =
        (value as List).fold(0, (prev, item) => prev + (item / 1000));
        total += sum;
      }
    });

    // Construct the data array for the pie chart
    jsonResponse['data'].forEach((key, value) {
      if (key.endsWith('_[kW]')) {
        double sum =
        (value as List).fold(0, (prev, item) => prev + (item / 1000));
        double percentage = (sum / total) * 100;
        data.add({
          'name': key.replaceAll('_[kW]', ''),
          'y': sum,
          'percentage': percentage // Store percentage for display
        });
      }
    });

    return json.encode({
      'chart': {'type': 'pie'},
      "title": {"text": 'Appliance Share'},
      'tooltip': {
        // Tooltip shows only the value in kWh
        "pointFormat": '<b>{point.y:.1f} kWh</b>'
      },
      'plotOptions': {
        'pie': {
          'allowPointSelect': true,
          'cursor': 'pointer',
          'dataLabels': {
            'enabled': true,
            // Display only percentage outside the slices
            'format': '{point.percentage:.1f}%',
            'style': {
              'color': 'black' // Change as needed to fit your app's theme
            }
          },
          'showInLegend': true // Ensure the legend is shown
        }
      },
      'series': [
        {'name': 'Energy', 'colorByPoint': true, 'data': data}
      ]
    });
  }
}