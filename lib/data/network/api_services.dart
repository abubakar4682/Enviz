import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

import '../exceptions/app_exceptions.dart';
import '../sharedPrefences/sharedPrefences.dart';

import 'base_api_services.dart';
import 'package:http/http.dart' as http;

class ApiServices extends BaseApiServices {
  final SharedPreferencesService sharedPreferencesService =
  SharedPreferencesService();

  @override
  Future<dynamic> getApi(String url) async {
    dynamic responseJson;

    try {
      final username = await sharedPreferencesService.getData<String>('username');

      if (username != null) {
        final response = await http.get(
          Uri.parse(url),
          headers: {
            'username': username,
            'Content-Type': 'application/json',
            // Add any other headers if required
          },
        ).timeout(
          const Duration(seconds: 10),
        );

        responseJson = returnResponse(response);
      } else {
        // Handle the case where 'username' is null or not a String.
        // You can choose to throw an error, log a message, or take other actions.
      }
    } on SocketException {
      throw InternetException();
    } on TimeOutError {
      throw TimeOutError();
    }

    return responseJson;
  }

  @override
  Future<dynamic> postApi(Map<String, dynamic> data, String url,
      {Map<String, dynamic>? queryParams}) async {
    if (kDebugMode) {
      print(url);
      print(data);
    }

    late Map responseJson;

    try {
      // Append query parameters to the URL
      if (queryParams != null && queryParams.isNotEmpty) {
        final uri = Uri.parse(url).replace(queryParameters: queryParams);
        url = uri.toString();
      }

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json', // Set your content type here
          // Add any other headers if required
        },
        body: json.encode(data),
      ).timeout(const Duration(seconds: 10));

      responseJson = returnResponse(response);
    } on SocketException catch (e, s) {
      debugPrintStack(stackTrace: s, label: e.toString());
      throw InternetException(e.message);
    } on TimeOutError {
      throw TimeOutError();
    }
    return responseJson;
  }

  Map returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        final responseJson = jsonDecode(response.body);
        return responseJson;
      case 404:

      ///this will manage according to api
      /*
     dynamic responseJson = jsonDecode(response.body);
        return responseJson;

         */
        throw DataNotFound();
      default:
        throw ApiFetchDataException(
            'Error Occur while communicating${response.statusCode}');
    }
  }
}
