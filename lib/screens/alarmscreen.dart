import 'package:everyday/forms/alarmform.dart';
import 'package:everyday/logic/database.dart';
import 'package:everyday/logic/models/alarm.dart';
import 'package:everyday/views/alarmview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart' as intl;
import 'package:notification_permissions/notification_permissions.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class AlarmScreen extends StatefulWidget {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  const AlarmScreen({Key? key, required this.flutterLocalNotificationsPlugin})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> with WidgetsBindingObserver {
  late Future<String> permissionStatusFuture;
  final List<String> weekDays = ["пн", "вт", "ср", "чт", "пт", "сб", "нд"];

  var permGranted = "granted";
  var permDenied = "denied";
  var permUnknown = "unknown";
  var permProvisional = "provisional";
  var oldLen = 0;
  late AlarmView alarmView;

  @override
  void initState() {
    alarmView = Provider.of<AlarmView>(context, listen: false);
    permissionStatusFuture = getCheckNotificationPermStatus();
    WidgetsBinding.instance!.addObserver(this);
    WidgetsBinding.instance!
        .addPostFrameCallback((_) => getNotificationAccessDialog());
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      permissionStatusFuture = getCheckNotificationPermStatus();
      if (mounted) {
        setState(() {});
      }
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<String> getCheckNotificationPermStatus() {
    return NotificationPermissions.getNotificationPermissionStatus()
        .then((status) {
      switch (status) {
        case PermissionStatus.denied:
          return permDenied;
        case PermissionStatus.granted:
          return permGranted;
        case PermissionStatus.unknown:
          return permUnknown;
        case PermissionStatus.provisional:
          return permProvisional;
        default:
          return '';
      }
    });
  }

  Future<void> getNotificationAccessDialog() async {
    var m = await permissionStatusFuture;
    if (m != "granted") {
      showDialog(
          context: context,
          builder: (alarmContext) {
            return AlertDialog(
              title: Column(
                children: [
                  Row(
                    children: const [
                      Expanded(
                          child: Text(
                              "Для використання будильника дозвольте відправку сповіщень"))
                    ],
                  )
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      NotificationPermissions.requestNotificationPermissions(
                              iosSettings: const NotificationSettingsIos(
                                  sound: true, badge: true, alert: true))
                          .then((_) {
                        // when finished, check the permission status
                        setState(() {
                          permissionStatusFuture =
                              getCheckNotificationPermStatus();
                          Navigator.of(context).pop();
                        });
                      });
                    },
                    child: Text(
                      'Налаштування',
                      style: TextStyle(
                          color: const Color(0xffc9e7f2), fontSize: 14.sp),
                    )),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Пшол нах',
                      style: TextStyle(
                          color: const Color(0xffc9e7f2), fontSize: 14.sp),
                    )),
              ],
            );
          });
    }
  }

  Future<void> getAlarms() async {
    alarmView.alarms = await DBProvider.db.getModels(AlarmData(label: ""));
    setState(() {});
  }

  void addAlarmToList(AlarmData alarm) {
    alarmView.alarms.removeWhere((element) => element.id == alarm.id);
    alarmView.alarms.add(alarm);
    setState(() {});
  }

  Future<void> updateAlarm(AlarmData alarm) async {
    await DBProvider.db.upsertModel(alarm);
  }

  @override
  Widget build(BuildContext context) {
    var orientation = MediaQuery.of(context).orientation;
    getAlarms();
    return Container(
      color: Colors.grey[300],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: orientation == Orientation.portrait ? 2.h : 2.w,
          ),
          Expanded(
            child: ListView(
              children: [
                for (var element in alarmView.alarms)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => AlarmForm(
                                        toCreate: false,
                                        alarmData: element,
                                        addAlarmToList: (alarm) async {
                                          alarmView.alarms.add(alarm);
                                          await DBProvider.db
                                              .upsertModel(alarm);
                                        },
                                      )));
                            },
                            child: Container(
                                width: orientation == Orientation.portrait
                                    ? 98.5.w
                                    : 98.5.h,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
                                    boxShadow: const [
                                      BoxShadow(
                                          color: Colors.white, blurRadius: 2)
                                    ]),
                                child: orientation == Orientation.portrait
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 8.sp,
                                                        bottom: 2.sp),
                                                    child: Text(
                                                      element.label,
                                                      style: TextStyle(
                                                          fontSize: 18.sp),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 8.sp,
                                                        bottom: 2.sp),
                                                    child: Text(
                                                      intl.DateFormat.Hm()
                                                          .format(DateTime
                                                              .parse(element
                                                                  .dateTime!)),
                                                      style: TextStyle(
                                                          fontSize: 18.sp),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                padding:
                                                    EdgeInsets.only(left: 1.w),
                                                height: 4.h,
                                                child: ListView.builder(
                                                  shrinkWrap: true,
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  itemBuilder:
                                                      (context, index) {
                                                    List<String> m = [];
                                                    if (element
                                                            .rangeOfDateForRepeat !=
                                                        null) {
                                                      m = element
                                                          .rangeOfDateForRepeat!
                                                          .split('/');
                                                      m.removeLast();
                                                    }
                                                    if (m.isNotEmpty) {
                                                      return Container(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 1.sp),
                                                        child: Text(
                                                          weekDays[index]
                                                              .toUpperCase(),
                                                          style: TextStyle(
                                                            fontSize: 13.sp,
                                                            color: m.any((element) =>
                                                                    element ==
                                                                    weekDays[
                                                                        index])
                                                                ? const Color(
                                                                    0xffc9e7f2)
                                                                : Colors.black,
                                                          ),
                                                        ),
                                                      );
                                                    } else {
                                                      return Text(
                                                        intl.DateFormat.MMMd(
                                                                'uk')
                                                            .format(DateTime
                                                                .parse(element
                                                                    .dateTime!))
                                                            .replaceAll(
                                                                '.', ''),
                                                        style: TextStyle(
                                                            fontSize: 13.sp,
                                                            color:
                                                                Colors.black),
                                                      );
                                                    }
                                                  },
                                                  itemCount: element
                                                              .rangeOfDateForRepeat ==
                                                          ""
                                                      ? 1
                                                      : element
                                                              .rangeOfDateForRepeat!
                                                              .split('/')
                                                              .isNotEmpty
                                                          ? 7
                                                          : 1,
                                                ),
                                              ),
                                              Checkbox(
                                                  value: element.isActive == 1
                                                      ? true
                                                      : false,
                                                  activeColor:
                                                      const Color(0xffc9e7f2),
                                                  onChanged: (value) {
                                                    final intValue =
                                                        value == true ? 1 : 0;
                                                    element.isActive = intValue;
                                                    updateAlarm(element);
                                                    setState(() {});
                                                  })
                                            ],
                                          )
                                        ],
                                      )
                                    : Row(
                                        children: [
                                          Expanded(
                                            flex: 65,
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 8.sp,
                                                          bottom: 2.sp),
                                                      child: Text(
                                                        element.label,
                                                        style: TextStyle(
                                                            fontSize: 18.sp),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 8.sp,
                                                          bottom: 2.sp),
                                                      child: Text(
                                                        intl.DateFormat.Hm()
                                                            .format(DateTime
                                                                .parse(element
                                                                    .dateTime!)),
                                                        style: TextStyle(
                                                            fontSize: 18.sp),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                              flex: 37,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  Container(
                                                    padding:
                                                        EdgeInsets.all(2.sp),
                                                    height: 4.h,
                                                    child: ListView.builder(
                                                      shrinkWrap: true,
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      itemBuilder:
                                                          (context, index) {
                                                        List<String> m = [];
                                                        if (element
                                                                .rangeOfDateForRepeat !=
                                                            null) {
                                                          m = element
                                                              .rangeOfDateForRepeat!
                                                              .split('/');
                                                          m.removeLast();
                                                        }
                                                        if (m.isNotEmpty) {
                                                          return Container(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    left: 1.sp),
                                                            child: Text(
                                                              weekDays[index],
                                                              style: TextStyle(
                                                                fontSize: 13.sp,
                                                                color: m.any((element) =>
                                                                        element ==
                                                                        weekDays[
                                                                            index])
                                                                    ? const Color(
                                                                        0xffc9e7f2)
                                                                    : Colors
                                                                        .black,
                                                              ),
                                                            ),
                                                          );
                                                        } else {
                                                          return Text(
                                                            intl.DateFormat
                                                                    .MMMd('uk')
                                                                .format(DateTime
                                                                    .parse(element
                                                                        .dateTime!))
                                                                .replaceAll(
                                                                    '.', ''),
                                                            style: TextStyle(
                                                                fontSize: 13.sp,
                                                                color: Colors
                                                                    .black),
                                                          );
                                                        }
                                                      },
                                                      itemCount: element
                                                                  .rangeOfDateForRepeat ==
                                                              ""
                                                          ? 1
                                                          : element
                                                                  .rangeOfDateForRepeat!
                                                                  .split('/')
                                                                  .isNotEmpty
                                                              ? 7
                                                              : 1,
                                                    ),
                                                  ),
                                                  Checkbox(
                                                      value:
                                                          element.isActive == 1
                                                              ? true
                                                              : false,
                                                      activeColor: const Color(
                                                          0xffc9e7f2),
                                                      onChanged: (value) {
                                                        final intValue =
                                                            value == true
                                                                ? 1
                                                                : 0;
                                                        element.isActive =
                                                            intValue;
                                                        updateAlarm(element);
                                                        setState(() {});
                                                      })
                                                ],
                                              ))
                                        ],
                                      )),
                          )
                        ],
                      ),
                      SizedBox(
                        height: orientation == Orientation.portrait ? 1.w : 1.h,
                      )
                    ],
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
