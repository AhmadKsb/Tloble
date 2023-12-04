import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce_app/src/pages/feedback/feedback_details_screen.dart';
import 'package:flutter_ecommerce_app/src/pages/orders/all_orders_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_ecommerce_app/src/models/feedback.dart' as Feedback;

/// FirebaseNotification widget
class FirebaseNotification extends StatefulWidget {
  /// Child widget.
  final Widget child;

  /// Creates FirebaseNotification widget.
  const FirebaseNotification({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  _FirebaseNotificationState createState() => _FirebaseNotificationState();
}

class _FirebaseNotificationState extends State<FirebaseNotification> {
  final _firebaseMessaging = FirebaseMessaging.instance;
  FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;
  String? token;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() async {
    token = await _firebaseMessaging.getToken();
    _initFireBase();
    initLocalNotifications();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> _initFireBase() async {
    final settings = await FirebaseMessaging.instance.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      FirebaseMessaging.onMessage.listen(
        (message) => showLocalNotification(
          title: message.notification?.title,
          message: message.notification?.body,
          messagePayload: message.data,
        ),
      );
      FirebaseMessaging.onMessageOpenedApp.listen(
        (message) => _openAlerts(message.data),
      );
      final initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        _openAlerts(initialMessage.data);
      }
    }

    getPushNotificationToken();
    // // _firebaseMessaging.configure(
    // //   onMessage: (message) async {
    // //     showLocalNotification(message);
    // //   },
    // //   onLaunch: (message) async {
    // //     _openAlerts(message);
    // //   },
    // //   onResume: (message) async {
    // //     _openAlerts(message);
    // //   },
    // // );
    //
    // requestPermission();
    //
    // // _firebaseMessaging.onIosSettingsRegistered.listen(
    // //   (settings) {
    // //     getPushNotificationToken();
    // //   },
    // // );
    // getPushNotificationToken();
  }

  Future<String?> getPushNotificationToken() async {
    var token = await _firebaseMessaging.getToken();
    return token;
  }

  void showLocalNotification({
    @required String? title,
    @required String? message,
    @required Map<String, dynamic>? messagePayload,
  }) async {
    try {
      Vibration.vibrate();
    } catch (e) {}
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'Notification',
      'Notification',
      // 'Notification',
      importance: Importance.high,
      priority: Priority.max,
      ticker: 'ticker',
    );
    var iOSPlatformChannelSpecifics = DarwinNotificationDetails(
      presentSound: true,
      presentAlert: true,
      presentBadge: true,
    );

    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    // var notificationBody = Platform.isIOS
    //     ? messagePayload['aps'] ?? message
    //     : messagePayload['notification'] ?? message;

    await flutterLocalNotificationsPlugin?.show(
      0,
      title,
      message,
      platformChannelSpecifics,
      payload: json.encode(messagePayload),
    );
  }

  Future<NotificationSettings> requestPermission() async {
    return FirebaseMessaging.instance.requestPermission(
      sound: true,
      badge: true,
      alert: true,
    );
  }

  void initLocalNotifications() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    var initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/ic_notification');

    var initializationSettingsIOS = DarwinInitializationSettings(
      onDidReceiveLocalNotification: onDidReceiveLocalNotification,
    );

    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    flutterLocalNotificationsPlugin?.initialize(
      initializationSettings,
      // onSelectNotification: onSelectNotification,
    );
  }

  void _openAlerts(Map<String, dynamic> message) async {
    var data = (message != null ? message['data'] : null) ?? message;
    SharedPreferences prefs = await SharedPreferences.getInstance();

    print(data['productsTitles'].runtimeType);

    if (message.containsKey('notificationSentToCustomer')
        ? data['notificationSentToCustomer'] == 'true'
        : false) return;

    if ((data['feedback'] != null) &&
        (prefs
                .getStringList('tloble_feedback_receivers')
                ?.contains(FirebaseAuth.instance.currentUser?.phoneNumber) ??
            false)) {
      Feedback.Feedback feedback = Feedback.Feedback.fromJson(data);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => FeedbackDetailsScreen(
            feedback: feedback,
          ),
        ),
      );
    }

    if (data['phoneNumber'] != null &&
        data['customerName'] != null &&
        (prefs
                .getStringList('tloble_employees')
                ?.contains(FirebaseAuth.instance.currentUser?.phoneNumber) ??
            false)) {
      // Order order = Orders.fromJson(data);

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AllOrdersScreen(
              // order: order,
              ),
        ),
      );
    }
  }

  Future<void> onSelectNotification(String? payload) {
    Map<String, dynamic> message = json.decode(payload ?? "");
    _openAlerts(message);
    return Future.value(true);
  }

  Future<void> onDidReceiveLocalNotification(
    int? id,
    String? title,
    String? body,
    String? payload,
  ) async {
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
