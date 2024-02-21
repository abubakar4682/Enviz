import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller/datacontroller.dart';

class YourWidget extends StatelessWidget {
  final summaryController = Get.put(DataControllers());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your App Title'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Other widgets...

            // Display lastMainKWValue using Obx
            Obx(() {
              return Text(
                'Last Main KW Value: ${summaryController.lastMainKWValue}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              );
            }),

            // Other widgets...
          ],
        ),
      ),
    );
  }
}
