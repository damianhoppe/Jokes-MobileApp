import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jokes/pages/web/WebHomePage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'App.dart';
import 'pages/HomePage.dart';
import 'pages/FirstConfigurationPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await App().init();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) => context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  final App app = App();
  late SharedPreferences preferences;
  ThemeMode _themeMode = ThemeMode.system;

  _MyAppState() {
    preferences = app.preferences;
    if(preferences.getInt("theme") != null) {
      switch (preferences.getInt("theme")) {
        case 1:
          _themeMode = ThemeMode.light;
          break;
        case 2:
          _themeMode = ThemeMode.dark;
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jokes',
      themeMode: _themeMode,
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent, brightness: Brightness.dark),
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      home: _homePage(),
    );
  }

  _homePage() {
    if(kIsWeb) {
      return const WebHomePage();
    }
    if(preferences.getBool("firstConfiguration") == null) {
      return FirstConfigurationPage();
    }
    return const HomePage();
  }

  changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }
}