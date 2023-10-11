import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jokes/main.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:settings_ui/settings_ui.dart';

import '../App.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final preferences = App.getInstance().preferences;
  int pageIndex = 0;
  final _nameFieldController = TextEditingController();

  @override
  void initState() {
    _nameFieldController.text = preferences.getString("name") ?? "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: ValueKey<int>(1),
      padding: EdgeInsets.only(top: 12, bottom: 0),
      child: Column(
          children: [
            AppBar(
              title: Text("Ustawienia",),
            ),
            Expanded(
              child: SettingsList(
                  lightTheme: SettingsThemeData(
                    settingsListBackground: Colors.transparent,
                    settingsSectionBackground: Colors.transparent,
                  ),
                  darkTheme: SettingsThemeData(
                    settingsListBackground: Colors.transparent,
                    settingsSectionBackground: Colors.transparent,
                  ),
                  sections: [
                    SettingsSection(
                      tiles: <SettingsTile>[
                        SettingsTile.navigation(
                          leading: Icon(Icons.color_lens),
                          title: Text("Theme"),
                          value: Text("Select app theme"),
                          onPressed: (BuildContext context) {
                            showDialog(context: context, builder: (BuildContext) {
                              int selected = preferences.getInt("theme") ?? 0;
                              return AlertDialog(
                                title: Text("Theme"),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: List.generate(3, (index) {
                                    return TextButton(
                                      child: Text(index==0? "System" : index==1? "Light" : "Dark"),
                                      onPressed: () {
                                        preferences.setInt("theme", index);
                                        if(index == 1) {
                                          MyApp.of(context).changeTheme(ThemeMode.light);
                                        }else if(index == 2) {
                                          MyApp.of(context).changeTheme(ThemeMode.dark);
                                        }else {
                                          MyApp.of(context).changeTheme(ThemeMode.system);
                                        }
                                        Navigator.of(context, rootNavigator: true).pop();
                                      },
                                    );
                                    return Radio(value: index, groupValue: selected, onChanged: (int? value) {
                                      if(value != null) {
                                        preferences.setInt("theme", value);
                                      }
                                      Navigator.of(context, rootNavigator: true).pop();
                                    });
                                  }),
                                ),
                              );
                            });
                          },
                        ),
                        SettingsTile.navigation(
                          leading: Icon(Icons.person),
                          title: Text('Name'),
                          value: Text(preferences.getString("name") ?? ""),
                          onPressed: (BuildContext context) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Name"),
                                  content: TextField(
                                    onChanged: (value) { },
                                    controller: _nameFieldController,
                                  ),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.of(context, rootNavigator: true).pop(), child: Text("Cancel")),
                                    TextButton(onPressed: () {
                                      setState(() {
                                        preferences.setString("name", _nameFieldController.text);
                                      });
                                      Navigator.of(context, rootNavigator: true).pop();
                                    }, child: Text("Ok")),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                        SettingsTile.switchTile(
                          onToggle: (value) async {
                            toggleNotifications(value, context);
                            if(!await Permission.notification.isGranted) {
                              value = false;
                            }
                            FirebaseMessaging fcm = FirebaseMessaging.instance;
                            if(!kIsWeb) {
                              if(value) {
                                fcm.subscribeToTopic("dailyVote");
                              } else {
                                fcm.unsubscribeFromTopic("dailyVote");
                              }
                            }
                            setState(() {
                              preferences.setBool("notificationsEnabled", value);
                            });
                          },
                          initialValue: preferences.getBool("notificationsEnabled"),
                          leading: Icon(Icons.notifications_active),
                          title: Text('Notifications'),
                        ),
                      ],
                    )
                  ]
              ),
            )
          ]
      ),
    );
  }
}