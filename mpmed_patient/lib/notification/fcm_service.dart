import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:mpmed_patient/authOtp/pages/splash_page.dart';
import 'package:mpmed_patient/documents/screens/document_item_screen.dart';
import 'package:mpmed_patient/documents/screens/documents_screen.dart';
import 'package:mpmed_patient/one_question/screen/one_question_item.dart';

import '../main.dart';
import 'notification_bloc.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'custom_notification_channel_id',
  'Notification',
  description: 'notifications from Your App Name.',
  importance: Importance.high,
);

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void setupFcm() async {
  await Firebase.initializeApp();
  getFcmToken().then((value) => print(value.toString()));
  var initializationSettingsAndroid =
      const AndroidInitializationSettings('@drawable/ic_notification');
  var initializationSettingsIOs = const IOSInitializationSettings();
  var initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOs,
  );

  //when the app is in foreground state and you click on notification.
  flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (payload) {
    if (payload != null) {
      Map<String, dynamic> data = json.decode(payload);
      goToNextScreen(data);
    }
  });

  //When the app is terminated, i.e., app is neither in foreground or background.
  FirebaseMessaging.instance.getInitialMessage().then((message) {
    if (message != null) {
      goToNextScreen(message.data);
    }
  });

  //When the app is in the background, but not terminated.
  FirebaseMessaging.onMessageOpenedApp.listen(
    (event) {
      goToNextScreen(event.data);
    },
    cancelOnError: false,
    onDone: () {},
  );

  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      print('FCM recived');
      Map map = message.data;
      map.forEach((key, value) {
        print('key==$key--value==$value');
      });

      if (message.data != null) {
        print('refreshing just started !!!!!');
        final notification = LocalNotification("data", message.data);
        NotificationsBloc.instance.newNotification(notification);
      }

      if (android.imageUrl != null && android.imageUrl!.trim().isNotEmpty) {
        final String largeIcon = await _base64encodedImage(
          android.imageUrl.toString(),
        );

        final BigPictureStyleInformation bigPictureStyleInformation =
            BigPictureStyleInformation(
          ByteArrayAndroidBitmap.fromBase64String(largeIcon),
          largeIcon: ByteArrayAndroidBitmap.fromBase64String(largeIcon),
          contentTitle: notification.title,
          htmlFormatContentTitle: true,
          summaryText: notification.body,
          htmlFormatSummaryText: true,
          hideExpandedLargeIcon: true,
        );

        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: null,
              color: Colors.red,
              importance: Importance.max,
              priority: Priority.high,
              largeIcon: ByteArrayAndroidBitmap.fromBase64String(largeIcon),
              styleInformation: bigPictureStyleInformation,
            ),
          ),
          payload: json.encode(message.data),
        );
      } else {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: null,
              color: Colors.red,
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
          payload: json.encode(message.data),
        );
      }
    }
  });
}

Future<void> deleteFcmToken() async {
  return await FirebaseMessaging.instance.deleteToken();
}

Future<String> getFcmToken() async {
  String? token = await FirebaseMessaging.instance.getToken();
  return Future.value(token);
}

_base64encodedImage(String url) async {
  http.Response response = await http.get(Uri.parse(url));
  String base64String = base64Encode(response.bodyBytes);
  return base64String;
}

void goToNextScreen(Map<String, dynamic> data) {
  data.forEach((key, value) {
    print('$key---$value');
  });
  if (data['click_action'] != null) {
    switch (data['click_action']) {
      case "review_screen":
        navigatorKey.currentState!.pushNamedAndRemoveUntil(
            DocumentItemScreen.routeName, (Route<dynamic> route) => false,
            arguments: data['arguments']);
        break;
      case "question_screen":
        navigatorKey.currentState!.pushNamedAndRemoveUntil(
            QuestionItemScreen.routeName, (Route<dynamic> route) => false,
            arguments: data['arguments']);
        break;
    }
    return;
  }
  //If the payload is empty or no click_action key found then go to Notification Screen if your app has one.
  navigatorKey.currentState!.pushNamed(
    SplashPage.routeName,
  );
}
