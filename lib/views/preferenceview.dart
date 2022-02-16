import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferenceView with ChangeNotifier {
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future init(_flutterLocalNotificationsPlugin) async {
    flutterLocalNotificationsPlugin = _flutterLocalNotificationsPlugin;
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('alarmsIdsList');
    if (list == null) {
      prefs.setStringList('alarmsIdsList', []);
    }
  }

  static Future getAlarmId() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('alarmsIdsList');
    return list!.length + 1;
  }
}
