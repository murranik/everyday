import 'dart:isolate';
import 'dart:ui';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
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

  const AlarmForm({Key? key, this.alarmData, required this.toCreate, this.addAlarmToList}) : super(key: key);

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
    if(!widget.toCreate){
      date = DateTime.parse(widget.alarmData!.dateTime!);
      if(widget.alarmData!.rangeOfDateForRepeat != null) {
        var m = widget.alarmData!.rangeOfDateForRepeat!.split('/');
        m.removeLast();
        for(var i = 0; i < weekDays.length; i++){
          if(m.any((element) => element == weekDays[i])){
            weekDaysBool[i] = true;
          }
        }
      }
    }
    super.initState();
  }

  void savePickedDate(DateTime dateTime){
    date = dateTime;
    setState(() {

    });
  }

  static Future<void> printHello() async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    var title = prefs.getString("title");
    var id = prefs.getInt("id") ?? 10000;
    AwesomeNotifications().createNotification(
        content: NotificationContent(
          largeIcon: 'resource://drawable/logo',
          id: id + 1,
          channelKey: 'basic_channel',
          title: title,
          body: DateTime.now().toString(),
          icon: 'resource://drawable/logo',
        )
    );
  }

  String buildRangeOfDateForRepeatString(){
    var rangeOfDateForRepeatString = '';
    for(var i = 0; i < weekDays.length; i++){
      if(weekDaysBool[i]){
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
            backgroundColor: const Color(0xff2a9863),
            actions: [
              if(!widget.toCreate)
                OutlinedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                      if (states.contains(MaterialState.disabled)) {
                        return const Color(0xff2a9863);
                      }
                      return Colors.red;
                    }),
                  ),
                  onPressed: () async {
                    await DBProvider.db.deleteModelById(widget.alarmData!.id, "AlarmDatas");

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
                        rangeOfDateForRepeat: buildRangeOfDateForRepeatString()
                    );
                    var res = await DBProvider.db.upsertModel(alarm);
                    if(!widget.toCreate){
                      widget.addAlarmToList!(res);
                    }
                    if(widget.toCreate){
                      var prefs = await SharedPreferences.getInstance();
                      prefs.remove("title");
                      prefs.remove("id");
                      await prefs.setString("title", alarm.label);
                      await prefs.setInt("id", alarm.id!);
                      const int helloAlarmID = 0;
                      await AndroidAlarmManager.oneShotAt(date, helloAlarmID, printHello, alarmClock: true, exact: true, wakeup: true);
                    }
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    "Зберегти",
                    style: TextStyle(color: Colors.white),
                  )
              ),

            ],
          ),
          body: orientation == Orientation.landscape
              ? SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(10.sp),
                child: Column(
                  children: [
                    TimePickerSpinner(
                      is24HourMode: true,
                      normalTextStyle: const TextStyle(
                          fontSize: 24,
                          color: Color.fromRGBO(0, 0, 0, 0.2)
                      ),
                      highlightedTextStyle: const TextStyle(
                          fontSize: 24,
                          color: Color(0xff2a9863)
                      ),
                      time: date,
                      itemHeight: 5.h,
                      isForce2Digits: true,
                      onTimeChange: (time) {
                        setState(() {
                          date = time;
                        });
                      },
                    ),
                    Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: const [
                              BoxShadow(color: Colors.white)
                            ]
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 1.h,
                            ),
                            Builder(
                                builder: (context) {
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      for(var i = 0; i < weekDays.length; i++)
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
                                                borderRadius: BorderRadius.circular(24)
                                            )
                                                : const BoxDecoration(),
                                            padding: EdgeInsets.only(left: 1.sp),
                                            child: Text(
                                              weekDays[i],
                                              style: TextStyle(
                                                  fontSize: 13.sp,
                                                  color: Colors.black
                                              ),
                                            ),
                                          ),
                                        )
                                    ],
                                  );
                                }
                            ),
                            SizedBox(
                              height: 1.6.h,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                SizedBox(
                                  width: orientation == Orientation.portrait ? 80.w : 70.h,
                                  child: TextFormField(
                                    controller: titleController,
                                    decoration: InputDecoration(
                                      errorText: '',
                                      labelText: 'Назва будильника',
                                      labelStyle: const TextStyle(color: Colors.black),
                                      prefixIcon: const Icon(Icons.event, color: Color(0xff2a9863)),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(26),
                                        borderSide: const BorderSide(color: Color(0xff2a9863)),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(26),
                                        borderSide: const BorderSide(color: Color(0xff2a9863)),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(26),
                                        borderSide: BorderSide(color: ''.isEmpty ? const Color(0xff2a9863) : Colors.red),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(26),
                                        borderSide: BorderSide(color: ''.isEmpty ? const Color(0xff2a9863) : Colors.red),
                                      ),
                                    ),
                                    onChanged: (value) {
                                      if(value.isNotEmpty){
                                        helpText = "";
                                        setState(() {});
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                    )
                  ],
                ),
              )
          )
              : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(10.sp),
                child: Column(
                  children: [
                    TimePickerSpinner(
                      is24HourMode: true,
                      normalTextStyle: const TextStyle(
                          fontSize: 24,
                          color: Color.fromRGBO(0, 0, 0, 0.2)
                      ),
                      highlightedTextStyle: const TextStyle(
                          fontSize: 24,
                          color: Color(0xff2a9863)
                      ),
                      time: date,
                      itemHeight: 5.h,
                      isForce2Digits: true,
                      onTimeChange: (time) {
                        setState(() {
                          date = time;
                        });
                      },
                    ),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: const [
                            BoxShadow(color: Colors.white)
                          ]
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 1.h,
                          ),
                          Builder(
                              builder: (context) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    for(var i = 0; i < weekDays.length; i++)
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
                                              borderRadius: BorderRadius.circular(24)
                                          )
                                              : const BoxDecoration(),
                                          padding: EdgeInsets.only(left: 1.sp),
                                          child: Text(
                                            weekDays[i],
                                            style: TextStyle(
                                                fontSize: 13.sp,
                                                color: Colors.black
                                            ),
                                          ),
                                        ),
                                      )
                                  ],
                                );
                              }
                          ),
                          SizedBox(
                            height: 1.6.h,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              SizedBox(
                                width: orientation == Orientation.portrait  ? 80.w : 80.h,
                                child: TextFormField(
                                  controller: titleController,
                                  decoration: InputDecoration(
                                    errorText: helpText,
                                    labelText: 'Назва події',
                                    labelStyle: const TextStyle(color: Colors.black),
                                    prefixIcon: const Icon(Icons.event, color: Color(0xff2a9863)),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(26),
                                      borderSide: const BorderSide(color: Color(0xff2a9863)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(26),
                                      borderSide: const BorderSide(color: Color(0xff2a9863)),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(26),
                                      borderSide: BorderSide(color: helpText.isEmpty ? const Color(0xff2a9863) : Colors.red),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(26),
                                      borderSide: BorderSide(color: helpText.isEmpty ? const Color(0xff2a9863) : Colors.red),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    if(value.isNotEmpty){
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
                  ],
                ),
              )
          ),
        )
    );
  }

}