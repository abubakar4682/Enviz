import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:highcharts_demo/screens/splashe_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controller/ThemeController.dart';
import '../controller/datacontroller.dart';
import '../controller/historical/historicalcontroller.dart';
import '../orgnizationchart.dart';
import '../screens/login.dart';
import '../today.dart';
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
              if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                return UserAccountsDrawerHeader(
                  accountName: Text(snapshot.data!['displayName'] ?? ''),
                  accountEmail: Text(snapshot.data!['email'] ?? ''),
                  currentAccountPicture: CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                );
              } else {
                // Display a loading indicator or placeholder
                return DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                  child: Text('Loading...'),
                );
              }
            },
          ),
          ListTile(
            title: Text('Info'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OrgChartScreen()),
              );
              // Close the drawer
            },
          ),
          ListTile(
            title: Text("Contact Support"),
            onTap: () => _showSupportContact(context),
          ),
          // ListTile(
          //   leading: Icon(Icons.brightness_4), // Icon for theme toggle
          //   title: Text('Toggle Dark Theme'),
          //   onTap: () {
          //     // Toggle the theme
          //     themeController.toggleTheme();
          //     Navigator.pop(context); // Close the drawer
          //   },
          // ),
          SizedBox(
            height: 20,
          ),
          ListTile(
            title: Text('Setting'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
              // Close the drawer
            },
          ),
          ListTile(
            title: Text('Logout'),
            onTap: () async {
              final HistoricalController historicalController = Get.put(HistoricalController());
              final DataControllers LoginController = Get.put(DataControllers());
              Get.delete<HistoricalController>();
              // Reset the controller's state

              LoginController.resetloginController();
              historicalController.resetController();
              // Handle item click in the drawer
              await clearAllSharedPreferences(); // Clear all SharedPreferences data
              // Navigate to the SplashScreen, and then immediately to the Login screen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (BuildContext context) => SplashScreen()),
              );

              // Optionally, if SplashScreen navigates based on SharedPreferences,
              // directly navigate to Login screen instead:
              // Navigator.pushReplacement(
              //   context,
              //   MaterialPageRoute(builder: (BuildContext context) => Login()),
              // );
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
  bool notificationsEnabled = false;
  String selectedHour = 'Not set';
  String notificationLimit = '';

  void _showHourPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select Hour"),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: 24,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text("$index:00"),
                  onTap: () {
                    setState(() {
                      selectedHour = "$index:00";
                    });
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
      appBar: AppBar(title: Text("Settings")),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text("Enable Notifications"),
            value: notificationsEnabled,
            onChanged: (bool value) {
              setState(() {
                notificationsEnabled = value;
              });
            },
          ),
          ListTile(
            title: Text("Notification Hour"),
            subtitle: Text(selectedHour),
            onTap: _showHourPicker,
          ),
          ListTile(
            title: Text("Setting Notification Limit (kW)"),
            subtitle: TextField(
              decoration: InputDecoration(
                hintText: "Enter limit in kW",
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) {
                notificationLimit = value;
              },
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
        title: Text("Contact Support"),
        content: RichText(
          text: TextSpan(
            style: TextStyle( // Default text style
              color: Colors.black,
              fontSize: 16,
            ),
            children: [
              TextSpan(
                text: "For support, email us at ",
              ),
              TextSpan(
                text: "contact@energyinformatics.pk",
                style: TextStyle( // Larger font for email
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: " or call us at ",
              ),
              TextSpan(
                text: "(92) 330 163 7589",
                style: TextStyle( // Larger font for phone number
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