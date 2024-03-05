import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AlertService {
  String? mtoken = " ";
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  AlertService() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  }

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

    if(settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    }
    else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    }
    else {
      print('User declined or has not accepted permission');
    }
  }

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


  void saveToken(String token) async {
    await FirebaseFirestore.instance.collection("token").doc(token).set(
      {'token': token},
      SetOptions(merge: true),
    );
  }

  void sendPushMessage(String token, String body, String title) async {
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'AAAAPmjwZ20:APA91bFBKPVycQDt7JsHpn6DKe1co3f5aC4IUMQfW3ZWV08IepPz_U5ffHZs0oWY69b-2uc8N56EiDGehhc-tWKZsb4RaJQr0LVpeDByXY7iu5lmznZ4hZObVMTEdyWjOK4Dx-jzzhaU'
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
            }
          },
        ),
      );
    } catch (e) {
      print("Error sending push message: $e");
    }
  }
}
