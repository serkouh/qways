import 'dart:async';
import 'dart:ui' as ui;
import 'package:qways/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../constant/key.dart';

class DirectionScreen extends StatefulWidget {
  const DirectionScreen({super.key});

  @override
  State<DirectionScreen> createState() => _DirectionScreenState();
}

class _DirectionScreenState extends State<DirectionScreen> {
  GoogleMapController? mapController;

  List<Marker> allMarkers = [];
  static const CameraPosition _currentPosition =
      CameraPosition(target: LatLng(51.507351, -0.127758), zoom: 12);

  PolylinePoints polylinePoints =
      PolylinePoints(apiKey: "AIzaSyCVgRxsFUXudZRBOCtja3AjV85Gr8VSiTc");
  Map<PolylineId, Polyline> polylines = {};

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
    if (mounted) {
      setState(() {});
    }
  }

  marker() async {
    allMarkers.add(
      Marker(
        markerId: const MarkerId("0"),
        rotation: 0.1,
        visible: true,
        position: const LatLng(51.488528, -0.168019),
        anchor: const Offset(0.4, 0.25),
        icon: BitmapDescriptor.fromBytes(
          await getBytesFromAsset("assets/direction/locationMarker.png", 170),
        ),
      ),
    );
    allMarkers.add(
      Marker(
        markerId: const MarkerId("1"),
        position: const LatLng(51.538311, -0.096560),
        icon: BitmapDescriptor.fromBytes(
          await getBytesFromAsset("assets/home/marker.png", 170),
        ),
        anchor: const Offset(0.35, 0.4),
      ),
    );
  }

  @override
  void initState() {
    getDirections();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: backButton(context),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      body: Stack(
        children: [
          googleMap(size),
          scooterDetail(size),
        ],
      ),
    );
  }

  backButton(BuildContext context) {
    return IconButton(
      padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
      onPressed: () {
        Navigator.pop(context);
      },
      icon: const Icon(
        Icons.arrow_back,
        color: black2FColor,
      ),
    );
  }

  googleMap(Size size) {
    return SizedBox(
      height: double.maxFinite,
      width: size.width,
      child: GoogleMap(
        mapType: MapType.terrain,
        polylines: Set<Polyline>.of(polylines.values),
        initialCameraPosition: _currentPosition,
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

  scooterDetail(Size size) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.all(fixPadding),
        margin: const EdgeInsets.all(fixPadding * 2.0),
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: blackColor.withOpacity(0.25),
              blurRadius: 6,
            )
          ],
        ),
        child: Row(
          children: [
            Image.asset(
              "assets/home/cycle1.png",
              width: size.width * 0.4,
            ),
            widthSpace,
            width5Space,
            const Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "6391 Elgin St. Celina, Mumbai ,Maharashtra",
                    style: bold15BlackText,
                  ),
                  height5Space,
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: greyColor,
                        size: 16,
                      ),
                      widthSpace,
                      Expanded(
                        child: Text(
                          "15 min/2.5 km",
                          style: semibold14Grey,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }
}
