import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/Models/SiteModel.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import '../Models/AttendanceModel.dart';
import '../Models/EmployeeModel.dart';
import '../Models/ShiftModel.dart';
import '../Utility.dart';
import 'package:http/http.dart' as http;

import 'shiftService.dart';
import 'terminalService.dart';

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
    } else if (response.statusCode == 204) {
      return false;
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

Future<CurrentAttendance?> getCurrentAttendance(
    EmployeeModel user, double? latitude, double? longitude) async {
  SiteModel? tempSite;
  ShiftModel? tempShift;
  await getSiteByLocation(user, user.port, latitude!, longitude!)
      .then((site) async {
    tempSite = site;
  });
  await getCurrentShift(user.port, TimeOfDay.now()).then((shift) async {
    tempShift = shift;
  });
  AttendanceModel? tempAttendance;
  await getEmployeeAttendance(user.id, formatDate(DateTime.now()))
      .then((attendances) {
    if (attendances.isNotEmpty) {
      if (attendances.length > 1) {
        // If more then 1 records found then it's OVERTIME
        try {
          AttendanceModel? att = attendances.firstWhere((attendance) {
            return attendance.checkOutTime == null;
          });
          tempAttendance = att;
          tempAttendance!.latitude = latitude;
          tempAttendance!.longitude = longitude;
        } catch (e) {
          tempAttendance = attendances.first;
          tempAttendance!.latitude = latitude;
          tempAttendance!.longitude = longitude;
        }
      } else {
        if (attendances.first.checkOutTime == null) {
          // If only 1 record found then it's REGULAR
          tempAttendance = attendances.first;
          tempAttendance!.latitude = latitude;
          tempAttendance!.longitude = longitude;
        } else {
          // If no record found then it's OVERTIME
          tempAttendance = AttendanceModel(
              id: 0,
              attendanceDate: DateTime.now(),
              employeeId: user.id,
              shiftId: tempShift?.id,
              siteId: tempSite?.id,
              checkInTime: DateTime.now(),
              checkInPhoto: null,
              latitude: latitude,
              longitude: longitude,
              attendanceType: 'OVERTIME');
        }
      }
    } else {
      // If no record found then it's REGULAR
      tempAttendance = AttendanceModel(
          id: 0,
          attendanceDate: DateTime.now(),
          employeeId: user.id,
          shiftId: tempShift?.id,
          siteId: tempSite?.id,
          checkInTime: DateTime.now(),
          checkInPhoto: null,
          latitude: latitude,
          longitude: longitude,
          attendanceType: 'REGULAR');
    }
  }).catchError((err) {
    tempAttendance = AttendanceModel(
        id: 0,
        attendanceDate: DateTime.now(),
        employeeId: user.id,
        shiftId: tempShift?.id,
        siteId: tempSite?.id,
        checkInTime: DateTime.now(),
        checkInPhoto: null,
        latitude: latitude,
        longitude: longitude,
        attendanceType: 'REGULAR');
  });

  AttendanceStatus status = tempAttendance!.id == 0
      ? AttendanceStatus.NEW
      : tempAttendance!.checkOutTime == null
          ? AttendanceStatus.CHECKED_IN
          : AttendanceStatus.CHECKED_OUT;

  CurrentAttendance attendance = CurrentAttendance(
      attendance: tempAttendance!,
      shift: tempShift!,
      site: tempSite!,
      status: status);
  return attendance;
}
