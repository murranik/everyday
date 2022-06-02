import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:everyday/views/preferenceview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:sizer/sizer.dart';
import 'package:duration_picker/duration_picker.dart';

class TimerCountDownScreen extends StatefulWidget {
  const TimerCountDownScreen({
    Key? key,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() => _TimerCountDownScreenState();
}

class _TimerCountDownScreenState extends State<TimerCountDownScreen>
    with WidgetsBindingObserver {
  bool hasTime = false;
  var _duration = Duration(seconds: 0);
  var backGroundColor = Colors.greenAccent[200];
  late CountdownTimerController countdownTimerController;

  @override
  void initState() {
    countdownTimerController =
        CountdownTimerController(endTime: _duration.inSeconds, onEnd: onEnd);
    super.initState();
  }

  onEnd() {
    hasTime = false;
    AndroidAlarmManager.oneShot(Duration.zero, 1, sendOneTimeAlarm,
        exact: true, wakeup: true);
    setState(() {});
  }

  @override
  void dispose() {
    countdownTimerController.dispose();
    super.dispose();
  }

  static void sendOneTimeAlarm() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('first', 'Onetime',
            channelDescription: 'Onetime alarm channel',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await PreferenceView.flutterLocalNotificationsPlugin
        .show(1, 'Таймер', "", platformChannelSpecifics);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
            child: Row(
          children: [
            Expanded(
                child: InkWell(
              onTap: () {
                if (!countdownTimerController.isRunning &&
                    _duration.inSeconds > 0) {
                  hasTime = true;
                  countdownTimerController.endTime =
                      DateTime.now().millisecondsSinceEpoch +
                          1000 * _duration.inSeconds;
                  countdownTimerController.start();
                  backGroundColor = Colors.greenAccent[200];
                  setState(() {});
                } else {
                  if (_duration.inSeconds > 0) {
                    hasTime = false;
                    countdownTimerController.disposeTimer();
                    backGroundColor = Colors.amber;
                    setState(() {});
                  }
                }
              },
              child: Container(
                alignment: Alignment.center,
                child: Builder(
                  builder: (BuildContext context) {
                    if (hasTime) {
                      return CountdownTimer(
                        controller: countdownTimerController,
                        textStyle: TextStyle(fontSize: 50.sp),
                        endWidget: Column(
                          children: [
                            Expanded(
                                child: Row(
                              children: [
                                Expanded(
                                    child: Container(
                                        alignment: Alignment.center,
                                        color: Colors.greenAccent[200],
                                        child: Text("Таймер спрацював")))
                              ],
                            ))
                          ],
                        ),
                      );
                    } else {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              DurationPicker(
                                duration: _duration,
                                onChange: (val) {
                                  print(val);
                                  if (val !=
                                      const Duration(
                                          minutes: 0,
                                          days: 0,
                                          hours: 0,
                                          microseconds: 0,
                                          milliseconds: 0,
                                          seconds: 0)) {
                                    backGroundColor = Colors.amber;
                                  } else {
                                    backGroundColor = Colors.greenAccent[200];
                                  }
                                  setState(() => _duration = val);
                                },
                                snapToMins: 5.0,
                              ),
                            ],
                          )
                        ],
                      );
                    }
                  },
                ),
                color: backGroundColor,
              ),
            ))
          ],
        ))
      ],
    );
  }
}
