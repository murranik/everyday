import 'package:everyday/forms/eventscreenform.dart';
import 'package:everyday/logic/database.dart';
import 'package:everyday/logic/models/event.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:intl/intl.dart' as intl;

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  List<Event> events = [];

  @override
  void initState() {
    getEvent();
    super.initState();
  }

  Future<void> getEvent() async {
    events = await DBProvider.db.getModels(Event(label: ''));
    events.sort((prev, next) => prev.label == next.label ? 0 : 1);
    setState(() {});
  }

  void onGoBack(Event event) {
    events.removeWhere((element) => element.id == event.id);
    events.add(event);
    events.sort((prev, next) => prev.label == next.label ? 0 : 1);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var orientation = MediaQuery.of(context).orientation;
    return SingleChildScrollView(
        child: Column(
      children: [
        Container(
          height: orientation == Orientation.landscape ? 100.w : 100.h,
          child: SfCalendar(
            backgroundColor: Colors.white,
            todayHighlightColor: Colors.green[800],
            cellBorderColor: Colors.black,
            allowViewNavigation: false,
            view: CalendarView.month,
            initialSelectedDate: DateTime.now(),
            allowAppointmentResize: true,
            dataSource: AppointmentDataSource(_getDataSource()),
            monthViewSettings: const MonthViewSettings(
              numberOfWeeksInView: 5,
              showAgenda: true,
              appointmentDisplayMode: MonthAppointmentDisplayMode.indicator,
            ),
            appointmentBuilder:
                (BuildContext context, CalendarAppointmentDetails details) {
              if (details.appointments.isNotEmpty) {
                final AppointmentExtend meeting = details.appointments.first;

                return GestureDetector(
                    onTap: () async {
                      var event = await DBProvider.db
                          .getModelById(meeting.eventId, Event(label: ""));
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => EventForm(
                                toCreate: false,
                                event: event,
                                onReturnToCalendar: onGoBack,
                              )));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: meeting.color,
                        border: Border.all(color: Colors.black, width: 0.0),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Container(
                        padding: EdgeInsets.only(left: 4.w),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    meeting.subject +
                                        (intl.DateFormat.yMd().format(
                                                    meeting.startTime) !=
                                                intl.DateFormat.yMd()
                                                    .format(meeting.endTime)
                                            ? " день ${details.date.day - meeting.startTime.day + 1}"
                                            : ""),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  flex: 4,
                                ),
                                Expanded(
                                  child: Text(
                                    (intl.DateFormat.yMd()
                                                .format(meeting.startTime) ==
                                            intl.DateFormat.yMd()
                                                .format(meeting.endTime)
                                        ? ""
                                        : intl.DateFormat.yMd()
                                                .format(meeting.startTime) +
                                            " - " +
                                            intl.DateFormat.yMd()
                                                .format(meeting.endTime)),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  flex: intl.DateFormat.yMd()
                                              .format(meeting.startTime) ==
                                          intl.DateFormat.yMd()
                                              .format(meeting.endTime)
                                      ? 0
                                      : 2,
                                )
                              ],
                            ),
                            if (intl.DateFormat.yMd()
                                    .format(meeting.startTime) ==
                                intl.DateFormat.yMd().format(meeting.endTime))
                              Row(
                                children: [
                                  Text(
                                    intl.DateFormat.Hm()
                                                .format(meeting.startTime) ==
                                            intl.DateFormat.Hm()
                                                .format(meeting.endTime)
                                        ? "В " +
                                            intl.DateFormat.Hm()
                                                .format(meeting.startTime)
                                        : intl.DateFormat.Hm()
                                                .format(meeting.startTime) +
                                            " - " +
                                            intl.DateFormat.Hm()
                                                .format(meeting.endTime),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              )
                          ],
                        ),
                      ),
                    ));
              } else {
                return Text("Немає івентів");
              }
            },
          ),
        )
      ],
    ));
  }

  Color fromHex(String hexString) {
    hexString = hexString
        .replaceAll("0x", "")
        .replaceAll("Color(", "")
        .replaceAll(")", "");
    if (hexString.isNotEmpty) {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    }
    return const Color(0xffc9e7f2);
  }

  List<AppointmentExtend> _getDataSource() {
    final List<AppointmentExtend> meetings = <AppointmentExtend>[];

    for (var element in events) {
      meetings.add(AppointmentExtend(
        extendEndTime: DateTime.parse(element.endDate!),
        extendStartTime: DateTime.parse(element.startDate!),
        extendColor: fromHex(element.calendarColor!),
        extendSubject: element.label,
        eventId: element.id!,
      ));
    }

    return meetings;
  }
}

class AppointmentExtend extends Appointment {
  DateTime extendStartTime;

  DateTime extendEndTime;

  Color extendColor;

  int eventId;

  String extendSubject;

  AppointmentExtend({
    required this.extendStartTime,
    required this.extendEndTime,
    required this.eventId,
    required this.extendColor,
    required this.extendSubject,
  }) : super(
            startTime: extendStartTime,
            endTime: extendEndTime,
            color: extendColor,
            subject: extendSubject);
}

class AppointmentDataSource extends CalendarDataSource {
  /// Creates a meeting data source, which used to set the appointment
  /// collection to the calendar
  AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
