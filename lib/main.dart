import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:everyday/logic/database.dart';
import 'package:everyday/pages/homepage.dart';
import 'package:everyday/views/alarmview.dart';
import 'package:everyday/views/pagesview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AndroidAlarmManager.initialize();
  AwesomeNotifications().initialize(
    // set the icon to null if you want to use the default app icon
      'resource://drawable/logo',
      [
        NotificationChannel(
            channelKey: 'basic_channel',
            channelName: 'Basic notifications',
            channelDescription: 'Notification channel for basic tests',
            defaultColor: Color(0xFF9D50DD),
            ledColor: Colors.white
        )
      ]
  );
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
              AwesomeNotifications().actionStream.listen(
                      (receivedNotification){

                    Navigator.of(context).pushNamed(
                        '/NotificationPage',
                        arguments: { "basic_channel": receivedNotification.id } // your page params. I recommend to you to pass all *receivedNotification* object
                    );

                  }
              );
              return const HomePage();
            },
          ),
          debugShowCheckedModeBanner: false,
          locale: const Locale("uk", "UA"),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('uk')
          ],
          theme: ThemeData(
            visualDensity: VisualDensity.adaptivePlatformDensity,
            fontFamily: 'Roboto',
          ),
        );
      }
      );
    }
    );
  }

}