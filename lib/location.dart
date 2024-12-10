
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';


class LocationTracker extends StatefulWidget {
  @override
  _LocationTrackerState createState() => _LocationTrackerState();
}

class _LocationTrackerState extends State<LocationTracker> {
  late GoogleMapController _mapController;
  Position? position;
  LatLng _currentLatLng = const LatLng(0, 0);
  List<LatLng> _routePoints = [];
  Marker? _marker;
  Polyline? _polyline;

  @override
  void initState() {
    super.initState();
    listenCurrentPosition();
  }

  Future<void> listenCurrentPosition() async {
    final isGranted = await isLocationPermissionGranted();

    if (isGranted) {
      final isServiceEnabled = await checkGPSServicesEnable();
      if (isServiceEnabled) {
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.bestForNavigation,
            timeLimit: Duration(seconds: 2),
          ),
        ).listen(
              (pos) {
            _updateLocation(LatLng(pos.latitude, pos.longitude));
          },
        );
      } else {
        Geolocator.openLocationSettings();
      }
    } else {
      final result = await requestLocationPermission();
      if (result) {
        getCurrentLocation();
      } else {
        Geolocator.openAppSettings();
      }
    }
  }

  Future<void> getCurrentLocation() async {
    final isGranted = await isLocationPermissionGranted();

    if (isGranted) {
      final isServiceEnabled = await checkGPSServicesEnable();
      if (isServiceEnabled) {
        Position p = await Geolocator.getCurrentPosition();
        _updateLocation(LatLng(p.latitude, p.longitude));
      } else {
        Geolocator.openLocationSettings();
      }
    } else {
      final result = await requestLocationPermission();
      if (result) {
        getCurrentLocation();
      } else {
        Geolocator.openAppSettings();
      }
    }
  }

  Future<bool> isLocationPermissionGranted() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> checkGPSServicesEnable() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  void _updateLocation(LatLng newPosition) {
    setState(() {
      _currentLatLng = newPosition;
      _routePoints.add(newPosition);

      // Update marker
      _marker = Marker(
        markerId: const MarkerId('currentLocation'),
        position: newPosition,
        infoWindow: InfoWindow(
          title: 'My Current Location',
          snippet: '${newPosition.latitude}, ${newPosition.longitude}',
        ),
      );

      // Update polyline
      _polyline = Polyline(
        polylineId: const PolylineId('route'),
        points: _routePoints,
        color: Colors.blue,
        width: 5,
      );

      // Animate camera to the new position
      _mapController.animateCamera(
        CameraUpdate.newLatLng(newPosition),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Real-Time Location Tracker'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _currentLatLng,
          zoom: 14.0,
        ),
        onMapCreated: (controller) {
          _mapController = controller;
        },
        markers: _marker != null ? {_marker!} : {},
        polylines: _polyline != null ? {_polyline!} : {},
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}
