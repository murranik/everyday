import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:everyday/forms/alarmform.dart';
import 'package:everyday/logic/database.dart';
import 'package:everyday/logic/models/alarm.dart';
import 'package:everyday/screens/alarmscreen.dart';
import 'package:everyday/screens/calendarscreen.dart';
import 'package:everyday/screens/financesscreen.dart';
import 'package:everyday/screens/mapscreen.dart';
import 'package:everyday/screens/organizerscreen.dart';
import 'package:everyday/views/alarmview.dart';
import 'package:everyday/views/pagesview.dart';
import 'package:everyday/widgets/drawerwidget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  String title = "Будильник";
  String pageName = "Alarm";

  @override
  void initState(){
    super.initState();

  }

  void getPage(){
    var pagesView = Provider.of<PagesView>(context, listen: false);
    switch(pagesView.pageName){
      case "Home": {title = "Головна"; pageName = "Home";} break;
      case "Alarm": {title = "Будильник"; pageName = "Alarm";} break;
      case "Organizer": {title = "Органайзер"; pageName = "Organizer";} break;
      case "Calendar": {title = "Календар"; pageName = "Calendar";} break;
      case "Finances": {title = "Фінаси"; pageName = "Finances";} break;
      case "Map": {title = "Карта"; pageName = "Map";} break;
      default: {title = "Будильник"; pageName = "Alarm";}
    }
  }

  void update(){
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var orientation = MediaQuery.of(context).orientation;
    getPage();
    return Scaffold(
        drawer: SafeArea(
          child: Drawer(
              child: DrawerWidget(update: update,)
          ),
        ),
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: const Color(0xff2a9863),
          title: Text(title),
          actions: [
            if(pageName == "Alarm")
              MaterialButton(
                color: const Color(0xff2a9863),
                onPressed: () async {
                  Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => AlarmForm(
                            toCreate: true,
                            alarmData: AlarmData(label: ''),
                          )
                      )
                  );
                },
                child: Icon(Icons.add, color: Colors.white, size: 30.sp,),
              ),
          ],
        ),
        body: Builder(
            builder: (context) {
          if(pageName == "Home") {
            return Container(
                color: const Color(0xff2a9863),
                child: const Center(
                  child: Text('hello'),
                )
            );
          } else if(pageName == "Alarm"){
            return const AlarmScreen();
          } else if(pageName == "Organizer"){
            return const OrganizerScreen();
          } else if(pageName == "Calendar"){
            return const CalendarScreen();
          }  else if(pageName == "Finances"){
            return const FinancesScreen();
          } else if(pageName == "Map"){
            return const MapScreen();
          } else {
            return const Text("error");
          }
        }
        )
    );
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