import 'dart:async';
import 'dart:ui' as ui;
import 'package:qways/localization/localization_const.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../constant/key.dart';
import '../../theme/theme.dart';

class EndRideScreen extends StatefulWidget {
  const EndRideScreen({super.key});

  @override
  State<EndRideScreen> createState() => _EndRideScreenState();
}

class _EndRideScreenState extends State<EndRideScreen> {
  GoogleMapController? mapController;

  PolylinePoints polylinePoints =
      PolylinePoints(apiKey: "AIzaSyCVgRxsFUXudZRBOCtja3AjV85Gr8VSiTc");
  Map<PolylineId, Polyline> polylines = {};

  List<Marker> allMarkers = [];
  static const CameraPosition _currentPosition =
      CameraPosition(target: LatLng(51.507351, -0.127758), zoom: 12);

  final startPoint = const LatLng(51.510969, -0.145688);
  final currentPoint = const LatLng(51.545144, -0.119235);
  final endPoint = const LatLng(51.550695, -0.084879);

  final latLng = [
    {"latlng": const LatLng(51.548987, -0.155995), "id": 2},
    {"latlng": const LatLng(51.531691, -0.179013), "id": 3},
    {"latlng": const LatLng(51.513747, -0.087284), "id": 4},
  ];

  @override
  void initState() {
    getDirections();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          googleMap(size),
          rideEndBottomsheet(size),
          backButton(context),
        ],
      ),
    );
  }

  rideEndBottomsheet(ui.Size size) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: BottomSheet(
        onClosing: () {},
        enableDrag: false,
        builder: (BuildContext context) {
          return Container(
            width: double.maxFinite,
            decoration: BoxDecoration(
              color: whiteColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30.0),
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.2),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(fixPadding * 2.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              getTranslation(context, 'end_ride.end_ride'),
                              style: bold18Primary,
                            ),
                            height5Space,
                            Text(
                              getTranslation(context, 'end_ride.drop_point'),
                              style: semibold16BlackText,
                            ),
                          ],
                        ),
                      ),
                      Image.asset(
                        "assets/startRide/scooter.png",
                        width: size.width * 0.35,
                        fit: BoxFit.cover,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.maxFinite,
                  padding: const EdgeInsets.symmetric(
                      horizontal: fixPadding * 2.0, vertical: fixPadding),
                  color: f0Color,
                  child: const Row(
                    children: [
                      Icon(
                        CupertinoIcons.placemark,
                        color: primaryColor,
                      ),
                      widthSpace,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "6391 Elgin St. Celina, Delaware 10299",
                              style: bold15BlackText,
                              overflow: TextOverflow.ellipsis,
                            ),
                            height5Space,
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 16,
                                  color: greyColor,
                                ),
                                width5Space,
                                Expanded(
                                  child: Text(
                                    "15 min/2.5 km",
                                    style: semibold14Grey,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                height5Space,
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
                  child: Text(
                    getTranslation(context, 'end_ride.make_sure_text'),
                    style: semibold14Primary,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(fixPadding * 2.0),
                  child: Row(
                    children: [
                      buttonWidget(getTranslation(context, 'end_ride.back'),
                          const Color(0xFFF8F8F8), primaryColor, () {
                        Navigator.pop(context);
                      }),
                      widthSpace,
                      widthSpace,
                      buttonWidget(getTranslation(context, 'end_ride.confirm'),
                          primaryColor, whiteColor, () {
                        Navigator.pushNamed(context, '/confirm');
                      }),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  buttonWidget(String title, Color color, Color textColor, Function() onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
              vertical: fixPadding * 1.4, horizontal: fixPadding),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(5.0),
            boxShadow: [
              BoxShadow(
                color: blackColor.withOpacity(0.25),
                blurRadius: 6,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: bold18White.copyWith(color: textColor),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  verticalDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: fixPadding),
      height: 70,
      width: 1,
      color: greyB4Color,
    );
  }

  scooterWidget(icon, title, detail) {
    return Expanded(
      child: Column(
        children: [
          Image.asset(
            icon,
            height: 30,
          ),
          height5Space,
          Text(
            title,
            style: bold16Primary,
          ),
          Text(
            detail,
            style: bold16BlackText,
          ),
        ],
      ),
    );
  }

  googleMap(Size size) {
    return SizedBox(
      height: double.maxFinite,
      width: size.width,
      child: GoogleMap(
        mapType: MapType.terrain,
        initialCameraPosition: _currentPosition,
        polylines: Set<Polyline>.of(polylines.values),
        markers: Set.from(allMarkers),
        onMapCreated: mapCreated,
        zoomControlsEnabled: false,
      ),
    );
  }

  mapCreated(GoogleMapController controller) async {
    mapController = controller;
    await marker();
    if (mounted) {
      setState(() {});
    }
  }

  static Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  backButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: fixPadding * 3.0),
      child: IconButton(
        padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const Icon(
          Icons.arrow_back,
          color: black2FColor,
        ),
      ),
    );
  }

  getDirections() async {
    List<LatLng> polylineCoordinates = [];
    List<LatLng> polylineCoordinates2 = [];

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      request: PolylineRequest(
        origin: PointLatLng(startPoint.latitude, startPoint.longitude),
        destination: PointLatLng(currentPoint.latitude, currentPoint.longitude),
        mode: TravelMode.driving,
      ),
    );

    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    }
    PolylineResult result2 = await polylinePoints.getRouteBetweenCoordinates(
      request: PolylineRequest(
        origin: PointLatLng(currentPoint.latitude, currentPoint.longitude),
        destination: PointLatLng(endPoint.latitude, endPoint.longitude),
        mode: TravelMode.driving,
      ),
    );

    if (result2.points.isNotEmpty) {
      for (var point in result2.points) {
        polylineCoordinates2.add(LatLng(point.latitude, point.longitude));
      }
    }
    addPolyLine(polylineCoordinates);
    addPolyLine2(polylineCoordinates2);
  }

  addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = const PolylineId("0");
    Polyline polyline = Polyline(
      polylineId: id,
      color: primaryColor,
      points: polylineCoordinates,
      width: 4,
    );
    polylines[id] = polyline;
    setState(() {});
  }

  addPolyLine2(List<LatLng> polylineCoordinates) {
    PolylineId id = const PolylineId("1");
    Polyline polyline = Polyline(
      polylineId: id,
      color: primaryColor,
      patterns: const [PatternItem.dot],
      points: polylineCoordinates,
      width: 4,
    );
    polylines[id] = polyline;
    setState(() {});
  }

  marker() async {
    allMarkers.add(
      Marker(
        markerId: const MarkerId("0"),
        rotation: 0.1,
        visible: true,
        position: startPoint,
        anchor: const Offset(0.4, 0.25),
        icon: BitmapDescriptor.fromBytes(
          await getBytesFromAsset("assets/home/marker.png", 130),
        ),
      ),
    );
    allMarkers.add(
      Marker(
        markerId: const MarkerId("1"),
        position: currentPoint,
        icon: BitmapDescriptor.fromBytes(
          await getBytesFromAsset("assets/direction/locationMarker.png", 170),
        ),
        anchor: const Offset(0.35, 0.4),
      ),
    );

    allMarkers.add(
      Marker(
        markerId: const MarkerId("end location"),
        position: endPoint,
        icon: BitmapDescriptor.fromBytes(
          await getBytesFromAsset("assets/home/marker.png", 130),
        ),
        anchor: const Offset(0.35, 0.4),
      ),
    );

    for (int i = 0; i < latLng.length; i++) {
      allMarkers.add(
        Marker(
          markerId: MarkerId(latLng[i]['id'].toString()),
          position: latLng[i]['latlng'] as LatLng,
          icon: BitmapDescriptor.fromBytes(
            await getBytesFromAsset("assets/home/marker.png", 130),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }
}
