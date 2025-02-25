import 'package:frontend/Models/EmployeeModel.dart';
import 'package:frontend/Models/ShiftModel.dart';
import 'package:frontend/Models/SiteModel.dart';

import '../Utils/formatter.dart';

class AttendanceModel {
  int id;
  DateTime attendanceDate;
  EmployeeModel employeeId; // Assuming you use the employee's ID
  int? portId; // Nullable site ID
  int? shiftId;
  DateTime checkInTime;
  DateTime? checkOutTime; // Nullable checkout time
  double? latitude; // Nullable latitude
  double? longitude; // Nullable longitude
  String? checkInPhoto;
  String? checkOutPhoto; // Nullable checkout photo
  String attendanceType;

  AttendanceModel(
      {required this.id,
      required this.attendanceDate,
      required this.employeeId,
      this.portId,
      required this.shiftId,
      required this.checkInTime,
      this.checkOutTime,
      this.latitude,
      this.longitude,
      required this.checkInPhoto,
      this.checkOutPhoto,
      required this.attendanceType});

  // From JSON
  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
        id: int.parse(json['id'].toString()),
        attendanceDate: DateTime.parse(json['attendance_date']),
        employeeId: EmployeeModel.fromJson(json['employee']),
        portId: json['port'],
        shiftId: json['shift'],
        checkInTime: DateTime.parse(json['check_in_time']),
        checkOutTime: json['check_out_time'] != null
            ? DateTime.parse(json['check_out_time'])
            : null,
        latitude: json['latitude']?.toDouble(),
        longitude: json['longitude']?.toDouble(),
        checkInPhoto: json['check_in_photo'],
        checkOutPhoto: json['check_out_photo'],
        attendanceType: json['attendance_type']);
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id.toString(),
      'attendance_date': Formatter.formatDate(attendanceDate),
      'employee_id': employeeId.id,
      'port_id': portId,
      'shift_id': shiftId,
      'check_in_time': checkInTime,
      'check_out_time': checkOutTime,
      'latitude': latitude,
      'longitude': longitude,
      'check_in_photo': checkInPhoto,
      'check_out_photo': checkOutPhoto,
      'attendance_type': attendanceType
    };
  }
}

enum AttendanceStatus { NEW, CHECKED_IN, CHECKED_OUT }

class CurrentAttendance {
  AttendanceModel attendance;
  SiteModel site;
  ShiftModel shift;
  AttendanceStatus status = AttendanceStatus.NEW;

  CurrentAttendance(
      {required this.attendance,
      required this.site,
      required this.shift,
      required this.status});
}
