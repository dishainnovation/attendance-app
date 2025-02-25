import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math' as math;

class LocationService {
  static Future<Position> getCurrentLocation() async {
    // Check permissions
    bool permission = await Permission.location.request().isGranted;
    if (permission) {
      // Get the current location
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      return position;
    } else {
      throw Exception('Location permission not granted');
    }
  }

  static Future<String> getLocationName(Position position) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isNotEmpty) {
      Placemark place = placemarks[0];
      return "${place.name}, ${place.locality}";
    } else {
      return "Unknown location";
    }
  }

  static double calculateDistance(double startLatitude, double startLongitude,
      double endLatitude, double endLongitude) {
    const earthRadius = 6371000; // Earth's radius in meters

    double dLat = _degreesToRadians(endLatitude - startLatitude);
    double dLon = _degreesToRadians(endLongitude - startLongitude);

    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(startLatitude)) *
            math.cos(_degreesToRadians(endLatitude)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    double distance = earthRadius * c;
    return distance;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * math.pi / 180;
  }
}
