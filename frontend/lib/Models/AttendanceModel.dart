class AttendanceModel {
  int id;
  DateTime attendanceDate;
  int employeeId; // Assuming you use the employee's ID
  int? siteId; // Nullable site ID
  int shiftId;
  DateTime checkInTime;
  DateTime? checkOutTime; // Nullable checkout time
  double? latitude; // Nullable latitude
  double? longitude; // Nullable longitude
  String checkInPhoto;
  String? checkOutPhoto; // Nullable checkout photo
  String attendanceType;

  AttendanceModel(
      {required this.id,
      required this.attendanceDate,
      required this.employeeId,
      this.siteId,
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
        employeeId: json['employee_id'],
        siteId: json['site_id'],
        shiftId: json['shift_id'],
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
      'attendance_date': attendanceDate.toString(),
      'employee_id': employeeId,
      'site_id': siteId,
      'shift_id': shiftId,
      'check_in_time': '${checkInTime.hour}:${checkInTime.minute}',
      'check_out_time': '${checkOutTime!.hour}:${checkOutTime!.minute}',
      'latitude': latitude,
      'longitude': longitude,
      'check_in_photo': checkInPhoto,
      'check_out_photo': checkOutPhoto,
      'attendance_type': attendanceType
    };
  }
}
