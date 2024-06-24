import 'package:connectivity/connectivity.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class WeekDataController extends GetxController {
  // Observables
  var isLoading = true.obs;
  var data = <String, List<double>>{}.obs;
  var errorMessage = ''.obs; // Observable for error messages
  var chartData = ''.obs;
  var hasError = false.obs;
  var pieChartData = ''.obs;

  // Initial date
  DateTime startDate = DateTime.now().subtract(Duration(days: 1));

  @override
  void onInit() {
    super.onInit();
    fetchChartData(); // Fetch chart data on initialization
  }

  // Resets the controller's state
  void resetController() {
    isLoading(true); // Set loading to true
    data(<String, List<double>>{}); // Clear data
    errorMessage(''); // Clear error messages
    startDate = DateTime.now().subtract(Duration(days: 1)); // Reset start date
  }

  // Fetch chart data from API
  void fetchChartData() async {
    errorMessage.value = '';

    // Check for internet connectivity
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      errorMessage.value = "No internet connection available.";
      isLoading(false);
      return;
    }

    isLoading(true);

    // Retrieve username from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUsername = prefs.getString('username');
    if (storedUsername == null) {
      errorMessage.value = "No username found in preferences.";
      isLoading(false);
      return;
    }

    // Set date range
    DateTime endDate = DateTime.now().toUtc().add(Duration(hours: 5));
    DateTime startDate = DateTime.now().subtract(Duration(days: 7));
    String formattedStartDate = _formatDate(startDate);
    String formattedEndDate = _formatDate(endDate);

    // API URL
    final String apiUrl = 'http://203.135.63.47:8000/data?username=$storedUsername&mode=day&start=$formattedStartDate&end=$formattedEndDate';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        chartData.value = _parseChartData(jsonResponse);
        pieChartData.value = _parsePieChartData(jsonResponse); // Generate pie chart data
      } else {
        _handleError('Failed to load data with status code: ${response.statusCode}');
      }
    } catch (e) {
      _handleError('Failed to load data with error: $e');
    } finally {
      isLoading(false);
    }
  }

  // Helper method to format date as string
  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  // Helper method to handle errors
  void _handleError(String message) {
    errorMessage.value = message;
    hasError(true);
  }

  // Parse chart data from API response
  String _parseChartData(Map<String, dynamic> jsonResponse) {
    List<String> categories = List<String>.from(jsonResponse['data']['Date & Time']);
    List<dynamic> series = [];

    jsonResponse['data'].forEach((key, value) {
      if (key.endsWith('_[kW]')) {
        List<double> convertedData = (value as List).map((item) => _convertToDouble(item)).toList();
        series.add({
          'name': key.replaceAll('_[kW]', ''),
          'data': convertedData,
          'visible': !(key.startsWith('Main') || key.startsWith('Generator')),
        });
      }
    });

    return json.encode({
      'chart': {'type': 'column'},
      'title': {'text': 'Daily Breakdown'},
      'xAxis': {'categories': categories},
      'yAxis': {
        'min': 0,
        'title': {'text': 'Energy (kWh)'},
        'stackLabels': {'enabled': false}
      },
      'tooltip': {
        'headerFormat': '{point.key:%A, %e %b %Y}</b><br/>',
        'pointFormat': '<b>{series.name}: {point.y:.2f} kWh</b>'
      },
      'plotOptions': {
        'column': {
          'stacking': 'normal',
          'dataLabels': {'enabled': false},
          'pointWidth': 25,
          'borderRadius': 5
        }
      },
      'series': series
    });
  }

  // Convert item to double
  double _convertToDouble(dynamic item) {
    return item is int ? item.toDouble() : item / 1000;
  }

  // Parse pie chart data from API response
  String _parsePieChartData(Map<String, dynamic> jsonResponse) {
    List<dynamic> data = [];
    double total = _calculateTotal(jsonResponse);

    jsonResponse['data'].forEach((key, value) {
      if (key.endsWith('_[kW]')) {
        double sum = _calculateSum(value as List);
        double percentage = (sum / total) * 100;
        data.add({
          'name': key.replaceAll('_[kW]', ''),
          'y': sum,
          'percentage': percentage
        });
      }
    });

    return json.encode({
      'chart': {'type': 'pie'},
      'title': {'text': 'Appliance Share'},
      'tooltip': {
        'pointFormat': '<b>{point.y:.1f} kWh</b>'
      },
      'plotOptions': {
        'pie': {
          'allowPointSelect': true,
          'cursor': 'pointer',
          'dataLabels': {
            'enabled': true,
            'format': '{point.percentage:.1f}%',
            'style': {'color': 'black'}
          },
          'showInLegend': true
        }
      },
      'series': [{
        'name': 'Energy',
        'colorByPoint': true,
        'data': data
      }]
    });
  }

  // Calculate total energy
  double _calculateTotal(Map<String, dynamic> jsonResponse) {
    double total = 0;
    jsonResponse['data'].forEach((key, value) {
      if (key.endsWith('_[kW]')) {
        total += _calculateSum(value as List);
      }
    });
    return total;
  }

  // Calculate sum of a list of values
  double _calculateSum(List<dynamic> values) {
    return values.fold(0, (prev, item) => prev + _convertToDouble(item));
  }
}
