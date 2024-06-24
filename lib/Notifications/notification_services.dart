import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/foundation.dart';

class NotificationServices {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  void requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    if (kDebugMode) {
      print('Authorization status: ${settings.authorizationStatus}');
    }
  }

  void firebaseInit() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        // If the app is in the foreground, handle notification here
        print('Title: ${message.notification!.title}');
        print('Body: ${message.notification!.body}');
      }
    });

    // Handling notifications when they are tapped by the user and the app opens from a killed state
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message clicked! Message ID: ${message.messageId}');
    });
  }

  Future<String> getDeviceToken() async {
    String? token = await messaging.getToken();
    if (token == null) throw Exception('Device token is null');
    return token;
  }

  void isTokenRefresh() {
    messaging.onTokenRefresh.listen((token) {
      if (kDebugMode) {
        print('Token refreshed: $token');
      }
    });
  }
}
