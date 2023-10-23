import 'dart:io';
import 'dart:math';

import 'package:app_settings/app_settings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:myoga/services/views/My_Orders/my_orders_screen.dart';
import 'package:myoga/services/views/driverFound.dart';
import 'package:myoga/services/views/ratingScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();

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
    if(settings.authorizationStatus == AuthorizationStatus.authorized){

    } else if(settings.authorizationStatus == AuthorizationStatus.provisional){

    } else {
      AppSettings.openNotificationSettings();
    }
  }

  void initLocalNotification(BuildContext context, RemoteMessage message) async {
    var androidInitializationSettings = const AndroidInitializationSettings("my_oga_noti_icon");
    var iOSInitializationSettings = const DarwinInitializationSettings();

    var initializationSettings = InitializationSettings(
        android: androidInitializationSettings, iOS: iOSInitializationSettings);

    await notificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (payload) async {
              handleMessage(context, message);
        });
  }


  void firebaseInit(BuildContext context){

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print("........onMessage......");
        print("onMessage: ${message.notification?.title}/${message.notification?.body}");
      }

      if(Platform.isAndroid){
        initLocalNotification(context, message);
        showNotification(message);
      } else {
        showNotification(message);
      }
    });
  }

  Future<void> showNotification(RemoteMessage message) async {

    AndroidNotificationChannel channel = AndroidNotificationChannel(
        Random.secure().nextInt(10000).toString(),
        "MyOga_Send_Me",
        importance: Importance.max,
    );

    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      channel.id.toString(),
      channel.name.toString(),
      importance: Importance.high,
      channelDescription: "Your channel description",
      priority: Priority.high,
      playSound: true,
      ticker: 'ticker'
    );

    const DarwinNotificationDetails darwinNotificationDetails = DarwinNotificationDetails(
        presentAlert: true,
      presentBadge: true,
      presentSound: true
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
    );

    Future.delayed(Duration.zero,() {
      notificationsPlugin.show(
          0,
          message.notification?.title.toString(),
          message.notification?.body.toString(),
          notificationDetails);
    });
  }

  Future<String>getDeviceToken()async{
    String? token = await messaging.getToken();
    return token!;
  }

  void isTokenRefresh()async{
    messaging.onTokenRefresh.listen((event) {
      event.toString();
    });
  }

  Future<void> setUpInteractMessage(BuildContext context) async{

    ///When appis terminated
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if(initialMessage != null){
      handleMessage(context, initialMessage);
    }

    ///When app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      handleMessage(context, event);
    });
  }

  void handleMessage(BuildContext context, RemoteMessage message){
    if(message.data['type'] == 'DRIVER_FOUND'){
      Navigator.push(context, MaterialPageRoute(builder: (context) => DriverFoundScreen(
        dId: message.data['dId'], bNum: message.data['bookingNumber'],
      )));
    } else if(message.data['type'] == 'ORDER_STATUS'){
      Navigator.push(context, MaterialPageRoute(builder: (context) => MyOrdersScreen()));
    } else if(message.data['type'] == 'ORDER_COMPLETED'){
      Navigator.push(context, MaterialPageRoute(builder: (context) =>RatingScreen(
        driverID: message.data['dId'],
      )));
    }
  }

  Future<void> initNotification() async {

    AndroidInitializationSettings initializationSettingsAndroid =
        const AndroidInitializationSettings("my_oga_noti_icon");

    var initializationSettingsIOS =  DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification:
        (int id, String? title, String? body, String? payload )async {});

    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await notificationsPlugin.initialize(initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {});

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (kDebugMode) {
        print("........onMessage......");
        print("onMessage: ${message.notification?.title}/${message.notification?.body}");
      }

      BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
        message.notification!.body.toString(), htmlFormatBigText: true,
        contentTitle: message.notification!.title.toString(), htmlFormatContentTitle: true,
      );
      AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
          "MyOga_Send_Me", "MyOga_Send_Me", importance: Importance.max,
        styleInformation: bigTextStyleInformation, priority: Priority.max, playSound: true,
      );
      NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics, iOS: const DarwinNotificationDetails());
      await notificationsPlugin.show(0, message.notification?.title, message.notification?.body, platformChannelSpecifics, payload: message.data['body']);
    });

  }

  notificationDetails(){
    return const NotificationDetails(
      android: AndroidNotificationDetails('channelId', 'channelName',
        importance: Importance.max),
      iOS: DarwinNotificationDetails()
    );
  }

 // Future showNotification(
  //{int id=0, String? title, String? body, String? payload }) async {
  //  return notificationsPlugin.show(id, title, body, await notificationDetails());
  //}

}