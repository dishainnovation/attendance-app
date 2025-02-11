import 'dart:io';

class EmployeeModel {
  int id;
  String employeeCode;
  String name;
  String password;
  String mobileNumber;
  String gender;
  String? profileImage;
  String dateOfBirth;
  String dateOfJoining;
  int designation;
  String? designationName;
  int port;
  String? portName;
  File? employeePhoto;
  EmployeeModel(
      {required this.id,
      required this.employeeCode,
      required this.name,
      required this.mobileNumber,
      required this.gender,
      required this.password,
      required this.designation,
      this.profileImage,
      required this.dateOfBirth,
      required this.dateOfJoining,
      this.designationName,
      required this.port,
      this.portName,
      this.employeePhoto});

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    File? image;
    if (json['profile_image'] != null) {
      image = File(json['profile_image']);
    }

    return EmployeeModel(
        id: int.parse(json['id'].toString()),
        employeeCode: json['employee_code'],
        name: json['name'],
        mobileNumber: json['mobile_number'],
        gender: json['gender'],
        password: json['password'],
        designation: int.parse(json['designation'].toString()),
        profileImage: json['profile_image'],
        dateOfBirth: json['date_of_birth'],
        dateOfJoining: json['date_of_joining'],
        designationName: json['designation_name'],
        port: int.parse(json['port'].toString()),
        portName: json['port_name'],
        employeePhoto: image);
  }

  Map<String, dynamic> toJson() => {
        'id': id.toString(),
        'employee_code': employeeCode,
        'name': name,
        'mobile_number': mobileNumber,
        'gender': gender,
        'password': password,
        'designation': designation.toString(),
        'profile_image': profileImage,
        'date_of_birth': dateOfBirth.toString(),
        'date_of_joining': dateOfJoining.toString(),
        'designation_name': designationName,
        'port': port.toString(),
        'port_name': portName
      };
}
