import 'dart:convert';

import 'package:everyday/logic/models/usagestatistic.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UsageStatisticView with ChangeNotifier {
  static var usageStatistic = UsageStatistic();
  static var enableStatisticSort = kDebugMode ? false : true;

  Future saveChanges() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setString("UsageStats", json.encode(usageStatistic.toMap()));
    if (kDebugMode) {
      print(usageStatistic.toMap().toString());
    }
  }

  static Future init() async {
    var prefs = await SharedPreferences.getInstance();
    var usageData = prefs.getString("UsageStats");

    if (usageData != null) {
      usageStatistic = UsageStatistic.fromMap(jsonDecode(usageData));
    }
  }
}
