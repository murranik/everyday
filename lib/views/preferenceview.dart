import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferenceView with ChangeNotifier {
  static late int? _alarmId = 0;

  static Future init() async {
    final prefs = await SharedPreferences.getInstance();
    _alarmId = prefs.getInt('alarmId');
    if (_alarmId == null) {
      prefs.setInt('alarmId', 0);
      _alarmId = 0;
    }
  }

  static Future getAlarmId() async {
    final prefs = await SharedPreferences.getInstance();
    _alarmId = _alarmId! + 1;
    prefs.setInt('alarmId', _alarmId!);
    return _alarmId;
  }
}
