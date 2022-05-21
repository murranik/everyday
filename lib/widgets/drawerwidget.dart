import 'package:everyday/screens/calendarscreen.dart';
import 'package:everyday/views/pagesview.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

class DrawerWidget extends StatefulWidget {
  final Function? update;

  const DrawerWidget({Key? key, this.update}) : super(key: key);

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  late PagesView pagesView;

  @override
  void initState() {
    pagesView = Provider.of<PagesView>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Every Day",
            style: TextStyle(color: Colors.black),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xff2A9863),
        ),
        backgroundColor: const Color(0xff2A9863),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: 1.h,
              ),
              iconButtonWithText(
                  "Будильник", "assets/images/alarm.png", "Alarm"),
              SizedBox(
                height: 2.h,
              ),
              iconButtonWithText(
                  "Органайзер", "assets/images/note.png", "Organizer"),
              SizedBox(
                height: 2.h,
              ),
              iconButtonWithText(
                  "Календар", "assets/images/calendar.png", "Calendar"),
              SizedBox(
                height: 2.h,
              ),
              iconButtonWithText(
                  "Фінанси", "assets/images/whiteboard.png", "Finances"),
              SizedBox(
                height: 2.h,
              ),
              iconButtonWithText("Карта", "assets/images/map.png", "Map"),
              SizedBox(
                height: 2.h,
              ),
              iconButtonWithText(
                  "Калькулятор", "assets/images/calculator.png", "Calc"),
              SizedBox(
                height: 2.h,
              ),
              iconButtonWithText(
                  "Таймер", "assets/images/chronometer.png", "Timer"),
              SizedBox(
                height: 2.h,
              ),
              iconButtonWithText(
                  "Секундомір", "assets/images/stopwatch.png", "Sec"),
              SizedBox(
                height: 2.h,
              ),
              iconButtonWithText(
                  "Компас", "assets/images/compass.png", "Compass"),
              SizedBox(
                height: 2.h,
              ),
            ],
          ),
        ));
  }

  Widget iconButtonWithText(String text, String icon, String pageName) {
    var orientation = MediaQuery.of(context).orientation;
    return GestureDetector(
      onTap: () {
        pagesView.pageName = pageName;
        Navigator.of(context).pop();
        widget.update!();
      },
      child: Row(
        children: [
          SizedBox(
            width: orientation == Orientation.portrait ? 1.5.w : 1.5.h,
          ),
          Image.asset(
            icon,
            height: 50,
            width: 50,
          ),
          SizedBox(
            width: orientation == Orientation.portrait ? 1.5.w : 1.5.h,
          ),
          Text(
            text,
            style: TextStyle(fontSize: 14.sp, color: Colors.black),
          )
        ],
      ),
    );
  }
}
