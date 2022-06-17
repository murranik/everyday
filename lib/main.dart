import 'dart:io';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:everyday/pages/homepage.dart';
import 'package:everyday/views/alarmview.dart';
import 'package:everyday/views/countdowns.dart';
import 'package:everyday/views/financemodelview.dart';
import 'package:everyday/views/pagesview.dart';
import 'package:everyday/views/preferenceview.dart';
import 'package:everyday/views/usagestatisticview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart' as tz;

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) {
    await AndroidAlarmManager.initialize();
    var prefs = await SharedPreferences.getInstance();
    var list = prefs.getStringList("ids");
    if (list == null) {
      prefs.setStringList("ids", []);
    }

    await PreferenceView.init(flutterLocalNotificationsPlugin);
    await UsageStatisticView.init();
    final String currentTimeZone =
        await tz.FlutterNativeTimezone.getLocalTimezone();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('logo');
    InitializationSettings initializationSettings =
        const InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  initApp();
}

void initApp() async {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<PagesView>(
          create: (_) => PagesView(),
        ),
        ChangeNotifierProvider<AlarmView>(
          create: (_) => AlarmView(),
        ),
        ChangeNotifierProvider<PreferenceView>(
          create: (_) => PreferenceView(),
        ),
        ChangeNotifierProvider<CountdownsView>(
          create: (_) => CountdownsView(),
        ),
        ChangeNotifierProvider<UsageStatisticView>(
          create: (_) => UsageStatisticView(),
        ),
        ChangeNotifierProvider<FinanceModelView>(
          create: (_) => FinanceModelView(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    return LayoutBuilder(builder: (context, constraints) {
      return OrientationBuilder(builder: (context, orientation) {
        SizerUtil.setScreenSize(constraints, orientation);
        return MaterialApp(
          title: 'Every Day',
          home: Builder(
            builder: (c) {
              return HomePage(
                flutterLocalNotificationsPlugin:
                    flutterLocalNotificationsPlugin,
              );
            },
          ),
          debugShowCheckedModeBanner: false,
          locale: const Locale("uk", "UA"),
          localizationsDelegates: const [GlobalMaterialLocalizations.delegate],
          supportedLocales: const [Locale('en'), Locale('uk')],
          theme: ThemeData(
            visualDensity: VisualDensity.adaptivePlatformDensity,
            fontFamily: 'Roboto',
          ),
        );
      });
    });
  }
}
