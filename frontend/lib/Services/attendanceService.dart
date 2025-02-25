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

String url = 'attendance/';
final uri = Uri.parse(url);

final InterceptedClient client = InterceptedClient();

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

    http.StreamedResponse response = await client.send(request);

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

    http.StreamedResponse response = await client.send(request);

    if (response.statusCode == 201) {
      return true;
    } else {
      throw Exception('Failed to save attendances: ${response.reasonPhrase}');
    }
  } catch (e) {
    throw Exception('Error occurred: $e');
  }
}

Future<bool> updateAttendanceAutoCheckout(
    int id, AttendanceModel attendance) async {
  try {
    Uri uriPut = Uri.parse('$url?id=$id');
    var request = http.MultipartRequest('PUT', uriPut);

    attendance.toJson().forEach((key, value) {
      request.fields[key] = value.toString();
    });

    http.StreamedResponse response = await client.send(request);

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
        await client.get(uri, headers: {'Accept': 'application/json'});

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
    final response = await client.get(uri);

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
  if (tempShift != null) {
    AttendanceModel? tempAttendance;
    await getEmployeeAttendance(user.id, Formatter.formatDate(DateTime.now()))
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
                employeeId: user,
                shiftId: tempShift?.id,
                portId: tempSite?.id,
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
            employeeId: user,
            shiftId: tempShift?.id,
            portId: tempSite?.port,
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
          employeeId: user,
          shiftId: tempShift?.id,
          portId: tempSite?.id,
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
  return null;
}

Future<List<AttendanceModel>> downloadReport(
    String startDate, String endDate, int? portId, String? employee) async {
  Map<String, dynamic>? queryParameters = {
    'start_date': startDate,
    'end_date': endDate
  };

  if (portId != null) {
    queryParameters['port_id'] = portId.toString();
  }

  if (employee != null && employee.isNotEmpty) {
    queryParameters['employee_name'] = employee;
  }

  final url = Uri.parse('attendance-report/');
  final response = await client.get(
    url.replace(queryParameters: queryParameters),
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    List<AttendanceModel> attendances = data.map((emp) {
      return AttendanceModel.fromJson(emp as Map<String, dynamic>);
    }).toList();
    return attendances;
  } else {
    return [];
  }
}

Future<bool> autoCheckout() async {
  EmployeeModel? user = await UserInfo.getUserInfo();

  await getEmployeeAttendance(
          user!.id, DateFormat('yyyy-MM-dd').format(DateTime.now()))
      .then((attendances) async {
    if (attendances.isNotEmpty) {
      AttendanceModel? att = attendances.firstWhere((attendance) {
        return attendance.checkOutTime == null;
      });
      if (att.attendanceType == 'OVERTIME') {
        await updateAttendanceAutoCheckout(att.id, att)
            .then((value) {})
            .then((result) {
          Workmanager().cancelByUniqueName('autoCheckOutTask');
        });
        return true;
      }
      TimeOfDay shiftEndTime = TimeOfDay.now();
      await getShiftById(att.shiftId!).then((result) {
        shiftEndTime = result[0].endTime!;
      });
      TimeOfDay now = TimeOfDay.now();
      if (now.isAfter(shiftEndTime)) {
        await updateAttendanceAutoCheckout(att.id, att)
            .then((value) {})
            .then((result) {
          Workmanager().cancelByUniqueName('autoCheckOutTask');
        });
      }
    }
  });

  return true;
}
