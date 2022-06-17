import 'package:everyday/screens/calendarscreen.dart';
import 'package:everyday/views/pagesview.dart';
import 'package:everyday/views/usagestatisticview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

class ButtonInfo {
  int weight;
  String label;
  String assetPath;
  String pageName;

  ButtonInfo({
    required this.weight,
    required this.label,
    required this.assetPath,
    required this.pageName,
  });
}

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
    sortList();
    pagesView = Provider.of<PagesView>(context, listen: false);
    super.initState();
  }

  List<ButtonInfo> buttonList = [];

  void sortList() {
    buttonList = [
      ButtonInfo(
        weight: UsageStatisticView.usageStatistic.alramUseCount,
        label: "Будильник",
        assetPath: "assets/images/alarm.png",
        pageName: "Alarm",
      ),
      ButtonInfo(
        weight: UsageStatisticView.usageStatistic.eventsUseCount,
        label: "Події",
        assetPath: "assets/images/note.png",
        pageName: "Organizer",
      ),
      ButtonInfo(
        weight: UsageStatisticView.usageStatistic.calenderUseCount,
        label: "Календар",
        assetPath: "assets/images/calendar.png",
        pageName: "Calendar",
      ),
      ButtonInfo(
        weight: UsageStatisticView.usageStatistic.financesUseCount,
        label: "Фінанси",
        assetPath: "assets/images/whiteboard.png",
        pageName: "Finances",
      ),
      ButtonInfo(
        weight: UsageStatisticView.usageStatistic.mapUseCount,
        label: "Карта",
        assetPath: "assets/images/map.png",
        pageName: "Map",
      ),
      ButtonInfo(
        weight: UsageStatisticView.usageStatistic.calcUseCount,
        label: "Калькулятор",
        assetPath: "assets/images/calculator.png",
        pageName: "Calc",
      ),
      ButtonInfo(
        weight: UsageStatisticView.usageStatistic.timerUseCount,
        label: "Таймер",
        assetPath: "assets/images/chronometer.png",
        pageName: "Timer",
      ),
      ButtonInfo(
        weight: UsageStatisticView.usageStatistic.countDownTimerUseCount,
        label: "Секундомір",
        assetPath: "assets/images/stopwatch.png",
        pageName: "Sec",
      ),
      ButtonInfo(
        weight: UsageStatisticView.usageStatistic.compassUseCount,
        label: "Компас",
        assetPath: "assets/images/compass.png",
        pageName: "Compass",
      ),
    ];
    if (UsageStatisticView.enableStatisticSort) {
      buttonList.sort((prev, next) => prev.weight.compareTo(next.weight));
      buttonList = buttonList.reversed.toList();
    }
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
          actions: [
            if (kDebugMode)
              Checkbox(
                  value: UsageStatisticView.enableStatisticSort,
                  onChanged: (value) {
                    UsageStatisticView.enableStatisticSort = value!;
                    sortList();
                    setState(() {});
                  })
          ],
        ),
        backgroundColor: const Color(0xff2A9863),
        body: ListView.builder(
          itemCount: buttonList.length,
          itemBuilder: (BuildContext context, int index) {
            return Column(
              children: [
                SizedBox(
                  height: 1.h,
                ),
                if (kDebugMode) Text(buttonList[index].weight.toString()),
                iconButtonWithText(buttonList[index].label,
                    buttonList[index].assetPath, buttonList[index].pageName)
              ],
            );
          },
        ));
  }

  Widget iconButtonWithText(String text, String icon, String pageName) {
    var orientation = MediaQuery.of(context).orientation;
    return GestureDetector(
      onTap: () async {
        var usageStatisticView =
            Provider.of<UsageStatisticView>(context, listen: false);
        switch (pageName) {
          case "Home":
            UsageStatisticView.usageStatistic.alramUseCount += 1;
            break;
          case "Alarm":
            UsageStatisticView.usageStatistic.alramUseCount += 1;
            break;
          case "Organizer":
            UsageStatisticView.usageStatistic.eventsUseCount += 1;
            break;
          case "Calendar":
            UsageStatisticView.usageStatistic.calenderUseCount += 1;
            break;
          case "Finances":
            UsageStatisticView.usageStatistic.financesUseCount += 1;
            break;
          case "Map":
            UsageStatisticView.usageStatistic.mapUseCount += 1;
            break;
          case "Calc":
            UsageStatisticView.usageStatistic.calcUseCount += 1;
            break;
          case "Timer":
            UsageStatisticView.usageStatistic.timerUseCount += 1;
            break;
          case "Sec":
            UsageStatisticView.usageStatistic.countDownTimerUseCount += 1;
            break;
          case "Compass":
            UsageStatisticView.usageStatistic.compassUseCount += 1;
            break;
          default:
            UsageStatisticView.usageStatistic.alramUseCount += 1;
        }
        await usageStatisticView.saveChanges();
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
