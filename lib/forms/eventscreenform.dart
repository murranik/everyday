import 'package:everyday/dialogs/financedialog.dart';
import 'package:everyday/logic/database.dart';
import 'package:everyday/logic/models/event.dart';
import 'package:everyday/logic/models/financemodel.dart';
import 'package:everyday/views/financemodelview.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:intl/intl.dart' as intl;
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:sqflite/sqflite.dart';

class EventForm extends StatefulWidget {
  final Event? event;
  final bool toCreate;
  final Function? addEventToList;
  final Function? onReturnToCalendar;

  const EventForm(
      {Key? key,
      this.event,
      required this.toCreate,
      this.addEventToList,
      this.onReturnToCalendar})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _EventFormState();
}

class _EventFormState extends State<EventForm> {
  TextEditingController titleController = TextEditingController();
  TextEditingController mainTextController = TextEditingController();
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  bool enableAlarm = false;
  var helpText = '';
  late Color calendarColor;
  late FinanceModelView financeModelView;
  late List<FinanceModel> listOfFinanceModels;

  @override
  void initState() {
    financeModelView = Provider.of<FinanceModelView>(context, listen: false);
    titleController.text = widget.event!.label;
    mainTextController.text = widget.event!.text ?? "";
    calendarColor = fromHex(
        widget.event!.calendarColor ?? const Color(0xff2A9863).toString());
    if (widget.event!.startDate != null) {
      startDate = DateTime.parse(widget.event!.startDate!);
    }
    if (widget.event!.endDate != null) {
      endDate = DateTime.parse(widget.event!.endDate!);
    }
    if (widget.event!.id != null) {
      financeModelView
          .load(widget.event!.id!)
          .then((value) => {if (mounted) setState(() {})});
    }
    super.initState();
  }

  void savePickedStartDate(DateTime dateTime) {
    startDate = dateTime;
    setState(() {});
  }

  void savePickedEndDate(DateTime dateTime) {
    endDate = dateTime;
    setState(() {});
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
    return const Color(0xff2A9863);
  }

  Future<bool> colorPickerDialog(Orientation orientation) async {
    return ColorPicker(
      // Use the dialogPickerColor as start color.
      color: calendarColor,
      // Update the dialogPickerColor using the callback.
      onColorChanged: (Color color) => setState(() => calendarColor = color),
      width: 40,
      height: 40,
      borderRadius: 4,
      spacing: 5,
      runSpacing: 5,
      wheelDiameter: 155,
      heading: Text(
        'Виберіть колір',
        style: Theme.of(context).textTheme.subtitle1,
      ),
      subheading: Text(
        'Виберіть відтінок кольору',
        style: Theme.of(context).textTheme.subtitle1,
      ),
      wheelSubheading: Text(
        'Вибраний колір та його відтінки',
        style: Theme.of(context).textTheme.subtitle1,
      ),
      borderColor: const Color(0xff2A9863),
      showMaterialName: true,
      showColorName: true,
      showColorCode: true,
      copyPasteBehavior: const ColorPickerCopyPasteBehavior(
        longPressMenu: true,
      ),
      materialNameTextStyle: Theme.of(context).textTheme.caption,
      colorNameTextStyle: Theme.of(context).textTheme.caption,
      colorCodeTextStyle: Theme.of(context).textTheme.caption,
      pickersEnabled: const <ColorPickerType, bool>{
        ColorPickerType.both: false,
        ColorPickerType.primary: true,
        ColorPickerType.accent: true,
        ColorPickerType.bw: false,
        ColorPickerType.custom: true,
        ColorPickerType.wheel: true,
      },
    ).showPickerDialog(
      context,
      constraints: BoxConstraints(
          minHeight: orientation == Orientation.portrait ? 80.w : 80.h,
          minWidth: orientation == Orientation.portrait ? 80.h : 80.w,
          maxWidth: orientation == Orientation.portrait ? 80.h : 80.w),
    );
  }

  @override
  Widget build(BuildContext context) {
    listOfFinanceModels = financeModelView.financeModels.length > 3
        ? financeModelView.financeModels
            .sublist(financeModelView.financeModels.length - 3,
                financeModelView.financeModels.length)
            .reversed
            .toList()
        : financeModelView.financeModels.reversed.toList();
    var orientation = MediaQuery.of(context).orientation;
    return WillPopScope(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xff2A9863),
            actions: [
              OutlinedButton(
                  onPressed: () async {
                    if (titleController.text.isNotEmpty) {
                      var event = Event(
                          label: titleController.text,
                          text: mainTextController.text,
                          startDate: startDate.toString(),
                          endDate: endDate.toString(),
                          id: widget.event!.id,
                          calendarColor: calendarColor
                              .toString()
                              .replaceAll("Color(", "")
                              .replaceAll(")", ""));
                      event.toString();
                      var res = await DBProvider.db.upsertModel(event) as Event;
                      if (widget.addEventToList != null) {
                        widget.addEventToList!(res);
                      }
                      if (widget.onReturnToCalendar != null) {
                        widget.onReturnToCalendar!(res);
                      }

                      for (var financeModel in financeModelView.financeModels) {
                        financeModel.eventId = res.id;
                        await DBProvider.db.upsertModel(financeModel);
                      }

                      Navigator.pop(context);
                      financeModelView.clear();
                    } else {
                      helpText = "Заповніть поле буть ласка";
                      setState(() {});
                    }
                  },
                  child: const Text(
                    "Зберегти",
                    style: TextStyle(color: Colors.white),
                  ))
            ],
          ),
          body: orientation == Orientation.landscape
              ? SingleChildScrollView(
                  child: Padding(
                  padding: EdgeInsets.all(10.sp),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          MaterialButton(
                            padding: EdgeInsets.only(
                              bottom: orientation == Orientation.portrait
                                  ? 2.5.w
                                  : 2.5.h,
                            ),
                            onPressed: () async {
                              final Color colorBeforeDialog = calendarColor;
                              if (!(await colorPickerDialog(orientation))) {
                                setState(() {
                                  calendarColor = colorBeforeDialog;
                                });
                              }
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Колір на календарі"),
                                Container(
                                  width: orientation == Orientation.portrait
                                      ? 10.w
                                      : 10.h,
                                  height: orientation == Orientation.portrait
                                      ? 5.h
                                      : 5.w,
                                  color: calendarColor,
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            width: orientation == Orientation.portrait
                                ? 80.w
                                : 60.h,
                            child: TextFormField(
                              controller: titleController,
                              decoration: InputDecoration(
                                errorText: helpText,
                                labelText: 'Назва події',
                                hintText: 'Заповніть, будь ласка, поле',
                                labelStyle:
                                    const TextStyle(color: Colors.black),
                                prefixIcon: const Icon(Icons.event,
                                    color: Color(0xff2A9863)),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(26),
                                  borderSide: const BorderSide(
                                      color: Color(0xff2A9863)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(26),
                                  borderSide: const BorderSide(
                                      color: Color(0xff2A9863)),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(26),
                                  borderSide: BorderSide(
                                      color: helpText.isEmpty
                                          ? const Color(0xff2A9863)
                                          : Colors.red),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(26),
                                  borderSide: BorderSide(
                                      color: helpText.isEmpty
                                          ? const Color(0xff2A9863)
                                          : Colors.red),
                                ),
                              ),
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  helpText = "";
                                  setState(() {});
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: orientation == Orientation.portrait ? 1.w : 1.h,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: const [
                          Text("Від"),
                          Text("До"),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          MaterialButton(
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                          content: Theme(
                                        data: ThemeData.light().copyWith(
                                          colorScheme: const ColorScheme.light()
                                              .copyWith(
                                            primary: const Color(0xff2A9863),
                                          ),
                                        ),
                                        child: DateTimePicker(
                                          type: DateTimePickerType
                                              .dateTimeSeparate,
                                          dateMask: 'd MMM, yyyy',
                                          firstDate: DateTime.now(),
                                          lastDate: DateTime(2100),
                                          initialValue: startDate.toString(),
                                          locale: const Locale("uk", "UA"),
                                          confirmText: "Зберегти",
                                          use24HourFormat: true,
                                          icon: const Icon(Icons.event),
                                          dateLabelText: 'Дата',
                                          timeLabelText: "Час",
                                          calendarTitle: "Календар",
                                          cancelText: "Відмінити",
                                          onChanged: (value) {
                                            savePickedStartDate(
                                                DateTime.parse(value));
                                          },
                                          onEditingComplete: () {
                                            "asadsd".toString();
                                          },
                                        ),
                                      ));
                                    });
                              },
                              child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 1.w, vertical: 1.h),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(25),
                                      border: Border.all(
                                          color: const Color(0xff2A9863),
                                          style: BorderStyle.solid)),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 1.w,
                                      ),
                                      Text(intl.DateFormat.yMMMMEEEEd("uk")
                                              .format(DateTime.parse(
                                                  startDate.toString())) +
                                          " o " +
                                          intl.DateFormat.Hm().format(
                                              DateTime.parse(
                                                  startDate.toString()))),
                                      SizedBox(
                                        width: 1.w,
                                      ),
                                    ],
                                  ))),
                          MaterialButton(
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                          content: Theme(
                                        data: ThemeData.light().copyWith(
                                          colorScheme: const ColorScheme.light()
                                              .copyWith(
                                            primary: const Color(0xff2A9863),
                                          ),
                                        ),
                                        child: DateTimePicker(
                                          type: DateTimePickerType
                                              .dateTimeSeparate,
                                          dateMask: 'd MMM, yyyy',
                                          firstDate: DateTime.now(),
                                          lastDate: DateTime(2100),
                                          initialValue: endDate.toString(),
                                          locale: const Locale("uk", "UA"),
                                          confirmText: "Зберегти",
                                          use24HourFormat: true,
                                          icon: const Icon(Icons.event),
                                          dateLabelText: 'Дата',
                                          timeLabelText: "Час",
                                          calendarTitle: "Календар",
                                          cancelText: "Відмінити",
                                          onChanged: (value) {
                                            savePickedEndDate(
                                                DateTime.parse(value));
                                          },
                                          onEditingComplete: () {
                                            "asadsd".toString();
                                          },
                                        ),
                                      ));
                                    });
                              },
                              child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 1.w, vertical: 1.h),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(25),
                                      border: Border.all(
                                          color: const Color(0xff2A9863),
                                          style: BorderStyle.solid)),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 1.w,
                                      ),
                                      Text(intl.DateFormat.yMMMMEEEEd("uk")
                                              .format(DateTime.parse(
                                                  endDate.toString())) +
                                          " o " +
                                          intl.DateFormat.Hm().format(
                                              DateTime.parse(
                                                  endDate.toString()))),
                                      SizedBox(
                                        width: 1.w,
                                      ),
                                    ],
                                  )))
                        ],
                      ),
                      SizedBox(
                        height: orientation == Orientation.portrait ? 2.w : 2.h,
                      ),
                      TextFormField(
                        controller: mainTextController,
                        maxLines: null,
                        decoration: InputDecoration(
                          labelStyle: const TextStyle(color: Colors.black),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(26),
                            borderSide:
                                const BorderSide(color: Color(0xff2A9863)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(26),
                            borderSide:
                                const BorderSide(color: Color(0xff2A9863)),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 1.h,
                      ),
                      DecoratedContainer(
                          onTap: () async {
                            var newFinanceModel =
                                FinanceModel(price: 0, isIncome: 1);
                            await showModalBottomSheet(
                                isScrollControlled: true,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25)),
                                context: context,
                                builder: (builder) {
                                  return Container(
                                      color: Colors.transparent,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: FinanceDialog(
                                          financeModel: newFinanceModel,
                                          update: (FinanceModel financeModel,
                                              {required bool toDelete}) {
                                            newFinanceModel = financeModel;
                                            setState(() {});
                                          },
                                        ),
                                      ));
                                });
                            if (newFinanceModel.id != null) {
                              financeModelView.financeModels
                                  .add(newFinanceModel);
                            }
                            setState(() {});
                          },
                          onTap2: () async {
                            var newFinanceModel =
                                FinanceModel(price: 0, isIncome: 0);
                            await showModalBottomSheet(
                                isScrollControlled: true,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25)),
                                context: context,
                                builder: (builder) {
                                  return Container(
                                      color: Colors.transparent,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: FinanceDialog(
                                          financeModel: newFinanceModel,
                                          update: (FinanceModel financeModel,
                                              {required bool toDelete}) {
                                            newFinanceModel = financeModel;
                                            setState(() {});
                                          },
                                        ),
                                      ));
                                });
                            if (newFinanceModel.id != null) {
                              financeModelView.financeModels
                                  .add(newFinanceModel);
                            }
                            setState(() {});
                          },
                          children: [],
                          colorMode: 4,
                          blockName: "Доходи"),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: listOfFinanceModels.length,
                        itemBuilder: (BuildContext context, int index) {
                          var m = listOfFinanceModels[index].isIncome == 1
                              ? "+"
                              : "-";
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Container(
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.symmetric(vertical: 0.3.h),
                                  decoration: BoxDecoration(
                                      color: m == "+"
                                          ? Colors.green
                                          : Colors.orange,
                                      borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.all(5),
                                  child: Text(
                                      listOfFinanceModels[index].label! +
                                          " " +
                                          m +
                                          listOfFinanceModels[index]
                                              .price
                                              .toString()),
                                ),
                              )
                            ],
                          );
                        },
                      )
                    ],
                  ),
                ))
              : SingleChildScrollView(
                  child: Padding(
                  padding: EdgeInsets.all(10.sp),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          SizedBox(
                            width: orientation == Orientation.portrait
                                ? 80.w
                                : 80.h,
                            child: TextFormField(
                              controller: titleController,
                              decoration: InputDecoration(
                                errorText: helpText,
                                labelText: 'Назва події',
                                labelStyle:
                                    const TextStyle(color: Colors.black),
                                prefixIcon: const Icon(Icons.event,
                                    color: Color(0xff2A9863)),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(26),
                                  borderSide: const BorderSide(
                                      color: Color(0xff2A9863)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(26),
                                  borderSide: const BorderSide(
                                      color: Color(0xff2A9863)),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(26),
                                  borderSide: BorderSide(
                                      color: helpText.isEmpty
                                          ? const Color(0xff2A9863)
                                          : Colors.red),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(26),
                                  borderSide: BorderSide(
                                      color: helpText.isEmpty
                                          ? const Color(0xff2A9863)
                                          : Colors.red),
                                ),
                              ),
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  helpText = "";
                                  setState(() {});
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          MaterialButton(
                            padding: EdgeInsets.only(
                              bottom: orientation == Orientation.portrait
                                  ? 2.5.w
                                  : 2.5.h,
                            ),
                            onPressed: () async {
                              final Color colorBeforeDialog = calendarColor;
                              // Wait for the picker to close, if dialog was dismissed,
                              // then restore the color we had before it was opened.
                              if (!(await colorPickerDialog(orientation))) {
                                setState(() {
                                  calendarColor = colorBeforeDialog;
                                });
                              }
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Колір на календарі"),
                                Container(
                                  width: orientation == Orientation.portrait
                                      ? 10.h
                                      : 10.h,
                                  height: orientation == Orientation.portrait
                                      ? 5.w
                                      : 5.w,
                                  color: calendarColor,
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: orientation == Orientation.portrait ? 1.w : 1.h,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Від"),
                          MaterialButton(
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                          content: Theme(
                                        data: ThemeData.light().copyWith(
                                          colorScheme: const ColorScheme.light()
                                              .copyWith(
                                            primary: const Color(0xff2A9863),
                                          ),
                                        ),
                                        child: DateTimePicker(
                                          type: DateTimePickerType
                                              .dateTimeSeparate,
                                          dateMask: 'd MMM, yyyy',
                                          firstDate: DateTime.now(),
                                          lastDate: DateTime(2100),
                                          initialValue: startDate.toString(),
                                          locale: const Locale("uk", "UA"),
                                          confirmText: "Зберегти",
                                          use24HourFormat: true,
                                          icon: const Icon(Icons.event),
                                          dateLabelText: 'Дата',
                                          timeLabelText: "Час",
                                          calendarTitle: "Календар",
                                          cancelText: "Відмінити",
                                          onChanged: (value) {
                                            savePickedStartDate(
                                                DateTime.parse(value));
                                          },
                                          onEditingComplete: () {
                                            "asadsd".toString();
                                          },
                                        ),
                                      ));
                                    });
                              },
                              child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 1.w, vertical: 1.h),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(25),
                                      border: Border.all(
                                          color: const Color(0xff2A9863),
                                          style: BorderStyle.solid)),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 1.w,
                                      ),
                                      Text(intl.DateFormat.yMMMMEEEEd("uk")
                                              .format(DateTime.parse(
                                                  startDate.toString())) +
                                          " o " +
                                          intl.DateFormat.Hm().format(
                                              DateTime.parse(
                                                  startDate.toString()))),
                                      SizedBox(
                                        width: 1.w,
                                      ),
                                    ],
                                  ))),
                          const Text("До"),
                          MaterialButton(
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                          content: Theme(
                                        data: ThemeData.light().copyWith(
                                          colorScheme: const ColorScheme.light()
                                              .copyWith(
                                            primary: const Color(0xff2A9863),
                                          ),
                                        ),
                                        child: DateTimePicker(
                                          type: DateTimePickerType
                                              .dateTimeSeparate,
                                          dateMask: 'd MMM, yyyy',
                                          firstDate: DateTime.now(),
                                          lastDate: DateTime(2100),
                                          initialValue: endDate.toString(),
                                          locale: const Locale("uk", "UA"),
                                          confirmText: "Зберегти",
                                          use24HourFormat: true,
                                          icon: const Icon(Icons.event),
                                          dateLabelText: 'Дата',
                                          timeLabelText: "Час",
                                          calendarTitle: "Календар",
                                          cancelText: "Відмінити",
                                          onChanged: (value) {
                                            savePickedEndDate(
                                                DateTime.parse(value));
                                          },
                                          onEditingComplete: () {
                                            "asadsd".toString();
                                          },
                                        ),
                                      ));
                                    });
                              },
                              child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 1.w, vertical: 1.h),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(25),
                                      border: Border.all(
                                          color: const Color(0xff2A9863),
                                          style: BorderStyle.solid)),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 1.w,
                                      ),
                                      Text(intl.DateFormat.yMMMMEEEEd("uk")
                                              .format(DateTime.parse(
                                                  endDate.toString())) +
                                          " o " +
                                          intl.DateFormat.Hm().format(
                                              DateTime.parse(
                                                  endDate.toString()))),
                                      SizedBox(
                                        width: 1.w,
                                      ),
                                    ],
                                  )))
                        ],
                      ),
                      SizedBox(
                        height: orientation == Orientation.portrait ? 2.w : 2.h,
                      ),
                      TextFormField(
                        controller: mainTextController,
                        maxLines: null,
                        decoration: InputDecoration(
                          labelStyle: const TextStyle(color: Colors.black),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(26),
                            borderSide:
                                const BorderSide(color: Color(0xff2A9863)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(26),
                            borderSide:
                                const BorderSide(color: Color(0xff2A9863)),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 1.h,
                      ),
                      DecoratedContainer(
                          onTap: () async {
                            var newFinanceModel =
                                FinanceModel(price: 0, isIncome: 0);
                            await showModalBottomSheet(
                                isScrollControlled: true,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25)),
                                context: context,
                                builder: (builder) {
                                  return Container(
                                      color: Colors.transparent,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: FinanceDialog(
                                          financeModel: newFinanceModel,
                                          update: (FinanceModel financeModel,
                                              {required bool toDelete}) {
                                            newFinanceModel = financeModel;
                                            setState(() {});
                                          },
                                        ),
                                      ));
                                });
                            if (newFinanceModel.id != null) {
                              financeModelView.financeModels
                                  .add(newFinanceModel);
                            }
                            setState(() {});
                          },
                          onTap2: () async {
                            var newFinanceModel =
                                FinanceModel(price: 0, isIncome: 0);
                            await showModalBottomSheet(
                                isScrollControlled: true,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25)),
                                context: context,
                                builder: (builder) {
                                  return Container(
                                      color: Colors.transparent,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: FinanceDialog(
                                          financeModel: newFinanceModel,
                                          update: (FinanceModel financeModel,
                                              {required bool toDelete}) {
                                            newFinanceModel = financeModel;
                                            setState(() {});
                                          },
                                        ),
                                      ));
                                });
                            if (newFinanceModel.id != null) {
                              financeModelView.financeModels
                                  .add(newFinanceModel);
                            }
                            setState(() {});
                          },
                          children: [],
                          colorMode: 4,
                          blockName: "Доходи"),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: listOfFinanceModels.length,
                        itemBuilder: (BuildContext context, int index) {
                          var m = listOfFinanceModels[index].isIncome == 1
                              ? "+"
                              : "-";
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Container(
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.symmetric(vertical: 0.3.h),
                                  decoration: BoxDecoration(
                                      color: m == "+"
                                          ? Colors.green
                                          : Colors.orange,
                                      borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.all(5),
                                  child: Text(
                                      listOfFinanceModels[index].label! +
                                          " " +
                                          m +
                                          listOfFinanceModels[index]
                                              .price
                                              .toString()),
                                ),
                              )
                            ],
                          );
                        },
                      )
                    ],
                  ),
                )),
        ),
        onWillPop: () async {
          financeModelView.clear();
          return true;
        });
  }
}

class DecoratedContainer extends StatefulWidget {
  final List<Widget> children;
  final String blockName;
  final int colorMode;
  final Function? onTap;
  final Function? onTap2;

  const DecoratedContainer(
      {Key? key,
      required this.children,
      required this.colorMode,
      required this.blockName,
      this.onTap,
      this.onTap2})
      : super(key: key);
  @override
  State<DecoratedContainer> createState() => _DecoratedContainerState();
}

class _DecoratedContainerState extends State<DecoratedContainer> {
  @override
  Widget build(BuildContext context) {
    var orientation = MediaQuery.of(context).orientation;
    return Builder(
      builder: (BuildContext context) {
        switch (widget.colorMode) {
          case 4:
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(
                        left: orientation == Orientation.landscape ? 3.w : 2.w,
                        right:
                            orientation == Orientation.landscape ? 8.w : 6.w),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(23),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.green,
                              offset: Offset(
                                  orientation == Orientation.landscape
                                      ? -8.w
                                      : -7.w,
                                  0.0)),
                        ]),
                    child: Row(
                      children: [
                        Text(
                          widget.blockName,
                          style: TextStyle(fontSize: 14.sp),
                        ),
                        if (widget.onTap != null)
                          IconButton(
                              iconSize: 18.sp,
                              onPressed: () {
                                widget.onTap!();
                              },
                              icon: const Icon(Icons.add))
                      ],
                    )),
                Container(
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(
                        left: orientation == Orientation.landscape ? 8.w : 7.w,
                        right:
                            orientation == Orientation.landscape ? 3.w : 4.w),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(23),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.orange,
                              offset: Offset(
                                  orientation == Orientation.landscape
                                      ? 8.w
                                      : 8.w,
                                  0.0)),
                        ]),
                    child: Row(
                      children: [
                        if (widget.onTap2 != null)
                          IconButton(
                              iconSize: 18.sp,
                              onPressed: () {
                                widget.onTap2!();
                              },
                              icon: const Icon(Icons.add)),
                        Text(
                          "Витрати",
                          style: TextStyle(fontSize: 14.sp),
                        ),
                      ],
                    )),
              ],
            );
          default:
            return Container();
        }
      },
    );
  }
}
