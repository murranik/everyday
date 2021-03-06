import 'package:everyday/dialogs/financedialog.dart';
import 'package:everyday/forms/alarmform.dart';
import 'package:everyday/logic/database.dart';
import 'package:everyday/logic/models/alarm.dart';
import 'package:everyday/screens/alarmscreen.dart';
import 'package:everyday/screens/calculatorscreen.dart';
import 'package:everyday/screens/calendarscreen.dart';
import 'package:everyday/screens/compass.dart';
import 'package:everyday/screens/finances/financesscreen.dart';
import 'package:everyday/screens/mapscreen.dart';
import 'package:everyday/screens/organizerscreen.dart';
import 'package:everyday/screens/secundomer.dart';
import 'package:everyday/screens/timerscreen.dart';
import 'package:everyday/views/alarmview.dart';
import 'package:everyday/views/pagesview.dart';
import 'package:everyday/widgets/drawerwidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

class HomePage extends StatefulWidget {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  const HomePage({Key? key, required this.flutterLocalNotificationsPlugin})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String title = "Будильник";
  String pageName = "Alarm";

  @override
  void initState() {
    super.initState();
  }

  void getPage() {
    var pagesView = Provider.of<PagesView>(context, listen: false);
    switch (pagesView.pageName) {
      case "Home":
        {
          title = "Головна";
          pageName = "Home";
        }
        break;
      case "Alarm":
        {
          title = "Будильник";
          pageName = "Alarm";
        }
        break;
      case "Organizer":
        {
          title = "Події";
          pageName = "Organizer";
        }
        break;
      case "Calendar":
        {
          title = "Календар";
          pageName = "Calendar";
        }
        break;
      case "Finances":
        {
          title = "Фінанси";
          pageName = "Finances";
        }
        break;
      case "Map":
        {
          title = "Карта";
          pageName = "Map";
        }
        break;
      case "Calc":
        {
          title = "Калькулятор";
          pageName = "Calc";
        }
        break;
      case "Timer":
        {
          title = "Таймер";
          pageName = "Timer";
        }
        break;
      case "Sec":
        {
          title = "Секундомір";
          pageName = "Sec";
        }
        break;
      case "Compass":
        {
          title = "Компас";
          pageName = "Compass";
        }
        break;
      default:
        {
          title = "Будильник";
          pageName = "Alarm";
        }
    }
  }

  void update() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var orientation = MediaQuery.of(context).orientation;
    getPage();
    return Scaffold(
        drawer: Drawer(
            child: DrawerWidget(
          update: update,
        )),
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: const Color(0xff2A9863),
          title: Text(
            title,
            style: const TextStyle(color: Colors.black),
          ),
          actions: [
            if (pageName == "Alarm")
              MaterialButton(
                color: const Color(0xff2A9863),
                onPressed: () async {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => AlarmForm(
                            toCreate: true,
                            alarmData: AlarmData(label: ''),
                          )));
                },
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 30.sp,
                ),
              ),
            if (pageName == "Timer")
              Container(
                margin: EdgeInsets.only(
                    right: orientation == Orientation.portrait ? 3.h : 3.w),
                child: const Tooltip(
                  message:
                      "Після вибору тривалості натисніть на оранжевий екран",
                  child: Icon(Icons.question_mark),
                ),
              )
          ],
        ),
        body: Builder(builder: (context) {
          if (pageName == "Home") {
            return Container(
                color: const Color(0xff2A9863),
                child: const Center(
                  child: Text('hello'),
                ));
          } else if (pageName == "Alarm") {
            return AlarmScreen(
              flutterLocalNotificationsPlugin:
                  widget.flutterLocalNotificationsPlugin,
            );
          } else if (pageName == "Organizer") {
            return const OrganizerScreen();
          } else if (pageName == "Calendar") {
            return const CalendarScreen();
          } else if (pageName == "Finances") {
            return const FinancesScreen();
          } else if (pageName == "Map") {
            return const MapScreen();
          } else if (pageName == "Calc") {
            return const CalculatorScreen();
          } else if (pageName == "Sec") {
            return const SecScreen();
          } else if (pageName == "Compass") {
            return const CompassScreen();
          } else if (pageName == "Timer") {
            return const TimerCountDownScreen();
          } else {
            return const Text("error");
          }
        }));
  }

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    initDatabase();
  }

  Future<void> initDatabase() async {
    await DBProvider.db.initDB();
  }
}
