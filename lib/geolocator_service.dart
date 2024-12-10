import 'package:geolocator/geolocator.dart';

class GeolocatorService {
  Future<Position> getCurrentLocation() async {
    // Check if location services are enabled
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw Exception("Location services are disabled");
    }

    // Request permission if not granted
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        throw Exception("Location permissions are permanently denied");
      }
    }

    // Get the current position
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    );
  }
}
