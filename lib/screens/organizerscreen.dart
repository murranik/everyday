import 'package:everyday/forms/eventscreenform.dart';
import 'package:everyday/logic/database.dart';
import 'package:everyday/logic/models/event.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:sizer/sizer.dart';

class OrganizerScreen extends StatefulWidget {
  const OrganizerScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _OrganizerScreenState();
}

class _OrganizerScreenState extends State<OrganizerScreen> {
  List<Event> events = [];
  @override
  void initState() {
    getEvents();
    super.initState();
  }

  Future<void> getEvents() async {
    events = await DBProvider.db.getModels(Event(label: ''));
    setState(() {});
  }

  void addEventToList(Event event) {
    events.removeWhere((element) => element.id == event.id);
    events.add(event);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var orientation = MediaQuery.of(context).orientation;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            MaterialButton(
              color: const Color(0xff2A9863),
              onPressed: () async {
                Navigator.of(context)
                    .push(MaterialPageRoute(
                        builder: (context) => EventForm(
                              event: Event(label: ""),
                              addEventToList: addEventToList,
                              toCreate: true,
                            )))
                    .then((value) {
                  setState(() {});
                });
              },
              child: const Text("Додати подію"),
            ),
            MaterialButton(
              color: const Color(0xff2A9863),
              onPressed: () async {
                await DBProvider.db.clearDatabase();
                events.clear();
                setState(() {});
              },
              child: const Text("Видалити всі події"),
            ),
          ],
        ),
        Divider(
          thickness: 2.sp,
        ),
        SizedBox(
          height: orientation == Orientation.portrait ? 1.h : 1.w,
        ),
        Expanded(
          child: ListView(
            children: [
              for (var element in events)
                Dismissible(
                  key: UniqueKey(),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => EventForm(
                                event: element,
                                toCreate: false,
                                addEventToList: addEventToList,
                              )));
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          margin: EdgeInsets.only(left: 10.w, right: 10.w),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(26)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                  child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Text(intl.DateFormat.yMd().format(
                                              DateTime.parse(
                                                  element.startDate!)) +
                                          " в " +
                                          intl.DateFormat.Hm().format(
                                              DateTime.parse(
                                                  element.startDate!))),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 4.w,
                                      ),
                                      Expanded(
                                        child: Text(element.label),
                                      ),
                                      SizedBox(
                                        width: 4.w,
                                      ),
                                    ],
                                  )
                                ],
                              ))
                            ],
                          ),
                        ),
                        SizedBox(
                          height:
                              orientation == Orientation.portrait ? 1.w : 1.h,
                        )
                      ],
                    ),
                  ),
                  onDismissed: (direction) async {
                    await DBProvider.db.deleteModelById(element.id, "Events");
                    events.removeWhere((event) => element.id == event.id);
                    setState(() {});
                  },
                  background: Container(
                    color: Colors.red,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [Text("Видалити"), Text("Видалити")],
                    ),
                  ),
                )
            ],
          ),
        )
      ],
    );
  }
}
