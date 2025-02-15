import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/Models/EmployeeModel.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;

String url = 'http://192.168.0.102:8000';
String baseUrl = '${url}/api/';
String baseImageUrl = url;

Future<void> save(String name, double distance, File? image1) async {
  final position = await getCurrentLocation();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final data = {
    'name': name,
    'image': image1!.path,
    'latitude': position.latitude,
    'longitude': position.longitude
  };
  await prefs.setString('data', json.encode(data));
}

Future<dynamic> load() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final data = prefs.getString('data');
  if (data != null) {
    final decodedData = json.decode(data);
    return decodedData;
  } else {
    return null;
  }
}

Future<File?> captureImage() async {
  final ImagePicker picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.camera);
  if (pickedFile != null) {
    return File(pickedFile.path);
  } else {
    return File('');
  }
}

Future compareImages(File? image1, File? image2) async {
  try {
    if (image1 != null && image2 != null) {
      var request = http.MultipartRequest(
          'POST', Uri.parse('http://192.168.0.100:5000/imagecompare'));
      request.files
          .add(await http.MultipartFile.fromPath('image1', image1.path));
      request.files
          .add(await http.MultipartFile.fromPath('image2', image2.path));

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var responseJson = json.decode(responseData);
        if (responseJson.containsKey('match')) {
          return responseJson['match']
              ? 'Images match!'
              : 'Images do not match.';
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception(response.reasonPhrase);
      }
    }
  } catch (e) {
    throw Exception('Error comparing images: $e');
  }
}

Future<Position> getCurrentLocation() async {
  // Check permissions
  if (await Permission.location.request().isGranted) {
    // Get the current location
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return position;
  } else {
    throw Exception('Location permission not granted');
  }
}

Future<String> getLocationName(Position position) async {
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

double calculateDistance(double startLatitude, double startLongitude,
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

double _degreesToRadians(double degrees) {
  return degrees * math.pi / 180;
}

Future<void> showMessageDialog(context, String title, String message) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(message),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
              return;
            },
          ),
        ],
      );
    },
  );
}

Future<bool> showAlertDialog(context, String title, String message) async {
  bool result = false;
  await showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(message),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Yes'),
            onPressed: () {
              result = true;
              Navigator.of(context).pop();
              return;
            },
          ),
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              result = false;
              Navigator.of(context).pop();
              return;
            },
          ),
        ],
      );
    },
  );
  return result;
}

Future<EmployeeModel?> getUserInfo() async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('user_data');
    if (data != null) {
      final user = EmployeeModel.fromJson(jsonDecode(data));
      return user;
    } else {
      return null;
    }
  } catch (e) {
    print(e);
    return null;
  }
}

Future<bool> logout() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.remove('user_data');
}

String formatTimeOfDay(TimeOfDay timeOfDay, BuildContext context) {
  final localizations = MaterialLocalizations.of(context);
  return localizations.formatTimeOfDay(timeOfDay, alwaysUse24HourFormat: false);
}

TimeOfDay stringToTimeOfDay(String time) {
  final format = DateFormat.Hms(); // Use DateFormat.Hm() for "08:00"
  final dateTime = format.parse(time);
  return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
}

String formatDate(DateTime date) {
  return DateFormat("yyyy-MM-dd").format(date);
}

String displayDate(DateTime date) {
  return DateFormat("dd-MM-yyyy").format(date);
}

showSnackBar(BuildContext context, String title, String message) {
  final snackBar = SnackBar(content: Text(message));

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
