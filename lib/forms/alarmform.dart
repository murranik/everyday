import 'dart:isolate';
import 'dart:ui';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:everyday/logic/database.dart';
import 'package:everyday/logic/models/alarm.dart';
import 'package:everyday/views/alarmview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

class AlarmForm extends StatefulWidget {
  final AlarmData? alarmData;
  final bool toCreate;
  final Function? addAlarmToList;

  const AlarmForm(
      {Key? key, this.alarmData, required this.toCreate, this.addAlarmToList})
      : super(key: key);

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
      if (widget.alarmData!.rangeOfDateForRepeat != null) {
        var m = widget.alarmData!.rangeOfDateForRepeat!.split('/');
        m.removeLast();
        for (var i = 0; i < weekDays.length; i++) {
          if (m.any((element) => element == weekDays[i])) {
            weekDaysBool[i] = true;
          }
        }
      }
    }
    super.initState();
  }

  void savePickedDate(DateTime dateTime) {
    date = dateTime;
    setState(() {});
  }

  static Future<void> sendOneTimeAlarm() async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    var listOfAlarms = prefs.getStringList("ids");
    String id;
    if (listOfAlarms!.isNotEmpty) {
      id = listOfAlarms.first;
      var alarm = await DBProvider.db
          .getModelById(int.parse(id), AlarmData(label: "")) as AlarmData;

      listOfAlarms.removeAt(0);
      prefs.setStringList("ids", listOfAlarms);
      alarm.isActive = 0;
      DBProvider.db.upsertModel(alarm);
    }
  }

  static Future<void> sendPeriodicAlarm(int id) async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    var title = prefs.getString("title");
    var id = prefs.getInt("id") ?? 10000;

    var alarm =
        await DBProvider.db.getModelById(id, AlarmData(label: "")) as AlarmData;

    var listOfDates = alarm.rangeOfDateForRepeat!.split('/');
    List<int> weekDaysList = [];
    for (var date in listOfDates) {
      switch (date) {
        case "пн":
          weekDaysList.add(1);
          break;
        case "вт":
          weekDaysList.add(2);
          break;
        case "ср":
          weekDaysList.add(3);
          break;
        case "чт":
          weekDaysList.add(4);
          break;
        case "пт":
          weekDaysList.add(5);
          break;
        case "сб":
          weekDaysList.add(6);
          break;
        case "нд":
          weekDaysList.add(7);
          break;
      }
    }

    for (var weekDay in weekDaysList) {}
  }

  String buildRangeOfDateForRepeatString() {
    var rangeOfDateForRepeatString = '';
    for (var i = 0; i < weekDays.length; i++) {
      if (weekDaysBool[i]) {
        rangeOfDateForRepeatString += weekDays[i] + "/";
      }
    }
    return rangeOfDateForRepeatString;
  }

  @override
  Widget build(BuildContext context) {
    var orientation = MediaQuery.of(context).orientation;
    return SafeArea(
        child: Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: const Color(0xffc9e7f2),
        actions: [
          if (!widget.toCreate)
            OutlinedButton(
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.resolveWith<Color>((states) {
                  if (states.contains(MaterialState.disabled)) {
                    return const Color(0xffc9e7f2);
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
                var alarm = AlarmData(
                    label: titleController.text,
                    dateTime: date.toString(),
                    id: widget.alarmData!.id,
                    isRepeat: 0,
                    isActive: 1,
                    rangeOfDateForRepeat: buildRangeOfDateForRepeatString());
                var res = await DBProvider.db.upsertModel(alarm);
                if (!widget.toCreate) {
                  widget.addAlarmToList!(res);
                }
                if (widget.toCreate) {
                  var prefs = await SharedPreferences.getInstance();

                  var listOfAlarms = prefs.getStringList("ids");
                  listOfAlarms!.add("${alarm.id}");
                  prefs.setStringList("ids", listOfAlarms);

                  final int helloAlarmID = res.id;
                  if (alarm.rangeOfDateForRepeat != null) {
                    await AndroidAlarmManager.oneShotAt(
                        date, helloAlarmID, sendOneTimeAlarm,
                        exact: true, wakeup: true);
                  } else {}
                }
                Navigator.of(context).pop();
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
                            height: 1.h,
                          ),
                          Builder(builder: (context) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                for (var i = 0; i < weekDays.length; i++)
                                  GestureDetector(
                                    onTap: () {
                                      weekDaysBool[i] = !weekDaysBool[i];
                                      setState(() {});
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      width: 4.h,
                                      height: 4.h,
                                      decoration: weekDaysBool[i] == true
                                          ? BoxDecoration(
                                              color: Colors.green,
                                              borderRadius:
                                                  BorderRadius.circular(24))
                                          : const BoxDecoration(),
                                      padding: EdgeInsets.only(left: 1.sp),
                                      child: Text(
                                        weekDays[i].toUpperCase(),
                                        style: TextStyle(
                                            fontSize: 11.sp,
                                            color: Colors.black),
                                      ),
                                    ),
                                  )
                              ],
                            );
                          }),
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
                                        color: Color(0xffc9e7f2)),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(26),
                                      borderSide: const BorderSide(
                                          color: Color(0xffc9e7f2)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(26),
                                      borderSide: const BorderSide(
                                          color: Color(0xffc9e7f2)),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(26),
                                      borderSide: BorderSide(
                                          color: ''.isEmpty
                                              ? const Color(0xffc9e7f2)
                                              : Colors.red),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(26),
                                      borderSide: BorderSide(
                                          color: ''.isEmpty
                                              ? const Color(0xffc9e7f2)
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
                          fontSize: 24, color: Color(0xffc9e7f2)),
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
                          height: 1.h,
                        ),
                        Builder(builder: (context) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              for (var i = 0; i < weekDays.length; i++)
                                GestureDetector(
                                  onTap: () {
                                    weekDaysBool[i] = !weekDaysBool[i];
                                    setState(() {});
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    width: 4.h,
                                    height: 4.h,
                                    decoration: weekDaysBool[i] == true
                                        ? BoxDecoration(
                                            color: Colors.green,
                                            borderRadius:
                                                BorderRadius.circular(24))
                                        : const BoxDecoration(),
                                    padding: EdgeInsets.only(left: 1.sp),
                                    child: Text(
                                      weekDays[i].toUpperCase(),
                                      style: TextStyle(
                                          fontSize: 11.sp, color: Colors.black),
                                    ),
                                  ),
                                )
                            ],
                          );
                        }),
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
                                      color: Color(0xffc9e7f2)),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(26),
                                    borderSide: const BorderSide(
                                        color: Color(0xffc9e7f2)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(26),
                                    borderSide: const BorderSide(
                                        color: Color(0xffc9e7f2)),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(26),
                                    borderSide: BorderSide(
                                        color: helpText.isEmpty
                                            ? const Color(0xffc9e7f2)
                                            : Colors.red),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(26),
                                    borderSide: BorderSide(
                                        color: helpText.isEmpty
                                            ? const Color(0xffc9e7f2)
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
                          fontSize: 24, color: Color(0xffc9e7f2)),
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
    ));
  }
}
