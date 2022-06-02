// ignore_for_file: deprecated_member_use

import 'dart:math';
import 'dart:ui';

import 'package:everyday/views/countdowns.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class SecScreen extends StatefulWidget {
  const SecScreen({
    Key? key,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() => _SecScreenState();
}

class _SecScreenState extends State<SecScreen> with WidgetsBindingObserver {
  final StopWatchTimer _stopWatchTimer = StopWatchTimer(
    mode: StopWatchMode.countUp,
    onChange: (value) => print('onChange $value'),
    onChangeRawSecond: (value) => print('onChangeRawSecond $value'),
    onChangeRawMinute: (value) => print('onChangeRawMinute $value'),
  );

  final _scrollController = ScrollController();
  final _isHours = true;
  late CountdownsView countdownsView;

  @override
  void initState() {
    _stopWatchTimer.rawTime.listen((value) =>
        print('rawTime $value ${StopWatchTimer.getDisplayTime(value)}'));
    countdownsView = Provider.of<CountdownsView>(context, listen: false);
    _stopWatchTimer.minuteTime.listen((value) => print('minuteTime $value'));
    _stopWatchTimer.secondTime.listen((value) => print('secondTime $value'));
    _stopWatchTimer.records.listen((value) => print('records $value'));
    _stopWatchTimer.fetchStop.listen((value) => print('stop from stream'));
    _stopWatchTimer.fetchEnded.listen((value) => print('ended from stream'));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var orientation = MediaQuery.of(context).orientation;
    return Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 6,
          horizontal: 16,
        ),
        child: Column(
          children: [
            StreamBuilder<int>(
              stream: _stopWatchTimer.rawTime,
              initialData: _stopWatchTimer.rawTime.value,
              builder: (context, snap) {
                final value = snap.data!;
                final displayTime =
                    StopWatchTimer.getDisplayTime(value, hours: _isHours);
                return Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        displayTime,
                        style: const TextStyle(
                            fontSize: 40,
                            fontFamily: 'Helvetica',
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                );
              },
            ),
            StreamBuilder<List<StopWatchRecord>>(
              stream: _stopWatchTimer.records,
              initialData: _stopWatchTimer.records.value,
              builder: (context, snap) {
                final value = snap.data!;
                if (value.isEmpty) {
                  return const SizedBox.shrink();
                }
                Future.delayed(const Duration(milliseconds: 100), () {
                  _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut);
                });
                print('Listen records. $value');
                return ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.vertical,
                  itemBuilder: (BuildContext context, int index) {
                    final data = value[index];
                    return Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            '${index + 1} ${data.displayTime}',
                            style: const TextStyle(
                                fontSize: 17,
                                fontFamily: 'Helvetica',
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Divider(
                          height: 1,
                        )
                      ],
                    );
                  },
                  itemCount: value.length,
                );
              },
            ),
            if (orientation == Orientation.landscape)
              Expanded(
                  child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: RaisedButton(
                            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                            color: Colors.lightBlue[200],
                            shape: const StadiumBorder(),
                            onPressed: () async {
                              _stopWatchTimer.onExecute
                                  .add(StopWatchExecute.start);
                            },
                            child: Container(
                              width: 80,
                              alignment: Alignment.center,
                              child: const Text(
                                'Старт',
                                style: TextStyle(color: Colors.black),
                              ),
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: RaisedButton(
                            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                            color: Colors.lightGreen[300],
                            shape: const StadiumBorder(),
                            onPressed: () async {
                              _stopWatchTimer.onExecute
                                  .add(StopWatchExecute.stop);
                            },
                            child: Container(
                              width: 80,
                              alignment: Alignment.center,
                              child: const Text(
                                'Стоп',
                                style: TextStyle(color: Colors.black),
                              ),
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: RaisedButton(
                            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                            color: Colors.red[500],
                            shape: const StadiumBorder(),
                            onPressed: () async {
                              _stopWatchTimer.onExecute
                                  .add(StopWatchExecute.reset);
                              countdownsView.timeList.clear();
                              setState(() {});
                            },
                            child: Container(
                              width: 80,
                              alignment: Alignment.center,
                              child: const Text(
                                'Скинути',
                                style: TextStyle(color: Colors.black),
                              ),
                            )),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RaisedButton(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                          color: Colors.purple,
                          shape: const StadiumBorder(),
                          onPressed: () async {
                            countdownsView.timeList
                                .add(_stopWatchTimer.rawTime.value);
                            setState(() {});
                          },
                          child: Container(
                            width: 200,
                            alignment: Alignment.center,
                            child: const Text(
                              'Коло',
                              style: TextStyle(color: Colors.black),
                            ),
                          )),
                    ],
                  ),
                  SizedBox(
                    height: 0.5.h,
                  ),
                  Expanded(
                      child: SingleChildScrollView(
                    child: Column(
                      children: [
                        for (var i = 0; i < countdownsView.timeList.length; i++)
                          Container(
                              alignment: Alignment.center,
                              child: Builder(
                                builder: (BuildContext context) {
                                  var zeroSafetyIndex = i == 0 ? 1 : i;
                                  var count = zeroSafetyIndex ~/
                                      countdownsView.colors.length;
                                  var colorIndex = i >=
                                          countdownsView.colors.length
                                      ? i -
                                          (countdownsView.colors.length * count)
                                      : i;
                                  var padedTime = countdownsView.timeList[i]
                                      .toString()
                                      .padLeft(9, "0");
                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Коло ' + i.toString(),
                                        style: TextStyle(
                                            fontSize: 14.sp,
                                            color: countdownsView
                                                .colors[colorIndex]),
                                      ),
                                      Text(
                                        padedTime.substring(0, 2) +
                                            ":" +
                                            padedTime.substring(2, 4) +
                                            ":" +
                                            padedTime.substring(4, 6) +
                                            "." +
                                            padedTime.substring(6, 8),
                                        style: TextStyle(
                                            fontSize: 14.sp,
                                            color: countdownsView
                                                .colors[colorIndex]),
                                      ),
                                    ],
                                  );
                                },
                              )),
                      ],
                    ),
                  ))
                ],
              ))
            else
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: RaisedButton(
                              padding:
                                  const EdgeInsets.fromLTRB(20, 10, 20, 10),
                              color: Colors.lightBlue[200],
                              shape: const StadiumBorder(),
                              onPressed: () async {
                                _stopWatchTimer.onExecute
                                    .add(StopWatchExecute.start);
                              },
                              child: Container(
                                width: 80,
                                alignment: Alignment.center,
                                child: const Text(
                                  'Старт',
                                  style: TextStyle(color: Colors.black),
                                ),
                              )),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: RaisedButton(
                              padding:
                                  const EdgeInsets.fromLTRB(20, 10, 20, 10),
                              color: Colors.lightGreen[300],
                              shape: const StadiumBorder(),
                              onPressed: () async {
                                _stopWatchTimer.onExecute
                                    .add(StopWatchExecute.stop);
                              },
                              child: Container(
                                width: 80,
                                alignment: Alignment.center,
                                child: const Text(
                                  'Стоп',
                                  style: TextStyle(color: Colors.black),
                                ),
                              )),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: RaisedButton(
                              padding:
                                  const EdgeInsets.fromLTRB(20, 10, 20, 10),
                              color: Colors.red[500],
                              shape: const StadiumBorder(),
                              onPressed: () async {
                                _stopWatchTimer.onExecute
                                    .add(StopWatchExecute.reset);
                                countdownsView.timeList.clear();
                                setState(() {});
                              },
                              child: Container(
                                width: 80,
                                alignment: Alignment.center,
                                child: const Text(
                                  'Скинути',
                                  style: TextStyle(color: Colors.black),
                                ),
                              )),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: RaisedButton(
                              padding:
                                  const EdgeInsets.fromLTRB(20, 10, 20, 10),
                              color: Colors.purple,
                              shape: const StadiumBorder(),
                              onPressed: () async {
                                countdownsView.timeList
                                    .add(_stopWatchTimer.rawTime.value);
                                setState(() {});
                              },
                              child: Container(
                                width: 80,
                                alignment: Alignment.center,
                                child: const Text(
                                  'Коло',
                                  style: TextStyle(color: Colors.black),
                                ),
                              )),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 0.5.h,
                    ),
                    Expanded(
                        child: SingleChildScrollView(
                      child: Column(
                        children: [
                          for (var i = 0;
                              i < countdownsView.timeList.length;
                              i++)
                            Container(
                                alignment: Alignment.center,
                                child: Builder(
                                  builder: (BuildContext context) {
                                    var zeroSafetyIndex = i == 0 ? 1 : i;
                                    var count = zeroSafetyIndex ~/
                                        countdownsView.colors.length;
                                    var colorIndex =
                                        i >= countdownsView.colors.length
                                            ? i -
                                                (countdownsView.colors.length *
                                                    count)
                                            : i;
                                    var padedTime = countdownsView.timeList[i]
                                        .toString()
                                        .padLeft(9, "0");
                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Коло ' + i.toString(),
                                          style: TextStyle(
                                              fontSize: 14.sp,
                                              color: countdownsView
                                                  .colors[colorIndex]),
                                        ),
                                        Text(
                                          padedTime.substring(0, 2) +
                                              ":" +
                                              padedTime.substring(2, 4) +
                                              ":" +
                                              padedTime.substring(4, 6) +
                                              "." +
                                              padedTime.substring(6, 8),
                                          style: TextStyle(
                                              fontSize: 14.sp,
                                              color: countdownsView
                                                  .colors[colorIndex]),
                                        ),
                                      ],
                                    );
                                  },
                                )),
                        ],
                      ),
                    ))
                  ],
                ),
              )
          ],
        ));
  }

  @override
  void dispose() async {
    super.dispose();
    await _stopWatchTimer.dispose();
  }
}
