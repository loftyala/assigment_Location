import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleMapController? googleMapController; // Change to nullable

  @override
  void dispose() {
    googleMapController?.dispose(); // Check before disposing
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Screen'),
      ),
      body: GoogleMap(
        mapType: MapType.satellite,
        initialCameraPosition: const CameraPosition(
          zoom: 16,
          target: LatLng(
            23.800507141895935,
            90.3722262378507,
          ),
        ),
        onTap: (LatLng? latLng) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('LatLng: $latLng')),
          );
        },
        zoomControlsEnabled: true,
        zoomGesturesEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          setState(() {
            googleMapController = controller; // Initialize controller
          });
        },
        trafficEnabled: true,
        markers: <Marker>{
          const Marker(
            markerId: MarkerId('initial-position'),
            position: LatLng(
              23.800507141895935,
              90.3722262378507,
            ),
          ),
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (googleMapController != null) {
            googleMapController!.animateCamera(
              CameraUpdate.newCameraPosition(
                const CameraPosition(
                  zoom: 16,
                  target: LatLng(
                    23.800507141895935,
                    90.3722262378507,
                  ),
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Google Map is not ready yet!"),
              ),
            );
          }
        },
        child: const Icon(Icons.location_history),
      ),
    );
  }
}
