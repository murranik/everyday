import 'dart:convert';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:everyday/logic/database.dart';
import 'package:everyday/logic/models/alarm.dart';
import 'package:everyday/views/alarmview.dart';
import 'package:everyday/views/preferenceview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

class AlarmForm extends StatefulWidget {
  final AlarmData? alarmData;
  final bool toCreate;
  final Function? addAlarmToList;

  const AlarmForm({
    Key? key,
    this.alarmData,
    required this.toCreate,
    this.addAlarmToList,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AlarmFormState();
}

class _AlarmFormState extends State<AlarmForm> {
  TextEditingController titleController = TextEditingController();
  var date = DateTime.now();
  var helpText = '';
  late AlarmView alarmView;
  final List<String> weekDays = ["пн", "вт", "ср", "чт", "пт", "сб", "нд"];
  List<bool> weekDaysBool = [false, false, false, false, false, false, false];

  @override
  void initState() {
    alarmView = Provider.of<AlarmView>(context, listen: false);
    titleController.text = widget.alarmData!.label;
    if (!widget.toCreate) {
      date = DateTime.parse(widget.alarmData!.dateTime!);
    }
    super.initState();
  }

  void savePickedDate(DateTime dateTime) {
    date = dateTime;
    setState(() {});
  }

  static Future<void> sendOneTimeAlarm() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.reload();

    final alarmsList = prefs.getStringList('alarmsIdsList');
    final currentAlarm =
        AlarmData.fromMap(await json.decode(alarmsList!.first));
    alarmsList.removeAt(0);

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('first', 'Onetime',
            channelDescription: 'Onetime alarm channel',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await PreferenceView.flutterLocalNotificationsPlugin.show(currentAlarm.id!,
        'Будильник', currentAlarm.label, platformChannelSpecifics);

    currentAlarm.isActive = 0;

    await DBProvider.db.upsertModel(currentAlarm);

    await prefs.setStringList("alarmsIdsList", alarmsList);
  }

  @override
  Widget build(BuildContext context) {
    var orientation = MediaQuery.of(context).orientation;
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: const Color(0xff2A9863),
        actions: [
          if (!widget.toCreate)
            OutlinedButton(
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.resolveWith<Color>((states) {
                  if (states.contains(MaterialState.disabled)) {
                    return const Color(0xff2A9863);
                  }
                  return Colors.red;
                }),
              ),
              onPressed: () async {
                await DBProvider.db
                    .deleteModelById(widget.alarmData!.id, "AlarmDatas");

                Navigator.of(context).pop();
              },
              child: const Text(
                "Видалити",
                style: TextStyle(color: Colors.white),
              ),
            ),
          OutlinedButton(
              onPressed: () async {
                if (titleController.text != "") {
                  var alarm = AlarmData(
                      label: titleController.text,
                      dateTime: date.toString(),
                      id: widget.alarmData!.id,
                      isRepeat: 0,
                      isActive: 1);
                  var res = await DBProvider.db.upsertModel(alarm);
                  if (!widget.toCreate) {
                    widget.addAlarmToList!(res);
                  }
                  if (widget.toCreate) {
                    final prefs = await SharedPreferences.getInstance();
                    final alarmsList =
                        prefs.getStringList('alarmsIdsList') ?? [];
                    await prefs.remove('alarmsIdsList');
                    List<AlarmData> alarms = [];
                    for (var tmpAlarmJson in alarmsList) {
                      final tmpAlarm =
                          AlarmData.fromMap(json.decode(tmpAlarmJson));
                      alarms.add(tmpAlarm);
                    }

                    alarms.add(res);
                    alarms.sort((prev, next) => DateTime.parse(prev.dateTime!)
                        .compareTo(DateTime.parse(next.dateTime!)));

                    var newAlarmsList = <String>[];
                    for (var newAlarm in alarms) {
                      newAlarmsList.add(json.encode(newAlarm.toMap()));
                    }
                    prefs.setStringList("alarmsIdsList", newAlarmsList);

                    await AndroidAlarmManager.oneShotAt(
                        date, res.id!, sendOneTimeAlarm,
                        exact: true, wakeup: true);
                  }
                  Navigator.of(context).pop();
                }
              },
              child: const Text(
                "Зберегти",
                style: TextStyle(color: Colors.white),
              )),
        ],
      ),
      body: orientation == Orientation.landscape
          ? SingleChildScrollView(
              child: Padding(
              padding: EdgeInsets.all(10.sp),
              child: Column(
                children: [
                  Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: const [BoxShadow(color: Colors.white)]),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 1.6.h,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              SizedBox(
                                width: orientation == Orientation.portrait
                                    ? 80.w
                                    : 70.h,
                                child: TextFormField(
                                  controller: titleController,
                                  decoration: InputDecoration(
                                    errorText: '',
                                    labelText: 'Назва будильника',
                                    labelStyle:
                                        const TextStyle(color: Colors.black),
                                    prefixIcon: const Icon(Icons.event,
                                        color: Color(0xff2A9863)),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(26),
                                      borderSide: const BorderSide(
                                          color: Color(0xff2A9863)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(26),
                                      borderSide: const BorderSide(
                                          color: Color(0xff2A9863)),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(26),
                                      borderSide: BorderSide(
                                          color: ''.isEmpty
                                              ? const Color(0xff2A9863)
                                              : Colors.red),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(26),
                                      borderSide: BorderSide(
                                          color: ''.isEmpty
                                              ? const Color(0xff2A9863)
                                              : Colors.red),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    if (value.isNotEmpty) {
                                      helpText = "";
                                      setState(() {});
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      )),
                  SizedBox(
                    height: 5.h,
                  ),
                  Transform.scale(
                    scale: 1.5,
                    child: TimePickerSpinner(
                      is24HourMode: true,
                      normalTextStyle: const TextStyle(
                          fontSize: 24, color: Color.fromARGB(100, 0, 0, 0)),
                      highlightedTextStyle:
                          const TextStyle(fontSize: 24, color: Colors.black),
                      time: date,
                      itemHeight: 5.h,
                      isForce2Digits: true,
                      onTimeChange: (time) {
                        setState(() {
                          date = time;
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
                ],
              ),
            ))
          : SingleChildScrollView(
              child: Padding(
              padding: EdgeInsets.all(10.sp),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: const [BoxShadow(color: Colors.white)]),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 1.6.h,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            SizedBox(
                              width: orientation == Orientation.portrait
                                  ? 80.w
                                  : 80.h,
                              child: TextFormField(
                                controller: titleController,
                                decoration: InputDecoration(
                                  errorText: helpText,
                                  labelText: 'Назва події',
                                  labelStyle:
                                      const TextStyle(color: Colors.black),
                                  prefixIcon: const Icon(Icons.event,
                                      color: Color(0xff2A9863)),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(26),
                                    borderSide: const BorderSide(
                                        color: Color(0xff2A9863)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(26),
                                    borderSide: const BorderSide(
                                        color: Color(0xff2A9863)),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(26),
                                    borderSide: BorderSide(
                                        color: helpText.isEmpty
                                            ? const Color(0xff2A9863)
                                            : Colors.red),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(26),
                                    borderSide: BorderSide(
                                        color: helpText.isEmpty
                                            ? const Color(0xff2A9863)
                                            : Colors.red),
                                  ),
                                ),
                                onChanged: (value) {
                                  if (value.isNotEmpty) {
                                    helpText = "";
                                    setState(() {});
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 8.h,
                  ),
                  Transform.scale(
                    scale: 1.7,
                    child: TimePickerSpinner(
                      is24HourMode: true,
                      normalTextStyle: const TextStyle(
                          fontSize: 24, color: Color.fromARGB(100, 0, 0, 0)),
                      highlightedTextStyle:
                          const TextStyle(fontSize: 24, color: Colors.black),
                      time: date,
                      itemHeight: 5.h,
                      isForce2Digits: true,
                      onTimeChange: (time) {
                        setState(() {
                          date = time;
                        });
                      },
                    ),
                  )
                ],
              ),
            )),
    );
  }
}
