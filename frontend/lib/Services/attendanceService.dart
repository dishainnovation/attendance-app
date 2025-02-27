import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/Models/SiteModel.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:workmanager/workmanager.dart';
import '../Models/AttendanceModel.dart';
import '../Models/EmployeeModel.dart';
import '../Models/ShiftModel.dart';
import 'package:http/http.dart' as http;

import '../Utils/formatter.dart';
import '../Utils/userInfo.dart';
import 'dioClient.dart';
import 'shiftService.dart';
import 'terminalService.dart';

final String url = 'attendance/';
final Uri uri = Uri.parse(url);
final InterceptedClient client = InterceptedClient();

Future<bool> createAttendance(AttendanceModel attendance, File file) async {
  try {
    var request = http.MultipartRequest('POST', uri);
    _addFieldsToRequest(request, attendance);

    await _addFileToRequest(request, file);

    return await _handleRequest(request, 201, 'Failed to save attendances');
  } catch (e) {
    if (kDebugMode) {
      print(e);
    }
    throw Exception('Error occurred: $e');
  }
}

Future<bool> updateAttendance(
    int id, AttendanceModel attendance, File file) async {
  try {
    Uri uriPut = Uri.parse('$url?id=$id');
    var request = http.MultipartRequest('PUT', uriPut);
    _addFieldsToRequest(request, attendance);

    await _addFileToRequest(request, file);

    return await _handleRequest(request, 201, 'Failed to save attendances');
  } catch (e) {
    throw Exception('Error occurred: $e');
  }
}

Future<bool> updateAttendanceAutoCheckout(
    int id, AttendanceModel attendance) async {
  try {
    Uri uriPut = Uri.parse('$url?id=$id');
    var request = http.MultipartRequest('PUT', uriPut);
    _addFieldsToRequest(request, attendance);

    return await _handleRequest(request, 201, 'Failed to save attendances');
  } catch (e) {
    throw Exception('Error occurred: $e');
  }
}

Future<List<AttendanceModel>> getAttendance() async {
  try {
    final response =
        await client.get(uri, headers: {'Accept': 'application/json'});

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((emp) => AttendanceModel.fromJson(emp)).toList();
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
    final response = await client.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((emp) => AttendanceModel.fromJson(emp)).toList();
    } else {
      throw Exception('Failed to load attendance: ${response.reasonPhrase}');
    }
  } catch (e) {
    throw Exception('Error occurred: $e');
  }
}

Future<CurrentAttendance?> getCurrentAttendance(
    EmployeeModel user, double? latitude, double? longitude) async {
  SiteModel? tempSite;
  ShiftModel? tempShift;

  tempSite = await getSiteByLocation(user, user.port, latitude!, longitude!);
  tempShift = await getCurrentShift(user.port, TimeOfDay.now());

  if (tempShift != null) {
    AttendanceModel? tempAttendance = await _getAttendanceForUser(
        user, latitude, longitude, tempShift, tempSite);

    AttendanceStatus status = tempAttendance!.id == 0
        ? AttendanceStatus.NEW
        : tempAttendance!.checkOutTime == null
            ? AttendanceStatus.CHECKED_IN
            : AttendanceStatus.CHECKED_OUT;

    return CurrentAttendance(
        attendance: tempAttendance,
        shift: tempShift,
        site: tempSite!,
        status: status);
  }
  return null;
}

Future<List<AttendanceModel>> downloadReport(
    String startDate, String endDate, int? portId, String? employee) async {
  final Map<String, dynamic>? queryParameters = {
    'start_date': startDate,
    'end_date': endDate,
    if (portId != null) 'port_id': portId.toString(),
    if (employee != null && employee.isNotEmpty) 'employee_name': employee,
  };

  final uri = Uri.parse('attendance-report/');
  final response = await client.get(
    uri.replace(queryParameters: queryParameters),
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((emp) => AttendanceModel.fromJson(emp)).toList();
  } else {
    return [];
  }
}

Future<bool> autoCheckout() async {
  final EmployeeModel? user = await UserInfo.getUserInfo();

  await getEmployeeAttendance(
          user!.id, DateFormat('yyyy-MM-dd').format(DateTime.now()))
      .then((attendances) async {
    if (attendances.isNotEmpty) {
      AttendanceModel? att = attendances
          .firstWhere((attendance) => attendance.checkOutTime == null);
      if (att.attendanceType == 'OVERTIME') {
        await updateAttendanceAutoCheckout(att.id, att);
        Workmanager().cancelByUniqueName('autoCheckOutTask');
      } else {
        TimeOfDay shiftEndTime = TimeOfDay.now();
        await getShiftById(att.shiftId!).then((result) {
          shiftEndTime = result[0].endTime!;
        });
        if (TimeOfDay.now().isAfter(shiftEndTime)) {
          await updateAttendanceAutoCheckout(att.id, att);
          Workmanager().cancelByUniqueName('autoCheckOutTask');
        }
      }
    }
  });

  return true;
}

void _addFieldsToRequest(
    http.MultipartRequest request, AttendanceModel attendance) {
  attendance.toJson().forEach((key, value) {
    request.fields[key] = value.toString();
  });
}

Future<void> _addFileToRequest(http.MultipartRequest request, File file) async {
  final mimeTypeData =
      lookupMimeType(file.path, headerBytes: [0xFF, 0xD8])?.split('/');
  request.files.add(
    await http.MultipartFile.fromPath(
      'user_photo',
      file.path,
      contentType: MediaType(mimeTypeData![0], mimeTypeData[1]),
    ),
  );
}

Future<AttendanceModel> _getAttendanceForUser(
    EmployeeModel user,
    double? latitude,
    double? longitude,
    ShiftModel? tempShift,
    SiteModel? tempSite) async {
  final List<AttendanceModel> attendances = await getEmployeeAttendance(
      user.id, Formatter.formatDate(DateTime.now()));
  AttendanceModel? tempAttendance;

  if (attendances.isNotEmpty) {
    try {
      tempAttendance = attendances
          .firstWhere((attendance) => attendance.checkOutTime == null);
    } catch (e) {
      tempAttendance = attendances.first;
    }
    tempAttendance!.latitude = latitude;
    tempAttendance!.longitude = longitude;
  } else {
    tempAttendance = AttendanceModel(
      id: 0,
      attendanceDate: DateTime.now(),
      employeeId: user,
      shiftId: tempShift?.id,
      portId: tempSite?.id,
      checkInTime: DateTime.now(),
      checkInPhoto: null,
      latitude: latitude,
      longitude: longitude,
      attendanceType: 'REGULAR',
    );
  }

  return tempAttendance;
}

Future<bool> _handleRequest(http.MultipartRequest request,
    int expectedStatusCode, String errorMessage) async {
  final http.StreamedResponse response = await client.send(request);

  if (response.statusCode == expectedStatusCode) {
    return true;
  } else {
    throw Exception('$errorMessage: ${response.reasonPhrase}');
  }
}
