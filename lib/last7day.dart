import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;



class MyDataDisplay extends StatefulWidget {
  @override
  _MyDataDisplayState createState() => _MyDataDisplayState();
}

class _MyDataDisplayState extends State<MyDataDisplay> {
  List<Map<String, dynamic>> kwData = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final username = 'ppjiq'; // replace with your actual username
    Set<String> processedDates = Set();

    try {
      for (int i = 6; i >= 0; i--) {
        DateTime currentDate = DateTime.now().subtract(Duration(days: i));
        String formattedDate = currentDate.toLocal().toString().split(' ')[0];

        if (processedDates.contains(formattedDate)) {
          continue;
        }

        try {
          final String apiUrl =
              "http://203.135.63.22:8000/data?username=$username&mode=hour&start=$formattedDate&end=$formattedDate";
          final response = await http.get(Uri.parse(apiUrl));

          if (response.statusCode == 200) {
            Map<String, dynamic> jsonData = json.decode(response.body);
            Map<String, dynamic> data = jsonData['data'];

            List<Map<String, dynamic>> newData = [];

            data.forEach((itemName, values) {
              if (itemName.endsWith("[kW]")) {
                String prefixName = itemName.substring(0, itemName.length - 4);
                List<double> numericValues =
                (values as List<dynamic>).map((value) {
                  if (value is num) {
                    return value.toDouble();
                  } else if (value is String) {
                    return double.tryParse(value) ?? 0.0;
                  } else {
                    return 0.0;
                  }
                }).toList();

                newData.add({
                  'prefixName': prefixName,
                  'values': numericValues,
                });
              }
            });

            kwData.add({'date': formattedDate, 'data': newData});
            processedDates.add(formattedDate);
            Map<String, dynamic> processJson(Map<String, dynamic> json) {
              if (json.containsKey("MainKw")) {
                double mainKwValue = (json["MainKw"] as List).last.toDouble();
                return {"MainKw": mainKwValue};
              } else {
                Map<String, dynamic> kwValues = {};
                json.forEach((key, value) {
                  if (key.endsWith("Kw")) {
                    kwValues[key] = (value as List).last.toDouble();
                  }
                });
                return kwValues;
              }
            }

            setState(() {
              data = processJson(jsonData);
              // Trigger a rebuild to update the UI with new data
            });
          } else {
            print(
                'Failed to fetch data for $formattedDate. Status code: ${response.statusCode}');
            print('Response body: ${response.body}');
          }
        } catch (error) {
          print('Error fetching data for $formattedDate: $error');
        }
      }
    } catch (error) {
      print('An unexpected error occurred: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: kwData.length!,
      itemBuilder: (context, index) {
        final data = kwData[index];
        final date = data['date'];
        final newData = data['data'];

        return Card(
          margin: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (data.containsKey("MainKw"))
                Text('MainKw: ${data["MainKw"]}'),
              if (data.isEmpty)
                CircularProgressIndicator()
              else
                ...data.entries.map((entry) => Text('${entry.key}: ${entry.value}')),
              // Padding(
              //   padding: const EdgeInsets.all(8.0),
              //   child: Text('Date: $date'),
              // ),
              // for (var item in newData)
              //   ListTile(
              //     title: Text('Name: ${item['prefixName']}'),
              //     subtitle: Text('Sum: ${(item['values'] as List<double>).reduce((a, b) => a + b)}'),
              //       ),
            ],
          ),
        );
      },
    );
  }
}
