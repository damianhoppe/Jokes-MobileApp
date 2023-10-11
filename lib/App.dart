import 'package:app_settings/app_settings.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class App {
  static final App _app = App._internal();

  static App getInstance() {
    return _app;
  }

  factory App() {
    return _app;
  }

  App._internal();

  late SharedPreferences preferences;

  init() async {
    await Firebase.initializeApp(
      options: FirebaseOptions(apiKey: "AIzaSyD1vzXW-GWagi5Gius4YlAauyMUS800HoQ", appId: "1:311859799774:android:44ae56beee7c1377ec844f", messagingSenderId: "311859799774", projectId: "jokes-6e768"),
    );
    this.preferences = await SharedPreferences.getInstance();
  }
}

toggleNotifications(bool enabled, BuildContext? context) async {
  FirebaseMessaging fcm = FirebaseMessaging.instance;
  if(enabled) {
    PermissionStatus status = await Permission.notification.isGranted.then((
        value) async {
      if (!value) {
        return await Permission.notification.request();
      }
      return PermissionStatus.granted;
    });
    if(status.isGranted) {
      fcm.subscribeToTopic("dailyVote");
    }else {
      fcm.unsubscribeFromTopic("dailyVote");
    }
    if(enabled && context != null && status.isPermanentlyDenied) {
      if(context.mounted) {
        show(context);
      }
    }
  }
}

show(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    duration: Duration(seconds: 3),
    dismissDirection: DismissDirection.down,
    behavior: SnackBarBehavior.floating,
    content: Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: Text("Musisz przejść do ustawień, aby zezwolić na powiadomienia."),
        ),
        TextButton(child: Text("Ustawienia", style: TextStyle(color: Theme.of(context).colorScheme.primaryContainer),), onPressed: () {
          ScaffoldMessenger.of(context).clearSnackBars();
          AppSettings.openAppSettings(type: AppSettingsType.notification);
        }),
      ],
    ),
  ));
}

extension StartAnimateWidgetExtensions on Widget {
  startAnimate({
    withDelay = false,
    Duration duration = const Duration(milliseconds: 400),
    double moveYBegin = 0.0,
  }) =>
      animate().fadeIn(curve: Curves.easeOut, delay: Duration(milliseconds: withDelay? 0 : 0), duration: duration).moveY(begin: moveYBegin, end: 0);
}