import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Completer<GoogleMapController> _controller = Completer();
  LatLng? _currentPosition;
  Set<Polyline> _polylines = {};
  List<LatLng> _polylineCoordinates = [];
  Marker? _marker;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _determinePosition().then((position) {
      _animateToPosition(position);
      _startLocationUpdates();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _startLocationUpdates() async {
    _timer = Timer.periodic(Duration(seconds: 10), (_) async {
      Position position = await _determinePosition();
      _updateMarkerAndPolyline(position);
    });
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      throw Exception("Location services are disabled.");
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Location permission denied.");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception("Location permissions are permanently denied.");
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<void> _animateToPosition(Position position) async {
    LatLng target = LatLng(position.latitude, position.longitude);
    GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: target,
      zoom: 15.0,
    )));
    _updateMarkerAndPolyline(position);
  }

  void _updateMarkerAndPolyline(Position position) {
    LatLng newPosition = LatLng(position.latitude, position.longitude);
    setState(() {
      _currentPosition = newPosition;

      // Add to polyline coordinates
      if (_polylineCoordinates.isEmpty ||
          _polylineCoordinates.last != newPosition) {
        _polylineCoordinates.add(newPosition);
        _polylines.add(Polyline(
          polylineId: PolylineId('route'),
          points: _polylineCoordinates,
          color: Colors.blue,
          width: 5,
        ));
      }

      // Update marker
      _marker = Marker(
        markerId: MarkerId('currentLocation'),
        position: newPosition,
        infoWindow: InfoWindow(
          title: "My current location",
          snippet: "Lat: ${newPosition.latitude}, Lng: ${newPosition.longitude}",
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Google Maps & Geolocator"),
        backgroundColor: Colors.blueAccent,
      ),
      body: _currentPosition == null
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
          target: _currentPosition!,
          zoom: 15.0,
        ),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: _marker != null ? {_marker!} : {},
        polylines: _polylines,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}







/*
import 'package:flutter/material.dart';
import 'package:assigment_location/homeScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Google Maps & Geolocator',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(), // Fixed issue
    );
  }
}
*/
