import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyAppcvcc());
}

class MyAppcvcc extends StatefulWidget {
  @override
  _MyAppcvccState createState() => _MyAppcvccState();
}

class _MyAppcvccState extends State<MyAppcvcc> {
  Map<String, List<List<dynamic>>> _data = {};
  DateTime startDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    // Calculate start and end dates for the last seven days
    DateTime endDate = DateTime.now();
    DateTime startDate = endDate.subtract(Duration(days: 40));

    // Format dates to YYYY-MM-DD for inclusion in the API URL
    String formattedStartDate = "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}";
    String formattedEndDate = "${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}";

    // Construct the API URL with dynamic start and end dates
    final Uri uri = Uri.parse('http://203.135.63.22:8000/data?username=ppjiq&mode=hour&start=$formattedStartDate&end=$formattedEndDate');

    try {
      // Perform the API request
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        // Parse the JSON response
        final jsonResponse = jsonDecode(response.body);
        final Map<String, dynamic> data = jsonResponse['data'];
        final Map<String, List<List<dynamic>>> processedData = {};

        // Process the data for each key that ends with '_[kW]'
        data.forEach((key, value) {
          if (key.endsWith('_[kW]')) {
            List<dynamic> listValues = value;
            List<List<dynamic>> chunks = [];
            for (var i = 0; i < listValues.length; i += 24) {
              List<dynamic> chunk = listValues.sublist(i, i + 24 > listValues.length ? listValues.length : i + 24);
              // If a chunk is empty, replace it with a list of 24 zeros
              if (chunk.isEmpty) {
                chunk = List.filled(24, 0.0); // Replace empty chunk with zeros
              }
              chunks.add(chunk);
            }
            processedData[key] = chunks;
          }
        });

        // Update the state with the processed data
        setState(() {
          _data = processedData;
        });
      } else {
        print('Failed to load data with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to load data with error: $e');
    }
  }



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Display kW Data with Dates'),
        ),
        body: ListView.builder(
          itemCount: _data.length,
          itemBuilder: (context, index) {
            String key = _data.keys.elementAt(index);
            List<List<dynamic>> dayChunks = _data[key]!;
            return ExpansionTile(
              title: Text(key),
              children: dayChunks.asMap().entries.map((entry) {
                int dayIndex = entry.key;
                List<dynamic> dayValues = entry.value;
                // Calculate the date for the current chunk
                DateTime chunkDate = startDate.add(Duration(days: dayIndex));
                String formattedDate = "${chunkDate.year}-${chunkDate.month.toString().padLeft(2, '0')}-${chunkDate.day.toString().padLeft(2, '0')}";
                return ListTile(
                  title: Text('Date: $formattedDate'),
                  subtitle: Text(dayValues.join(', ')),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}
