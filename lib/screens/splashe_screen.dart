import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/bottom_navigation.dart';
import 'login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    redirectToNextScreen();
  }

  Future<void> redirectToNextScreen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUsername = prefs.getString('username');

    // Check if the username is stored and not empty
    if (storedUsername != null && storedUsername.isNotEmpty) {
      // If username is stored and not empty, redirect to home screen
      redirectToHomeScreen();
    } else {
      // If username is not stored or empty, redirect to login screen
      redirectToLoginScreen();
    }
  }

  void redirectToHomeScreen() {
    Timer(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => BottomPage(),
        ),
      );
    });
  }

  void redirectToLoginScreen() {
    Timer(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => Login(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    var deviceWidth = MediaQuery.of(context).size.width;
    var deviceHeight = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        body: Container(
          width: deviceWidth,
          height: deviceHeight,
          color: Colors.white,
          child: Center(
            child: SizedBox(
              width: 738,
              height: 266,
              child: Image.asset('assets/images/enfologo.png'),
            ),
          ),
        ),
      ),
    );
  }
}

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../widgets/bottom_navigation.dart';
// import 'login.dart';
//
// class SplashScreen extends StatefulWidget {
//   const SplashScreen({Key? key}) : super(key: key);
//
//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     redirectToNextScreen();
//   }
//
//   Future<void> redirectToNextScreen() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? storedUsername = prefs.getString('username');
//
//     // Check if the username is stored
//     if (storedUsername != null && storedUsername.isNotEmpty) {
//       // If username is stored, redirect to home screen
//       redirectToHomeScreen();
//     } else {
//       // If username is not stored, redirect to login screen
//       redirectToLoginScreen();
//     }
//   }
//
//   void redirectToHomeScreen() {
//     Timer(const Duration(seconds: 5), () {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (BuildContext context) => BottomPage(),
//         ),
//       );
//     });
//   }
//
//   void redirectToLoginScreen() {
//     Timer(const Duration(seconds: 5), () {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (BuildContext context) => Login(),
//         ),
//       );
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     var deviceWidth = MediaQuery.of(context).size.width;
//     var deviceHeight = MediaQuery.of(context).size.height;
//     return SafeArea(
//       child: Scaffold(
//         body: Container(
//           width: deviceWidth,
//           height: deviceHeight,
//           color: Colors.white,
//           child: Center(
//             child: SizedBox(
//               width: 738,
//               height: 266,
//               child: Image.asset('assets/images/enfologo.png'),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
//
// // import 'dart:async';
// // import 'package:flutter/material.dart';
// //
// // import 'login.dart';
// //
// //
// //
// // class Splashscreen extends StatefulWidget {
// //   const Splashscreen({Key? key}) : super(key: key);
// //
// //   @override
// //   State<Splashscreen> createState() => _SplashscreenState();
// // }
// //
// // class _SplashscreenState extends State<Splashscreen> {
// //
// //
// //   @override
// //   void initState() {
// //     Timer(const Duration(seconds: 5), () {
// //
// //       Navigator.push(
// //         context,
// //         MaterialPageRoute(
// //           builder: (BuildContext context) =>  Login(),
// //         ),
// //       );
// //     });
// //     super.initState();
// //
// //   }
// //
// //
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     var deviceWidth = MediaQuery.of(context).size.width;
// //     var deviceHeight = MediaQuery.of(context).size.height;
// //     return SafeArea(
// //       child: Scaffold(
// //         body: Container(
// //           width: deviceWidth,
// //           height: deviceHeight,
// //           color: Colors.white,
// //           child:Center(
// //             child:
// //             SizedBox(
// //               width:  738,
// //               height:  266,
// //               child: Image.asset('assets/images/enfologo.png'),
// //
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
