import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jokes/utils/ValueHolder.dart';
import 'package:jokes/widgets/SwitchButton.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../App.dart';
import 'HomePage.dart';
import '../widgets/PageStepper.dart';

class FirstConfigurationPage extends StatefulWidget {
  FirstConfigurationPage({super.key});

  @override
  State<StatefulWidget> createState() => _FirstConfigurationPageState();
}

class _FirstConfigurationPageState extends State<FirstConfigurationPage> {
  final StepperController stepperController = StepperController();

  final nameFieldController = TextEditingController();
  final ValueHolder<bool> notificationsEnabledHolder = ValueHolder(false);

  SharedPreferences preferences = App.getInstance().preferences;

  @override
  void dispose() {
    nameFieldController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    nameFieldController.text = preferences?.getString("name") ?? "";
    if(!kIsWeb) {
      Permission.notification.isDenied.then((value) async {
        if (value) {
          if (await Permission.notification
              .request()
              .isDenied) {
            return;
          }
        }
        setState(() {
          notificationsEnabledHolder.value = true;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageStepper(
                  controller: stepperController,
                  onFinish: () {
                    preferences?.setBool("firstConfiguration", true);
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const HomePage()), (r) => false);
                  },
                  steps: [
                    _firstStep(),
                    _secondStep(),
                  ],
                ),
              ),
            ],
          ),
        )
    );
  }

  _firstStep() {
    return StepPage(
      widget: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
              margin: EdgeInsets.only(top: 12),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("Cześć 👋",
                      style: TextStyle(
                        fontSize: 24,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        "Podaj swoje imię, aby móc\nCię codziennie przywitać nowymi\ndowcipami",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                    SizedBox(height: 20,),
                    SizedBox(
                      width: 300,
                      child: TextField(
                        controller: nameFieldController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Podaj swoje imię",
                        ),
                      ),
                    )
                  ]
              )
          ),
          SizedBox(height: 50,),
          Container(
            margin: const EdgeInsets.only(bottom: 12, top: 10),
            child: FilledButton.tonal(
              onPressed: () {
                stepperController.nextStep();
              },
              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 26)),
              child: const Text("Dalej",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
          )
        ],
      ),
      onNext: () {
        preferences?.setString("name", nameFieldController.text);
      },
    );
  }

  _secondStep() {
    return StepPage(
        widget: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 30,),
                  Text("Otrzymuj powiadomienia\no nowych dowcipach",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 24
                    ),
                  ),
                  SizedBox(height: 20,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("Powiadomienia ",
                          style: TextStyle(
                              fontSize: 18
                          )
                      ),
                      SizedBox(width: 10,),
                      SwitchButton(
                        valueHolder: notificationsEnabledHolder,
                        onChanged: (bool value) async {
                          if(!kIsWeb) {
                            PermissionStatus status = await Permission.notification.isGranted.then((value) async {
                              if (!value) {
                                return await Permission.notification.request();
                              }
                              return PermissionStatus.granted;
                            });
                            if(!status.isGranted) {
                              setState(() {
                                notificationsEnabledHolder.value = false;
                              });
                            }
                          }
                        },
                      )
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 100,),
            Container(
              margin: const EdgeInsets.only(bottom: 12, top: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FilledButton.tonal(
                    onPressed: () {
                      stepperController.previousStep();
                    },
                    style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 26)),
                    child: const Text("Wróć",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                  SizedBox(width: 20,),
                  FilledButton.tonal(
                    onPressed: () async {
                      preferences.setBool("notificationsEnabled", notificationsEnabledHolder.value);
                      toggleNotifications(notificationsEnabledHolder.value, context);
                      FirebaseMessaging fcm = FirebaseMessaging.instance;
                      if(!kIsWeb) {
                        if (notificationsEnabledHolder.value) {
                          fcm.subscribeToTopic("dailyVote");
                        } else {
                          fcm.unsubscribeFromTopic("dailyVote");
                        }
                      }
                      stepperController.nextStep();
                    },
                    style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 26)),
                    child: const Text("Dalej",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
        onNext: () {
          preferences.setBool("notificationsEnabled", notificationsEnabledHolder.value);
        }
    );
  }
}