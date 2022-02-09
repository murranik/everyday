import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:everyday/pages/homepage.dart';
import 'package:everyday/views/alarmview.dart';
import 'package:everyday/views/pagesview.dart';
import 'package:everyday/views/preferenceview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AndroidAlarmManager.initialize();
  var prefs = await SharedPreferences.getInstance();
  var list = prefs.getStringList("ids");
  if (list == null) {
    prefs.setStringList("ids", []);
  }

  await PreferenceView.init();

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
    return LayoutBuilder(builder: (context, constraints) {
      return OrientationBuilder(builder: (context, orientation) {
        SizerUtil.setScreenSize(constraints, orientation);
        return MaterialApp(
          title: 'Every Day',
          home: Builder(
            builder: (c) {
              return const HomePage();
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
