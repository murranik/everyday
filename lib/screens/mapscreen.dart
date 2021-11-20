import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
@override
  void initState() {
    super.initState();
  }
  final Completer<GoogleMapController> _controller = Completer();

  static const CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

Future<BitmapDescriptor> createCustomMarkerBitmap(String title) async {
  TextSpan span = TextSpan(
    style: const TextStyle(
      fontSize: 35.0,
      fontWeight: FontWeight.bold,
    ),
    text: title,
  );

  var bkImage = await rootBundle.load("assets/images/mapmarker.jpg");

  Uint8List lst = Uint8List.view(bkImage.buffer);
  var codec = await ui.instantiateImageCodec(lst, targetHeight: 256, targetWidth: 256);
  var frameInfo = await codec.getNextFrame();
  var res = frameInfo.image;


  TextPainter tp = TextPainter(
    text: span,
    textAlign: TextAlign.center,
    textDirection: TextDirection.ltr,
  );
  tp.text = TextSpan(
    text: title,
    style: const TextStyle(
      fontSize: 35.0,
      color: Colors.black,
      letterSpacing: 1.0,
      fontFamily: 'Roboto Bold',
    ),
  );

  PictureRecorder recorder = PictureRecorder();
  Canvas c = Canvas(recorder);
  c.drawImage(res, const Offset(0.0, 0.0), Paint());

  tp.layout();
  tp.paint(c, const Offset(30.0, 45.0));

  /* Do your painting of the custom icon here, including drawing text, shapes, etc. */

  Picture p = recorder.endRecording();
  ByteData? pngBytes =
  await (await p.toImage(tp.width.toInt() + 256, tp.height.toInt() + 256))
      .toByteData(format: ImageByteFormat.png);

  Uint8List data = Uint8List.view(pngBytes!.buffer);

  return BitmapDescriptor.fromBytes(data);
}

  @override
  Widget build(BuildContext context) {
    var orientation = MediaQuery.of(context).orientation;
    return FutureBuilder(
      future: _determinePosition(),
        builder: (context, AsyncSnapshot<Position> snapshot){
          if(snapshot.hasData){
            LatLng currentLatLng = LatLng(snapshot.data!.latitude, snapshot.data!.longitude);
            var userCameraPosition = CameraPosition(
              target: LatLng(currentLatLng.latitude, currentLatLng.longitude),
              zoom: 20,
            );
            return FutureBuilder(
              future: createCustomMarkerBitmap("suck"),
                builder: (context, snapshot) {
                  if(snapshot.hasData){
                    return GoogleMap(
                        mapType: MapType.normal,
                        initialCameraPosition: userCameraPosition,
                        onMapCreated: (GoogleMapController controller) {
                          _controller.complete(controller);
                        },
                        markers: {
                          Marker(markerId: const MarkerId('suck'), position: currentLatLng, icon: snapshot.data as BitmapDescriptor),
                        }
                    );
                  }
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          CircularProgressIndicator()
                        ],
                      )
                    ],
                  );
                }
            );
          } else {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    CircularProgressIndicator()
                  ],
                )
              ],
            );
          }
        }
    );
  }

}