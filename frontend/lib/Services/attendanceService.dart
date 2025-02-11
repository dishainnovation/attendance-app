import 'dart:convert';

import '../Models/AttendanceModel.dart';
import '../Utility.dart';
import 'package:http/http.dart' as http;

String url = '${baseUrl}designation/';
final uri = Uri.parse(url);

Future<AttendanceModel> createAttendance(AttendanceModel attendance) async {
  try {
    var request = await http.post(uri, body: attendance.toJson());

    if (request.statusCode == 201) {
      return AttendanceModel.fromJson(
          jsonDecode(request.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to save attendance: ${request.reasonPhrase}');
    }
  } catch (e) {
    throw Exception('Error occurred: $e');
  }
}

Future<AttendanceModel> updateAttendance(
    int id, AttendanceModel attendance) async {
  try {
    Uri uriPut = Uri.parse('$url$id/');
    var request = await http.put(uriPut, body: attendance.toJson());

    if (request.statusCode == 200) {
      return AttendanceModel.fromJson(
          jsonDecode(request.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to save attendance: ${request.reasonPhrase}');
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
      List<AttendanceModel> employees = data.map((emp) {
        return AttendanceModel.fromJson(emp as Map<String, dynamic>);
      }).toList();
      return employees;
    } else {
      throw Exception('Failed to load attendance: ${response.reasonPhrase}');
    }
  } catch (e) {
    throw Exception('Error occurred: $e');
  }
}

Future<List<AttendanceModel>> getEmployeeAttendance(
    int employeeId, DateTime? date) async {
  try {
    Uri uri = Uri.parse('$url?employee=$employeeId');
    if (date != null) {
      uri = Uri.parse('$url?employee=$employeeId&date=$date');
    }
    final response =
        await http.get(uri, headers: {"Accept": "application/json"});

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      List<AttendanceModel> employees = data.map((emp) {
        return AttendanceModel.fromJson(emp as Map<String, dynamic>);
      }).toList();
      return employees;
    } else {
      throw Exception('Failed to load attendance: ${response.reasonPhrase}');
    }
  } catch (e) {
    throw Exception('Error occurred: $e');
  }
}
