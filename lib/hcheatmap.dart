import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter/material.dart';


// Adjust this import as necessary
class KeyValuesController extends GetxController {
  var isLoading = false.obs;
  var organizedData = <String, Map<String, List<dynamic>>>{}.obs;
  var startDate = DateTime.now().obs;
  var endDate = DateTime.now().obs;

  Future<void> fetchKeys() async {
    isLoading(true);
    final response = await http
        .get(Uri.parse('http://203.135.63.22:8000/buildingmap?username=ahmad'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      List<String> keys = data.containsKey('Main')
          ? ['Main_[kW]']
          : data.keys.map((key) => '$key\_[kW]').toList();
      fetchFilteredData(keys);
    } else {
      isLoading(false);
      throw Exception('Failed to load keys');
    }
  }

  Future<void> fetchFilteredData(List<String> keys) async {
    final String formattedStartDate =
        '${startDate.value.year}-${startDate.value.month.toString().padLeft(2, '0')}-${startDate.value.day.toString().padLeft(2, '0')}';
    final String formattedEndDate =
        '${endDate.value.year}-${endDate.value.month.toString().padLeft(2, '0')}-${endDate.value.day.toString().padLeft(2, '0')}';
    final response = await http.get(Uri.parse(
        'http://203.135.63.22:8000/data?username=ahmad&mode=hour&start=$formattedStartDate&end=$formattedEndDate'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body)['data'];
      Map<String, Map<String, List<dynamic>>> tempOrganizedData = {};
      DateTime current = startDate.value;

      while (current.isBefore(endDate.value.add(Duration(days: 1)))) {
        String dateKey =
            '${current.year}-${current.month.toString().padLeft(2, '0')}-${current.day.toString().padLeft(2, '0')}';
        Map<String, List<dynamic>> dayData = {};

        for (String key in keys) {
          if (data.containsKey(key) && data[key] is List) {
            // Process each value in the list
            List<dynamic> processedList = data[key].map((value) {
              if (value == 'NA' || value == null) return 0;
              return value;
            }).toList();

            // If the list is empty or not long enough, fill with zeros
            if (processedList.isEmpty || processedList.length < 24) {
              processedList = List.filled(24, 0);
            } else {
              // Ensure to get up to the first 24 hours safely
              int endRange =
                  processedList.length < 24 ? processedList.length : 24;
              processedList = processedList.sublist(0, endRange);
            }

            // If there are more than 24 elements, prepare the remainder for the next day
            if (data[key].length > 24)
              data[key] = data[key].sublist(24);
            else
              data[key]
                  .clear(); // Clear the list if fewer than 24 to prevent reuse on the next iteration

            dayData[key] = processedList;
          }
        }

        tempOrganizedData[dateKey] = dayData;
        current = current.add(Duration(days: 1));
      }

      organizedData.assignAll(tempOrganizedData);
    } else {
      throw Exception('Failed to load filtered data');
    }
    isLoading(false);
  }
}

class Home extends StatelessWidget {
  final KeyValuesController controller = Get.put(KeyValuesController());

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate:
            isStartDate ? controller.startDate.value : controller.endDate.value,
        firstDate: DateTime(2000),
        lastDate: DateTime(2025));

    if (pickedDate != null) {
      if (isStartDate) {
        controller.startDate(pickedDate);
      } else {
        controller.endDate(pickedDate);
        controller
            .fetchKeys(); // Trigger data refresh only after the end date is selected
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Viewer'),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => _selectDate(context, true),
                child: Text('Start Date'),
              ),
              ElevatedButton(
                onPressed: () => _selectDate(context, false),
                child: Text('End Date'),
              ),
            ],
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              } else {
                return ListView.builder(
                    itemCount: controller.organizedData.keys.length,
                    itemBuilder: (context, index) {
                      String date =
                          controller.organizedData.keys.elementAt(index);
                      Map<String, List<dynamic>> dayData =
                          controller.organizedData[date]!;
                      return ExpansionTile(
                        title: Text(date),
                        children: dayData.entries.map((entry) {
                          return ListTile(
                            title: Text(entry.key),
                            subtitle: Text(entry.value.join(", ")),
                          );
                        }).toList(),
                      );
                    });
              }
            }),
          ),
        ],
      ),
    );
  }
}
