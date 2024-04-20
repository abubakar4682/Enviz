import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';


class kWDataController extends GetxController {
  var isLoading = true.obs;
  var dailykWData = <String, Map<String, double>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchkWData();
  }

  void fetchkWData() async {
    DateTime endDate = DateTime.now();
    DateTime startDate = endDate.subtract(Duration(days: 7));
    String formattedEndDate = "${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}";
    String formattedStartDate = "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}";

    final uri = Uri.parse('http://203.135.63.47:8000/data?username=ppjiq&mode=hour&start=$formattedStartDate&end=$formattedEndDate');

    try {
      isLoading(true);
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = jsonDecode(response.body);
        Map<String, dynamic> data = jsonData['data'];
        var tempData = <String, Map<String, double>>{};

        List<DateTime> dateList = List.generate(
          endDate.difference(startDate).inDays + 1,
              (index) => DateTime(startDate.year, startDate.month, startDate.day + index),
        );

        for (DateTime date in dateList) {
          String dateString = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          tempData[dateString] = {};
          data.keys.where((k) => k.endsWith('_[kW]')).forEach((k) {
            tempData[dateString]![k] = 0.0;  // Initialize with zero
          });
        }

        data.forEach((key, values) {
          if (key.endsWith('_[kW]')) {
            for (int i = 0; i < values.length; i++) {
              String dateTime = data['Date & Time'][i];
              String date = dateTime.split(' ')[0];
              double value = 0.0;
              if (values[i] != null && values[i] != 'NA') {
                value = double.tryParse(values[i].toString()) ?? 0.0;
              }
              tempData[date]![key] = value;
            }
          }
        });

        dailykWData.assignAll(tempData);
      }
    } finally {
      isLoading(false);
    }
  }
}



class kWDataWidget extends StatelessWidget {
  final kWDataController controller = Get.put(kWDataController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Daily kW Data')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        } else {
          return ListView.builder(
            itemCount: controller.dailykWData.length,
            itemBuilder: (context, index) {
              String date = controller.dailykWData.keys.elementAt(index);
              return ExpansionTile(
                title: Text(date),
                children: controller.dailykWData[date]!.entries.map((entry) {
                  double kWhValue = entry.value / 1000;
                  return ListTile(
                    title: Text(entry.key),
                    trailing: Text('${kWhValue.toStringAsFixed(2)} kWh'),
                  );
                }).toList(),
              );
            },
          );
        }
      }),
    );
  }
}