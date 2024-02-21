import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../controller/datacontroller.dart';
import 'CustomText.dart';

class MinAvgValueBox extends StatefulWidget {
  const MinAvgValueBox({
    Key? key,
  }) : super(key: key);

  @override
  State<MinAvgValueBox> createState() => _MinAvgValueBoxState();
}
class _MinAvgValueBoxState extends State<MinAvgValueBox> {
  final viewModel = Get.put(DataControllers());

  // Function to format the value into kilos
  String formatToKilo(double value) {
    if (value >= 1000) {
      // If the value is greater than or equal to 1000, format it as kilos
      return '${(value / 1000).toStringAsFixed(2)}kW';
    } else {
      // Otherwise, just return the original value
      return '${(value / 1000).toStringAsFixed(2)}kW';

        // value.toStringAsFixed(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: EdgeInsets.only(left: 10, right: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(() {
              if (viewModel.result.isNotEmpty) {
                return Row(

                  children: [
                    buildBox('Min :', viewModel.result[0], 'assets/images/Minus.png'),
                    SizedBox(
                      width: 10,
                    ),
                    buildBox('Max :', viewModel.result[1], 'assets/images/Plus.png'),
                    SizedBox(
                      width: 10,
                    ),
                    buildBox('Avg :', viewModel.result[2], 'assets/images/Disconnected.png'),
                  ],
                );
              } else {
                return SizedBox();
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget buildBox(String label, String value, String photoPath) {
    // Parse the value as double
    double parsedValue = double.parse(value);

    return Container(
height: 85,
      width: 120,
      decoration: BoxDecoration(
        color: Color(0xff002f46),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                style: TextStyle(
                    color: Color(0xff009f8d)
                ),
                ),

                SizedBox(
                  width: 20,
                  height: 20,
                  child: Image.asset(photoPath),
                ),
              ],
            ),
            Text(
              // Format the value using the formatToKilo function
              formatToKilo(parsedValue),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                height: 1.5,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// class _MinAvgValueBoxState extends State<MinAvgValueBox> {
//   final viewModel=Get.put(DataControllers());
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.only(left: 10, right: 10),
//       child: Row(
//         children: [
//           Obx(() {
//             if (viewModel.result.isNotEmpty) {
//               return Container(
//                 width: MediaQuery.of(context).size.width,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     buildBox('Min Value:', viewModel.result[0], 'assets/images/Minus.png'),
//                     buildBox('Max Value:', viewModel.result[1], 'assets/images/Plus.png'),
//                     buildBox('Average Value:', viewModel.result[2], 'assets/images/Disconnected.png'),
//                   ],
//                 ),
//               );
//             } else {
//               return SizedBox();
//             }
//           }),
//
//         ],
//       ),
//     );
//   }
//   Widget buildBox(String label, String value, String photoPath) {
//     return Container(
//         height: 100,
//         width: 140,
//
//         decoration: BoxDecoration(
//           color: Color(0xff002f46),
//           borderRadius: BorderRadius.circular(20),
//         ),
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 CustomText(
//                   texts: label,
//                   textColor: Color(0xff009f8d),
//                 ),
//                 SizedBox(
//                   width: 20,
//                   height: 20,
//                   child: Image.asset(
//                       photoPath
//                      ),
//                 ),
//               ],
//             ),
//             Text(
//               value,
//               style: const TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.w700,
//                 height: 1.5,
//                 color: Colors.white,
//               ),
//             ),
//           ],
//         ),
//       )
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
//
//
//       // Column(
//       //   children: [
//       //     Image.asset(
//       //       photoPath,
//       //       height: 60,
//       //       width: 60,
//       //       fit: BoxFit.cover,
//       //     ),
//       //     SizedBox(height: 8),
//       //     Text(label, style: TextStyle(color: Colors.white)),
//       //     SizedBox(height: 4),
//       //     Text(value, style: TextStyle(color: Colors.white)),
//       //   ],
//       // ),
//     );
//   }
//
// }