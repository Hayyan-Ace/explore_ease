import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class AlertService {
  String? mtoken = " ";
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AlertService() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    _initializeNotifications();
  }

  // Initialize notifications
  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('app_icon');
    final InitializationSettings initializationSettings =
    const InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      // onSelectNotification: (String? payload) async {
      //   // Handle notification when user taps on it
      //   debugPrint("Notification tapped: $payload");
      // },
    );
  }

  // Function to show local notification
  Future<void> showLocalNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      title,
      body,
      platformChannelSpecifics,
    );
  }

  // Function to show foreground notification
  void showForegroundNotification(String title, String body) {
    flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'foreground channel id',
          'foreground channel name',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  // Function to request permission for receiving notifications
  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  // Function to get the FCM token
  void getToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        mtoken = token;
        print("My token is $mtoken");
        saveToken(token);
      } else {
        print("Failed to get token");
      }
    } catch (e) {
      print("Error getting token: $e");
    }
  }

  // Function to save the FCM token in Firestore
  void saveToken(String token) async {
    try {
      String? userId = await getCurrentUserId();
      if (userId != null) {
        DocumentReference userDocRef =
        FirebaseFirestore.instance.collection("users").doc(userId);
        await userDocRef.set(
          {'token': token},
          SetOptions(merge: true),
        );
        print('Token saved successfully for user: $userId');
      } else {
        print('Failed to save token: User not authenticated.');
      }
    } catch (e) {
      print("Error saving token: $e");
    }
  }

  // Function to send push message
  void sendPushMessage(String token, String body, String title) async {
    try {
      http.Response response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
          'key=AAAAPmjwZ20:APA91bENs_L0NlUiQ8FoFt-d7re_6t-kWKPiZZy-KNJFCuZTB6U0cwQqGlCh0fNfnogFrqfb36Ubz1MGQ37Di2vNuzz_vxZ6HiLDoOjxaQRX_DRQsXxL7Y8uVwqsZn62BBe5bXFoxLx9',
        },
        body: jsonEncode(
          <String, dynamic>{
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'status': 'done',
              'body': body,
              'title': title,
            },
            "notification": <String, dynamic>{
              "title": title,
              "body": body,
            },
            "to": token,
          },
        ),
      );

      print("FCM Server Response: ${response.body}");
    } catch (e) {
      print("Error sending push message: $e");
    }
  }

  // Function to get current user ID
  Future<String?> getCurrentUserId() async {
    User? user = _auth.currentUser;
    if (user != null) {
      return user.uid;
    }
    return null;
  }
}
