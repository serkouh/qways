import 'dart:async';
import 'dart:ui' as ui;
import 'package:dotted_border/dotted_border.dart';
import 'package:qways/localization/localization_const.dart';
import 'package:qways/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../constant/key.dart';

class StartRideScreen extends StatefulWidget {
  const StartRideScreen({super.key});

  @override
  State<StartRideScreen> createState() => _StartRideScreenState();
}

class _StartRideScreenState extends State<StartRideScreen> {
  GoogleMapController? mapController;

  bool pause = false;

  List<Marker> pauseMarker = [];

  List<Marker> resumeMarker = [];

  static const CameraPosition _currentPosition =
      CameraPosition(target: LatLng(51.507351, -0.127758), zoom: 12);

  PolylinePoints polylinePoints =
      PolylinePoints(apiKey: "AIzaSyCVgRxsFUXudZRBOCtja3AjV85Gr8VSiTc");
  Map<PolylineId, Polyline> polylines = {};

  final latLng = [
    {"latlng": const LatLng(51.548987, -0.155995), "id": 2},
    {"latlng": const LatLng(51.531691, -0.179013), "id": 3},
    {"latlng": const LatLng(51.522079, -0.089689), "id": 4},
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
          rideDetailBottomsheet(size),
          backButton(context),
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
        polylines: pause ? {} : Set<Polyline>.of(polylines.values),
        initialCameraPosition: _currentPosition,
        markers:
            pause ? Set.from(Set.from(resumeMarker)) : Set.from(pauseMarker),
        onMapCreated: mapCreated,
        zoomControlsEnabled: false,
      ),
    );
  }

  mapCreated(GoogleMapController controller) async {
    mapController = controller;
    await marker();
    await resumemarkers();
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

  rideDetailBottomsheet(Size size) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: DraggableScrollableSheet(
        initialChildSize: 0.48,
        minChildSize: 0.48,
        maxChildSize: 0.6,
        expand: true,
        builder: (BuildContext context, ScrollController scrollController) {
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
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    controller: scrollController,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(fixPadding * 2.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "City rider BK2252",
                                    style: bold18BlackText,
                                  ),
                                  heightSpace,
                                  Text(
                                    getTranslation(context, "start_ride.range"),
                                    style: semibold14Grey,
                                  ),
                                  const Text(
                                    "30-35 km",
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
                      DottedBorder(
                        padding: EdgeInsets.zero,
                        dashPattern: const [2.5],
                        color: primaryColor,
                        child: Container(),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(fixPadding * 2.0),
                        child: Row(
                          children: [
                            scooterWidget(
                                "assets/startRide/battery.png",
                                getTranslation(
                                    context, 'start_ride.battery_level'),
                                "90%"),
                            verticalDivider(),
                            scooterWidget(
                                "assets/startRide/clock.png",
                                getTranslation(context, 'start_ride.time_used'),
                                "02 : 15 min"),
                            verticalDivider(),
                            scooterWidget(
                                "assets/startRide/location-current.png",
                                getTranslation(context, 'start_ride.travelled'),
                                "3.5km"),
                          ],
                        ),
                      ),
                      pause
                          ? Container(
                              width: double.maxFinite,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: fixPadding * 2.0,
                                  vertical: fixPadding),
                              color: f0Color,
                              child: Row(
                                children: [
                                  Expanded(
                                      child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        getTranslation(
                                            context, 'start_ride.ride_paused'),
                                        style: bold16BlackText,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      height5Space,
                                      Text(
                                        getTranslation(
                                            context, 'start_ride.no_cost_till'),
                                        overflow: TextOverflow.ellipsis,
                                        style: semibold14Grey,
                                      )
                                    ],
                                  )),
                                  widthSpace,
                                  Column(
                                    children: [
                                      Image.asset(
                                        "assets/startRide/clock.png",
                                        height: 17,
                                        width: 17,
                                      ),
                                      height5Space,
                                      Text(
                                        getTranslation(
                                            context, 'start_ride.paused_time'),
                                        style: bold16Primary,
                                      ),
                                      const Text(
                                        "01 : 45 min",
                                        style: bold14BlackText,
                                      )
                                    ],
                                  )
                                ],
                              ),
                            )
                          : const SizedBox(),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(fixPadding * 2.0),
                  child: Row(
                    children: [
                      buttonWidget(
                          pause
                              ? getTranslation(context, 'start_ride.resume')
                              : getTranslation(context, 'start_ride.pause'),
                          primaryColor, () {
                        setState(() {
                          pause = !pause;
                        });
                      }),
                      widthSpace,
                      widthSpace,
                      buttonWidget(
                          getTranslation(context, 'start_ride.end_ride'),
                          redColor, () {
                        Navigator.pushNamed(context, '/endRide');
                      }),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  buttonWidget(String title, Color color, Function() onTap) {
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
            style: bold18White,
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

  marker() async {
    pauseMarker.add(
      Marker(
        markerId: const MarkerId("0"),
        rotation: 0.1,
        visible: true,
        position: const LatLng(51.514602, -0.146719),
        anchor: const Offset(0.4, 0.25),
        icon: BitmapDescriptor.fromBytes(
          await getBytesFromAsset("assets/home/marker.png", 130),
        ),
      ),
    );
    pauseMarker.add(
      Marker(
        markerId: const MarkerId("1"),
        position: const LatLng(51.552830, -0.093468),
        icon: BitmapDescriptor.fromBytes(
          await getBytesFromAsset("assets/direction/locationMarker.png", 170),
        ),
        anchor: const Offset(0.35, 0.4),
      ),
    );

    commanMarker(pauseMarker);
  }

  resumemarkers() async {
    resumeMarker.add(
      Marker(
        markerId: const MarkerId("Your Location"),
        position: const LatLng(51.537884, -0.132290),
        icon: BitmapDescriptor.fromBytes(
          await getBytesFromAsset("assets/direction/locationMarker.png", 170),
        ),
        anchor: const Offset(0.35, 0.4),
      ),
    );

    commanMarker(resumeMarker);
  }

  commanMarker(marker) async {
    for (int i = 0; i < latLng.length; i++) {
      marker.add(Marker(
        markerId: MarkerId(latLng[i]['id'].toString()),
        position: latLng[i]['latlng'] as LatLng,
        icon: BitmapDescriptor.fromBytes(
          await getBytesFromAsset("assets/home/marker.png", 130),
        ),
      ));
    }
  }

  getDirections() async {
    List<LatLng> polylineCoordinates = [];

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      request: PolylineRequest(
        origin: PointLatLng(37.7749, -122.4194), // San Francisco
        destination: PointLatLng(37.3382, -121.8863), // San Jose
        mode: TravelMode.driving,
      ),
    );

    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    }
    addPolyLine(polylineCoordinates);
  }

  addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = const PolylineId("poly");
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

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }
}
