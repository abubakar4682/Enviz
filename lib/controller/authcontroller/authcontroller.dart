import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../data/exceptions/app_exceptions.dart';
import '../../repository/register_view_repo.dart';
import '../../widgets/bottom_navigation.dart';
import 'package:http/http.dart' as http;

class RegisterViewController extends GetxController {
  final repository = RegisterRepository();
  final usernamenameController = TextEditingController();

  final passwordController = TextEditingController();
//  RxList<Map<String, dynamic>> kwData = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> kwData = <Map<String, dynamic>>[].obs;
  final mobileFocusNode = FocusNode().obs;
  RxBool loading = false.obs;
 // late MyDataModel myDataModel;
  late TooltipBehavior _tooltip;
  RxString selectedStartDate = '2023-12-07'.obs;
  RxString selectedEndDate = '2023-12-07'.obs;
  RxList<double> mainKWData = <double>[].obs;
  RxList<double> mainAData = <double>[].obs;
  RxList<double> mainPFData = <double>[].obs;
  RxDouble sumMainKW = 0.0.obs;
  RxDouble sumMainA = 0.0.obs;
  RxDouble sumMainPF = 0.0.obs;
  RxDouble lastMainKWValue = 0.0.obs;
  RxInt touchedIndex = RxInt(-1);
  Map<String, dynamic> responseData = {};
  final RxInt selectedIndex = 0.obs;

  void updateIndex(int index) {
    final RxInt selectedIndex = 0.obs;
    selectedIndex.value = index;
  }

  // void UserRegister() {
  //   loading.value = true;
  //   final username = usernamenameController.text.toString();
  //   final password = passwordController.text;
  //
  //   if (username != null && password != null) {
  //     repository.registerApi(username, password).then((value) async {
  //       loading.value = false;
  //
  //       if (value['error'] == 'User not found') {
  //         if (Get.overlayContext != null) {
  //           Get.snackbar('Login Error', value['error']);
  //         }
  //       } else {
  //         if (Get.overlayContext != null) {
  //           Get.snackbar('Login', 'User Created Successfully');
  //           print(
  //             {'username': username, 'password': password},
  //           );
  //
  //           Get.to(() => BottomPage());
  //         }
  //       }
  //     }).onError((AppExceptions error, stackTrace) {
  //       loading.value = false;
  //       if (Get.overlayContext != null) {
  //         Get.snackbar('Error', error.message ?? '');
  //         print(error.message);
  //       }
  //     });
  //   } else {
  //     // Handle the case where either username or password is null
  //     loading.value = false;
  //     if (Get.overlayContext != null) {
  //       Get.snackbar('Error', 'Username or password is null.');
  //     }
  //   }
  // }
  void userRegister() {
    loading.value = true;
    final username = usernamenameController.text.toString();
    final password = passwordController.text;

    if (username != null && password != null && username.isNotEmpty && password.isNotEmpty) {
      repository.registerApi(username, password).then((value) async {
        loading.value = false;

        if (value != null && value['token'] != null) {
          Get.snackbar('Registration', 'User Created Successfully');
          // Access additional fields from the response if needed
          String token = value['token'];
          String displayName = value['client']['displayName'];

          print({'username': username, 'password': password, 'token': token, 'displayName': displayName});
          Get.to(() => BottomPage());
        } else if (value != null && value['error'] != null) {
          Get.snackbar('Registration Error', value['error']);
        } else {
          Get.snackbar('Registration Error', 'Unexpected response from the server');
        }
      }).onError((AppExceptions error, stackTrace) {
        loading.value = false;
        Get.snackbar('Error', error.message ?? '');
        print(error.message);
      });
    } else {
      loading.value = false;
      Get.snackbar('Error', 'Username or password is empty or null.');
    }
  }






  // Future<void> fetchData() async {
  //   DateTime now = DateTime.now();
  //   DateTime lastWeekStart = now.subtract(Duration(days: 7));
  //   final formattedStartDate = DateFormat('yyyy-MM-dd').format(lastWeekStart);
  //   final formattedEndDate = DateFormat('yyyy-MM-dd').format(now);
  //   final apiUrl =
  //       'http://203.135.63.22:8000/data?username=ahmad&mode=hour&start=$formattedStartDate&end=$formattedEndDate';
  //
  //   print(apiUrl);
  //
  //   try {
  //     final response = await http.get(Uri.parse(apiUrl));
  //
  //     if (response.statusCode == 200) {
  //       Map<String, dynamic> jsonData = json.decode(response.body);
  //       Map<String, dynamic> data = jsonData['data'];
  //
  //       List<Map<String, dynamic>> newData = [];
  //
  //       data.forEach((itemName, values) {
  //         if (itemName.endsWith("[kW]")) {
  //           String prefixName = itemName.substring(0, itemName.length - 4);
  //
  //           List<double> numericValues = (values as List<dynamic>).map((value) {
  //             if (value is num) {
  //               return value.toDouble();
  //             } else if (value is String) {
  //               return double.tryParse(value) ?? 0.0;
  //             } else {
  //               return 0.0;
  //             }
  //           }).toList();
  //
  //           newData.add({
  //             'prefixName': prefixName,
  //             'values': numericValues,
  //           });
  //         }
  //       });
  //
  //       kwData.assignAll(newData);
  //     } else {
  //       print('Failed to fetch data. Status code: ${response.statusCode}');
  //       print('Response body: ${response.body}');
  //     }
  //   } catch (error) {
  //     print('Error fetching data: $error');
  //   }
  // }


  Future<void> fetchData() async {
    Set<String> processedDates = Set();

    for (int i = 6; i >= 0; i--) {
      DateTime currentDate = DateTime.now().subtract(Duration(days: i));
      String formattedDate = currentDate.toLocal().toString().split(' ')[0];

      if (processedDates.contains(formattedDate)) {
        // Skip fetching if the date has already been processed
        continue;
      }

      final apiUrl =
          'http://203.135.63.22:8000/data?username=ppjp2isl&mode=hour&start=$formattedDate&end=$formattedDate';

      try {
        final response = await http.get(Uri.parse(apiUrl));

        if (response.statusCode == 200) {
          Map<String, dynamic> jsonData = json.decode(response.body);
          Map<String, dynamic> data = jsonData['data'];

          double lastMainKwValue = 0.0; // Variable to store the last MainKw value

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

              if (prefixName == 'MainKw' && numericValues.isNotEmpty) {
                lastMainKwValue = numericValues.last;
              }

              kwData.add({
                'prefixName': prefixName,
                'values': numericValues,
              });
            }
          });

          // Update kwData with the new data, including the last MainKw value
          kwData.add({'date': formattedDate, 'data': kwData, 'lastMainKw': lastMainKwValue});

          // Mark the date as processed to avoid duplicates
          processedDates.add(formattedDate);
        } else {
          print(
              'Failed to fetch data for $formattedDate. Status code: ${response.statusCode}');
          print('Response body: ${response.body}');
        }
      } catch (error) {
        print('Error fetching data for $formattedDate: $error');
      }
    }
  }



  @override
  void onInit() {
    fetchData();
    _tooltip = TooltipBehavior(enable: true);
    // TODO: implement onInit
    super.onInit();
  }
}
