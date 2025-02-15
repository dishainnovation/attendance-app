import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import '../Models/AttendanceModel.dart';
import '../Utility.dart';
import 'package:http/http.dart' as http;

String url = '${baseUrl}attendance/';
final uri = Uri.parse(url);

Future<bool> createAttendance(AttendanceModel attendance, File file) async {
  try {
    var request = http.MultipartRequest('POST', uri);

    attendance.toJson().forEach((key, value) {
      request.fields[key] = value.toString();
    });

    final mimeTypeData =
        lookupMimeType(file.path, headerBytes: [0xFF, 0xD8])?.split('/');

    request.files.add(
      await http.MultipartFile.fromPath(
        'user_photo',
        file.path,
        contentType: MediaType(mimeTypeData![0], mimeTypeData[1]),
      ),
    );

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 201) {
      return true;
    } else {
      throw Exception('Failed to save attendances: ${response.reasonPhrase}');
    }
  } catch (e) {
    if (kDebugMode) {
      print(e);
    }
    throw Exception(e.toString());
  }
}

Future<bool> updateAttendance(
    int id, AttendanceModel attendance, File file) async {
  try {
    Uri uriPut = Uri.parse('$url?id=$id');
    var request = http.MultipartRequest('PUT', uriPut);

    attendance.toJson().forEach((key, value) {
      request.fields[key] = value.toString();
    });

    final mimeTypeData =
        lookupMimeType(file.path, headerBytes: [0xFF, 0xD8])?.split('/');

    request.files.add(
      await http.MultipartFile.fromPath(
        'user_photo',
        file.path,
        contentType: MediaType(mimeTypeData![0], mimeTypeData[1]),
      ),
    );

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 201) {
      return true;
    } else {
      throw Exception('Failed to save attendances: ${response.reasonPhrase}');
    }
  } catch (e) {
    throw Exception('Error occurred: $e');
  }
}

Future<List<AttendanceModel>> getAttendance() async {
  try {
    final response =
        await http.get(uri, headers: {"Accept": "application/json"});

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      List<AttendanceModel> attendances = data.map((emp) {
        return AttendanceModel.fromJson(emp as Map<String, dynamic>);
      }).toList();
      return attendances;
    } else {
      throw Exception('Failed to load attendance: ${response.reasonPhrase}');
    }
  } catch (e) {
    throw Exception('Error occurred: $e');
  }
}

Future<List<AttendanceModel>> getEmployeeAttendance(
    int employeeId, String? date) async {
  try {
    Uri uri = Uri.parse('$url?employee=$employeeId');
    if (date != null) {
      uri = Uri.parse('$url?employee=$employeeId&date=$date');
    }
    final response =
        await http.get(uri, headers: {"Accept": "application/json"});

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      List<AttendanceModel> attendances = data.map((emp) {
        return AttendanceModel.fromJson(emp as Map<String, dynamic>);
      }).toList();
      return attendances;
    } else {
      throw Exception('Failed to load attendance: ${response.reasonPhrase}');
    }
  } catch (e) {
    throw Exception('Error occurred: $e');
  }
}
