import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:highcharts_demo/screens/splashe_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controller/NotificationController/notification_time.dart';
import '../controller/NotificationController/toggle_controller.dart';
import '../controller/ThemeController.dart';
import '../controller/auth_controller/login_controller.dart';
import '../controller/datacontroller.dart';
import '../controller/historical/historicalcontroller.dart';

import '../screens/SummaryTab/this_month.dart';
import '../screens/SummaryTab/this_week.dart';

import '../today.dart';
import 'CustomText.dart';

class Sidedrawer extends StatelessWidget {
  const Sidedrawer({
    Key? key,
    required this.context,
  }) : super(key: key);

  final BuildContext context;

  Future<Map<String, String?>> getDrawerData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return {
      'displayName': prefs.getString('displayName'),
      'email': prefs.getString('email'),
    };
  }

  Future<void> clearAllSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all shared preferences data
  }

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.put(ThemeController());
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          FutureBuilder<Map<String, String?>>(
            future: getDrawerData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData) {
                return UserAccountsDrawerHeader(
                  accountName: Text(snapshot.data!['displayName'] ?? ''),
                  accountEmail: Text(snapshot.data!['email'] ?? ''),
                  currentAccountPicture: const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xff009F8D), // Replace with your desired color
                  ),
                );
              } else {
                // Display a loading indicator or placeholder
                return const DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                  child: Text('Loading...'),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.info,color: Color(0xff009F8D),),
            title: const Text('Info'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OrgChartScreen()),
              );
              // Close the drawer
            },
          ),
          ListTile(
            leading: const Icon(Icons.support_agent,color: Color(0xff009F8D)),
            trailing: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            title: const Text("Contact Support"),
            onTap: () => _showSupportContact(context),
          ),
          const SizedBox(
            height: 20,
          ),
          ListTile(
            leading: const Icon(Icons.settings,color: Color(0xff009F8D)),
            title: const Text('Setting'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
              // Close the drawer
            },
          ),
          ListTile(
            leading: Icon(Icons.logout,color: Color(0xff009F8D)),
            title: Text('Logout'),
            onTap: () async {
              final HistoricalController historicalController =
                  Get.put(HistoricalController());
              final DataControllers loginController =
                  Get.put(DataControllers());
              final WeekDataController weekDataController =
                  Get.put(WeekDataController());
              final DataControllerForThisMonth monthDataController =
                  Get.put(DataControllerForThisMonth());
              final LoginControllers loginControllers =
                  Get.put(LoginControllers());
              final NotificationController notificationController =
                  Get.put(NotificationController());
              Get.delete<LoginControllers>();
              Get.delete<HistoricalController>();
              Get.delete<
                  WeekDataController>(); // Clear the WeekDataController from memory
              Get.delete<DataControllerForThisMonth>();
              Get.delete<NotificationController>();

              // Reset the controllers' state
              notificationController.resetNotificationsOnLogout();
              loginControllers.resetloginController();
              loginController.resetloginController();
              historicalController.resetController();
              weekDataController
                  .resetController(); // Reset week data controller
              monthDataController.resetController();
              await clearAllSharedPreferences(); // Clear all SharedPreferences data

              // Navigate to the SplashScreen, and then immediately to the Login screen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => SplashScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final NotificationController controller = Get.put(NotificationController());
  final LimitController limitController = Get.put(LimitController());
  final TextEditingController textEditingController = TextEditingController();
  bool notificationsEnabled = false;
  String selectedHour = 'Not set';
  String notificationLimit = '';

  void _showHourPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select Hour"),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: 24,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text("$index:00"),
                  onTap: () {
                    controller.updateHour("$index:00");
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: CustomText(
            texts: 'Settings',
            textColor: const Color(0xff002F46),
          ),
        ),
        actions: [
          SizedBox(
            width: 40,
            height: 30,
            child: Image.asset('assets/images/Vector.png'),
          ),
        ],
      ),
      body: ListView(
        children: [
          SizedBox(height: 30),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 4,
            shadowColor: Color(0xff009F8D).withOpacity(0.5),
            margin: EdgeInsets.all(8),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.notifications_active, color: Color(0xff009F8D)),
                  title: Text("Enable Notifications", style: TextStyle(color: Color(0xff002F46))),
                  trailing: Obx(() => Switch(
                 //   activeColor: Color(0xff009F8D), // Color of the track when switch is active
                    activeTrackColor: Color(0xff009F8D),// Color of the thumb when switch is active
                    value: controller.notificationsEnabled.value,
                    onChanged: (bool value) {
                      controller.toggleNotifications(value);
                    },
                  )

                  ),
                )
              ],
            ),
          ),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 4,
            shadowColor: Color(0xff009F8D).withOpacity(0.5),
            margin: EdgeInsets.all(8),
            child: ListTile(
              leading: Icon(Icons.access_time, color: Color(0xff009F8D)),
              title: Text("Notification Hour", style: TextStyle(color: Color(0xff002F46))),
              subtitle: Obx(() => Text(controller.selectedHour.value)),
              onTap: () => _showHourPicker(context),
            ),
          ),
      Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 4,
        shadowColor: Color(0xff009F8D).withOpacity(0.5),
        margin: EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.settings, color: Color(0xff009F8D)),
                title: Text("Setting Notification Limit (kW)", style: TextStyle(color: Color(0xff002F46))),
                subtitle: TextField(
                  controller: textEditingController,
                  decoration: InputDecoration(
                    hintText: "Enter limit in kW",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              SizedBox(height: 10), // Adds some space between the text field and the button
              ElevatedButton(
                onPressed: () {
                  // Get the text from the TextEditingController and pass it to the updateLimit method
                  if (textEditingController.text.isNotEmpty) {
                    limitController.updateLimit(textEditingController.text);
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Color(0xff009F8D), // Button text color
                ),
                child: Text('Set'),
              ),
            ],
          ),
        ),
      ),
        ],
      ),
    );
  }
}

void _showSupportContact(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Contact Support"),
        content: RichText(
          text: const TextSpan(
            style: TextStyle(
              // Default text style
              color: Colors.black,
              fontSize: 16,
            ),
            children: [
              TextSpan(
                text: "For support, email us at ",
              ),
              TextSpan(
                text: "contact@energyinformatics.pk",
                style: TextStyle(
                  // Larger font for email
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: " or call us at ",
              ),
              TextSpan(
                text: "(92) 330 163 7589",
                style: TextStyle(
                  // Larger font for phone number
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: ".",
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text("OK"),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );
    },
  );
}

// class Sidedrawer extends StatelessWidget {
//   const Sidedrawer({
//     Key? key,
//     required this.context,
//   }) : super(key: key);
//
//   final BuildContext context;
//
//   Future<void> clearAllSharedPreferences() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.clear(); // Clear all shared preferences data
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       // Define your side drawer content here
//       child: ListView(
//         padding: EdgeInsets.zero,
//         children: [
//           DrawerHeader(
//             decoration: BoxDecoration(
//               color: Colors.blue,
//             ),
//             child: Text('Header'),
//           ),
//           ListTile(
//             title: Text('Setting'),
//             onTap: () {
//               // Handle item click in the drawer
//               Navigator.pop(context); // Close the drawer
//             },
//           ),
//           ListTile(
//             title: Text('Logout'),
//             onTap: () {
//               // Handle item click in the drawer
//               clearAllSharedPreferences().then((_) {
//                 // Close the drawer
//                 Navigator.pushReplacement( // Navigate to login screen after logout
//                   context,
//                   MaterialPageRoute(
//                     builder: (BuildContext context) => SplashScreen(),
//                   ),
//                 ).then((_) {
//                   // Ensure login screen navigation only if username is not empty
//                   SharedPreferences.getInstance().then((prefs) {
//                     String? storedUsername = prefs.getString('username');
//                     if (storedUsername == null || storedUsername.isEmpty) {
//                       Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(
//                           builder: (BuildContext context) => Login(),
//                         ),
//                       );
//                     }
//                   });
//                 });
//               });
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
// class Sidedrawer extends StatelessWidget {
//   const Sidedrawer({
//     Key? key,
//     required this.context,
//   }) : super(key: key);
//
//   final BuildContext context;
//
//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       // Define your side drawer content here
//       child: ListView(
//         padding: EdgeInsets.zero,
//         children: [
//           DrawerHeader(
//             decoration: BoxDecoration(
//               color: Colors.blue,
//             ),
//             child: Text(' Header'),
//           ),
//           ListTile(
//             title: Text('Setting'),
//             onTap: () {
//               // Handle item click in the drawer
//               Navigator.pop(context); // Close the drawer
//             },
//           ),
//           ListTile(
//             title: Text('Logout'),
//             onTap: () {
//               // Handle item click in the drawer
//               Navigator.pop(context); // Close the drawer
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get/get_core/src/get_main.dart';
// import 'package:highcharts_demo/screens/splashe_screen.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../controller/Summary_Controller/Data_for_this_month_controller.dart';
// import '../controller/Summary_Controller/Week_Data_Chart_Controller.dart';
// import '../controller/ThemeController.dart';
// import '../controller/datacontroller.dart';
// import '../controller/historical/historicalcontroller.dart';
// import '../orgnizationchart.dart';
// import '../screens/login.dart';
// import '../today.dart';
// class Sidedrawer extends StatelessWidget {
//   const Sidedrawer({
//     Key? key,
//     required this.context,
//   }) : super(key: key);
//
//   final BuildContext context;
//
//   Future<Map<String, String?>> getDrawerData() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return {
//       'displayName': prefs.getString('displayName'),
//       'email': prefs.getString('email'),
//     };
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final ThemeController themeController = Get.put(ThemeController());
//     return Drawer(
//       child: ListView(
//         padding: EdgeInsets.zero,
//         children: [
//           FutureBuilder<Map<String, String?>>(
//             future: getDrawerData(),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
//                 return UserAccountsDrawerHeader(
//                   accountName: Text(snapshot.data!['displayName'] ?? ''),
//                   accountEmail: Text(snapshot.data!['email'] ?? ''),
//                   currentAccountPicture: CircleAvatar(
//                     child: Icon(Icons.person),
//                   ),
//                 );
//               } else {
//                 // Display a loading indicator or placeholder
//                 return DrawerHeader(
//                   decoration: BoxDecoration(
//                     color: Colors.blue,
//                   ),
//                   child: Text('Loading...'),
//                 );
//               }
//             },
//           ),
//           ListTile(
//             title: Text('Info'),
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => OrgChartScreen()),
//               );
//               // Close the drawer
//             },
//           ),
//           ListTile(
//             title: Text("Contact Support"),
//             onTap: () => _showSupportContact(context),
//           ),
//           // ListTile(
//           //   leading: Icon(Icons.brightness_4), // Icon for theme toggle
//           //   title: Text('Toggle Dark Theme'),
//           //   onTap: () {
//           //     // Toggle the theme
//           //     themeController.toggleTheme();
//           //     Navigator.pop(context); // Close the drawer
//           //   },
//           // ),
//           SizedBox(
//             height: 20,
//           ),
//           ListTile(
//             title: Text('Setting'),
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => SettingsScreen()),
//               );
//               // Close the drawer
//             },
//           ),
//           ListTile(
//             title: Text('Logout'),
//             onTap: () async {
//               final HistoricalController historicalController = Get.put(HistoricalController());
//               final DataControllers LoginController = Get.put(DataControllers());
//
//               LoginController.resetloginController();
//               historicalController.resetController();
//               // Handle item click in the drawer
//             // Clear all SharedPreferences data
//               // Navigate to the SplashScreen, and then immediately to the Login screen
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(builder: (BuildContext context) => SplashScreen()),
//               );
//
//               // Optionally, if SplashScreen navigates based on SharedPreferences,
//               // directly navigate to Login screen instead:
//               // Navigator.pushReplacement(
//               //   context,
//               //   MaterialPageRoute(builder: (BuildContext context) => Login()),
//               // );
//             },
//           ),
//
//
//         ],
//       ),
//     );
//   }
// }
// class SettingsScreen extends StatefulWidget {
//   @override
//   _SettingsScreenState createState() => _SettingsScreenState();
// }
//
// class _SettingsScreenState extends State<SettingsScreen> {
//   bool notificationsEnabled = false;
//   String selectedHour = 'Not set';
//   String notificationLimit = '';
//
//   void _showHourPicker() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Select Hour"),
//           content: Container(
//             width: double.maxFinite,
//             child: ListView.builder(
//               shrinkWrap: true,
//               itemCount: 24,
//               itemBuilder: (BuildContext context, int index) {
//                 return ListTile(
//                   title: Text("$index:00"),
//                   onTap: () {
//                     setState(() {
//                       selectedHour = "$index:00";
//                     });
//                     Navigator.of(context).pop();
//                   },
//                 );
//               },
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Settings")),
//       body: ListView(
//         children: [
//           SwitchListTile(
//             title: Text("Enable Notifications"),
//             value: notificationsEnabled,
//             onChanged: (bool value) {
//               setState(() {
//                 notificationsEnabled = value;
//               });
//             },
//           ),
//           ListTile(
//             title: Text("Notification Hour"),
//             subtitle: Text(selectedHour),
//             onTap: _showHourPicker,
//           ),
//           ListTile(
//             title: Text("Setting Notification Limit (kW)"),
//             subtitle: TextField(
//               decoration: InputDecoration(
//                 hintText: "Enter limit in kW",
//               ),
//               keyboardType: TextInputType.numberWithOptions(decimal: true),
//               onChanged: (value) {
//                 notificationLimit = value;
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
// void _showSupportContact(BuildContext context) {
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: Text("Contact Support"),
//         content: RichText(
//           text: TextSpan(
//             style: TextStyle( // Default text style
//               color: Colors.black,
//               fontSize: 16,
//             ),
//             children: [
//               TextSpan(
//                 text: "For support, email us at ",
//               ),
//               TextSpan(
//                 text: "contact@energyinformatics.pk",
//                 style: TextStyle( // Larger font for email
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               TextSpan(
//                 text: " or call us at ",
//               ),
//               TextSpan(
//                 text: "(92) 330 163 7589",
//                 style: TextStyle( // Larger font for phone number
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               TextSpan(
//                 text: ".",
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             child: Text("OK"),
//             onPressed: () => Navigator.of(context).pop(),
//           ),
//         ],
//       );
//     },
//   );
// }
//
//
// // class Sidedrawer extends StatelessWidget {
// //   const Sidedrawer({
// //     Key? key,
// //     required this.context,
// //   }) : super(key: key);
// //
// //   final BuildContext context;
// //
// //   Future<void> clearAllSharedPreferences() async {
// //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //     await prefs.clear(); // Clear all shared preferences data
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Drawer(
// //       // Define your side drawer content here
// //       child: ListView(
// //         padding: EdgeInsets.zero,
// //         children: [
// //           DrawerHeader(
// //             decoration: BoxDecoration(
// //               color: Colors.blue,
// //             ),
// //             child: Text('Header'),
// //           ),
// //           ListTile(
// //             title: Text('Setting'),
// //             onTap: () {
// //               // Handle item click in the drawer
// //               Navigator.pop(context); // Close the drawer
// //             },
// //           ),
// //           ListTile(
// //             title: Text('Logout'),
// //             onTap: () {
// //               // Handle item click in the drawer
// //               clearAllSharedPreferences().then((_) {
// //                 // Close the drawer
// //                 Navigator.pushReplacement( // Navigate to login screen after logout
// //                   context,
// //                   MaterialPageRoute(
// //                     builder: (BuildContext context) => SplashScreen(),
// //                   ),
// //                 ).then((_) {
// //                   // Ensure login screen navigation only if username is not empty
// //                   SharedPreferences.getInstance().then((prefs) {
// //                     String? storedUsername = prefs.getString('username');
// //                     if (storedUsername == null || storedUsername.isEmpty) {
// //                       Navigator.pushReplacement(
// //                         context,
// //                         MaterialPageRoute(
// //                           builder: (BuildContext context) => Login(),
// //                         ),
// //                       );
// //                     }
// //                   });
// //                 });
// //               });
// //             },
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
//
// // import 'package:flutter/cupertino.dart';
// // import 'package:flutter/material.dart';
// //
// // class Sidedrawer extends StatelessWidget {
// //   const Sidedrawer({
// //     Key? key,
// //     required this.context,
// //   }) : super(key: key);
// //
// //   final BuildContext context;
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Drawer(
// //       // Define your side drawer content here
// //       child: ListView(
// //         padding: EdgeInsets.zero,
// //         children: [
// //           DrawerHeader(
// //             decoration: BoxDecoration(
// //               color: Colors.blue,
// //             ),
// //             child: Text(' Header'),
// //           ),
// //           ListTile(
// //             title: Text('Setting'),
// //             onTap: () {
// //               // Handle item click in the drawer
// //               Navigator.pop(context); // Close the drawer
// //             },
// //           ),
// //           ListTile(
// //             title: Text('Logout'),
// //             onTap: () {
// //               // Handle item click in the drawer
// //               Navigator.pop(context); // Close the drawer
// //             },
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
