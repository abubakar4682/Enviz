import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:highcharts_demo/screens/splashe_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controller/ThemeController.dart';
import '../screens/login.dart';
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
            title: Text('Setting'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
            },
          ),
          ListTile(
            leading: Icon(Icons.brightness_4), // Icon for theme toggle
            title: Text('Toggle Dark Theme'),
            onTap: () {
              // Toggle the theme
              themeController.toggleTheme();
              Navigator.pop(context); // Close the drawer
            },
          ),
          ListTile(
            title: Text('Logout'),
            onTap: () {
              // Handle item click in the drawer
              clearAllSharedPreferences().then((_) {
                // Close the drawer
                Navigator.pushReplacement( // Navigate to login screen after logout
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => SplashScreen(),
                  ),
                ).then((_) {
                  // Ensure login screen navigation only if username is not empty
                  SharedPreferences.getInstance().then((prefs) {
                    String? storedUsername = prefs.getString('username');
                    if (storedUsername == null || storedUsername.isEmpty) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => Login(),
                        ),
                      );
                    }
                  });
                });
              });
            },
          ),
        ],
      ),
    );
  }
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