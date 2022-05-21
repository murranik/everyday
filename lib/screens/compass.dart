import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math' as math;

import 'package:sizer/sizer.dart';

class CompassScreen extends StatefulWidget {
  const CompassScreen({
    Key? key,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() => _CompassScreenState();
}

class _CompassScreenState extends State<CompassScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    _fetchPermissionStatus();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _buildCompass(),
    );
  }

  Widget _buildCompass() {
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error reading heading: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        double? direction = snapshot.data!.heading;

        // if direction is null, then device does not support this sensor
        // show error message
        if (direction == null) {
          return const Center(
            child: Text("Device does not have sensors !"),
          );
        }

        return Material(
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            elevation: 4.0,
            child: Container(
              padding: const EdgeInsets.all(15),
              width: 80.w,
              height: 80.h,
              child: Transform.rotate(
                angle: (direction * (math.pi / 180) * -1),
                child: Image.asset(
                  'assets/images/compassarrow.png',
                  fit: BoxFit.fitWidth,
                ),
              ),
            ));
      },
    );
  }

  void _fetchPermissionStatus() {
    Permission.locationWhenInUse.status.then((status) {
      if (mounted) {}
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }
}
