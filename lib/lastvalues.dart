import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UserDataScreen extends StatefulWidget {
  final String username;

  UserDataScreen({required this.username});

  @override
  _UserDataScreenState createState() => _UserDataScreenState();
}

class _UserDataScreenState extends State<UserDataScreen> {
  Future<Map<String, dynamic>> fetchData(String username) async {
    final url = 'http://203.135.63.22:8000/data?username=$username&mode=hour&start=2024-01-10&end=2024-01-10';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch data. Status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Data: ${widget.username}'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchData(widget.username),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || !snapshot.data!.containsKey('data')) {
            return Center(child: Text('Invalid response format'));
          }

          Map<String, dynamic> data = snapshot.data!['data'];

          // Debug prints to understand the structure of the data
          print('Data: $data');

          if (data.containsKey('MainKw') && data['MainKw'] is List && data['MainKw'].isNotEmpty) {
            double mainKwLastValue = (data['MainKw'].last as num).toDouble();
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('User ${widget.username} has MainKw value. Last value is $mainKwLastValue'),
              ],
            );
          } else {
            Map<String, dynamic> kwItems = {};
            data.forEach((key, values) {
              if (key.endsWith('[kW]') && !key.contains('MainKw') && values.isNotEmpty) {
                kwItems[key] = values.last;
              }
            });

            // Debug prints to understand the structure of kwItems
            print('kwItems: $kwItems');

            // Calculate the sum excluding MainKw
            double sum = kwItems.values.fold(0, (prev, value) {
              if (value is num) {
                return prev + value.toDouble();
              } else if (value == null) {
                return prev; // Skip null values
              } else {
                // Handle other cases if necessary
                return prev;
              }
            });

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('User ${widget.username} does not have MainKw.'),
                if (kwItems.isNotEmpty)
                  Column(
                    children: [
                      Text('Sum of last values (excluding MainKw): $sum'),
                      // Display individual kW items
                      for (var entry in kwItems.entries)
                        Text('${entry.key} last value is ${entry.value ?? 'N/A'}'),

                    ],
                  ),
              ],
            );
          }
        },
      ),
    );
  }
}
