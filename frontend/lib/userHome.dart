import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter/material.dart';
import 'package:frontend/Models/ShiftModel.dart';
import 'package:frontend/Services/shiftService.dart';
import 'package:provider/provider.dart';

import 'Models/AttendanceModel.dart';
import 'Models/EmployeeModel.dart';
import 'Models/ErrorObject.dart';
import 'Services/attendanceService.dart';
import 'Services/employeeService.dart';
import 'Services/navigationService.dart';
import 'Services/userNotifier.dart';
import 'Utility.dart';
import 'attendance.dart';
import 'employee.dart';
import 'widgets/Button.dart';
import 'widgets/ScaffoldPage.dart';
import 'widgets/ShiftCard.dart';
import 'widgets/TakePicture.dart';

class UserHome extends StatefulWidget {
  const UserHome({super.key});

  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  ErrorObject error = ErrorObject(title: '', message: '');
  EmployeeModel? user;
  String locationName = '';
  String time = '';
  double? latitude;
  double? longitude;
  AttendanceModel? attendance;
  ShiftModel? shift;
  double percentageDone = 0.00;
  bool isLoading = false;
  bool isProfileCompleted = false;

  checkProfile() {
    if (user!.profileImage == null) {
      setState(() {
        isProfileCompleted = false;
      });
    } else {
      setState(() {
        isProfileCompleted = true;
      });
    }
  }

  getLocation() async {
    try {
      await getCurrentLocation().then((location) async {
        await getLocationName(location).then((value) => setState(() {
              locationName = value;
              setState(() {
                latitude = location.latitude;
                longitude = location.longitude;
              });
            }));
      });
    } catch (e) {
      setState(() {
        error = ErrorObject(title: 'Error', message: e.toString());
      });
    }
  }

  Future<AttendanceModel?> getAttendance() async {
    AttendanceModel? tempAttendance;
    EmployeeModel user = context.read<User>().user!;
    await getEmployeeAttendance(user.id, formatDate(DateTime.now()))
        .then((attendances) {
      if (attendances.isNotEmpty) {
        tempAttendance =
            attendances.firstWhere((att) => att.checkOutTime == null);
      }
    });
    if (tempAttendance != null) {
      getShiftById(tempAttendance!.shiftId!).then((result) {
        setState(() {
          shift = result[0];
          percentageDone = calculateShiftPercentage(result[0]);
        });
      });
    }
    setState(() {
      attendance = tempAttendance;
    });
    return tempAttendance;
  }

  double calculateShiftPercentage(ShiftModel shift) {
    DateTime now = DateTime.now();
    DateTime start = _timeOfDayToDateTime(shift.startTime!);
    DateTime end = _timeOfDayToDateTime(shift.endTime!);

    Duration totalDuration = end.difference(start);
    Duration elapsedDuration = now.difference(start);

    double percentageElapsed =
        elapsedDuration.inMinutes / totalDuration.inMinutes;
    return percentageElapsed > 1 ? 1 : percentageElapsed;
  }

  DateTime _timeOfDayToDateTime(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    return DateTime(
        now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
  }

  @override
  void initState() {
    super.initState();
    user = context.read<User>().user;
    checkProfile();
    getLocation();
    getAttendance();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      error: error,
      title: user != null ? user!.name : 'Home',
      body: Column(
        children: [
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Visibility(visible: user != null, child: employeeCard(user!)),
                Visibility(
                  visible: !isProfileCompleted,
                  child: SizedBox(
                    height: 20,
                  ),
                ),
                Visibility(
                    visible: !isProfileCompleted,
                    child: completeProfile(context)),
                SizedBox(
                  height: 20,
                ),
                shift != null
                    ? Visibility(
                        visible: attendance != null && shift != null,
                        child: ShiftCard(shift: shift!),
                      )
                    : Container(),
                SizedBox(height: 40),
                Center(
                  child: LinearPercentIndicator(
                    animation: true,
                    barRadius: Radius.circular(10),
                    lineHeight: 30.0,
                    percent: percentageDone,
                    backgroundColor: Colors.grey[400],
                    progressColor: Colors.green,
                    leading: shift != null
                        ? Text(shift!.startTime!.format(context))
                        : Container(),
                    trailing: shift != null
                        ? Text(shift!.endTime!.format(context))
                        : Container(),
                  ),
                ),
                SizedBox(height: 40),
                Button(
                  label: attendance != null ? 'Check-Out' : 'Check-In',
                  color: Colors.green,
                  width: 200,
                  onPressed: () {
                    Navigator.push(context,
                            MaterialPageRoute(builder: (context) => CheckIn()))
                        .then((result) {
                      getAttendance();
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Divider(height: 40),
                tiles(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget employeeCard(EmployeeModel employee) {
    return Card(
      color: Colors.white,
      child: ListTile(
        title: Text(employee.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              employee.designation!.name,
              style: TextStyle(color: Colors.blueAccent),
            ),
            Text(
              employee.mobileNumber,
              style: TextStyle(color: Colors.grey),
            ),
            Divider(
              height: 8,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Code: ${employee.employeeCode}',
                  style: TextStyle(color: Colors.grey),
                ),
                Text(
                  'Port: ${employee.portName}',
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
            Text(
              'Gender: ${employee.gender}',
              style: TextStyle(color: Colors.grey),
            ),
            Divider(
              height: 8,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Birth : ${displayDate(DateTime.parse(employee.dateOfBirth))}',
                  style: TextStyle(
                    color: Colors.grey[900],
                    fontSize: 12,
                  ),
                ),
                Container(
                  color: Colors.grey,
                  width: 1,
                  height: 20,
                ),
                Text(
                  'Hire Date: ${displayDate(DateTime.parse(employee.dateOfJoining))}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[900],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget tiles() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Employee(
                  employee: user,
                  employeeesList: [],
                ),
              ),
            );
          },
          child: Card(
            color: Colors.green,
            child: SizedBox(
              height: 100,
              width: 110,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.white,
                  ),
                  Text(
                    'Profile',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        InkWell(
          onTap: () {
            NavigationService.navigateTo('/attendace-report');
          },
          child: Card(
            color: Colors.blue,
            child: SizedBox(
              height: 100,
              width: 110,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_month_outlined,
                    size: 50,
                    color: Colors.white,
                  ),
                  Text(
                    'Attendance',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Card(
          color: Colors.deepOrange,
          child: SizedBox(
            height: 100,
            width: 110,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 50,
                  color: Colors.white,
                ),
                Text(
                  'Overtime',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget completeProfile(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.5,
      child: Column(
        children: [
          Text(
            'Please update your profile photo before check-in/check-out.',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          Button(
            label: 'Capture Photo',
            color: Colors.blue,
            width: MediaQuery.of(context).size.width * 0.5,
            onPressed: () async {
              setState(() {
                isLoading = true;
              });
              final cameras = await availableCameras();
              final preferedtCamera = cameras[1];
              Navigator.of(context)
                  .push(MaterialPageRoute(
                      builder: (context) =>
                          TakePictureScreen(camera: preferedtCamera)))
                  .then((value) async {
                if (value != null) {
                  user!.profileImage = value.toString();
                  user!.employeePhoto = File(value.toString());
                  await updateEmployee(user!.id, user!, user!.employeePhoto!)
                      .then((value) async {
                    context.read<User>().user =
                        EmployeeModel.fromJson(user!.toJson());
                    storeUserInfo(user!);
                    await getLocation();
                    setState(() {
                      user = context.read<User>().user!;
                      isProfileCompleted = true;
                      isLoading = false;
                    });
                  }).catchError((err) {
                    showSnackBar(context, 'Employee', err.toString());
                  });
                } else {
                  setState(() {
                    isLoading = false;
                  });
                }
              });
            },
          ),
        ],
      ),
    );
  }
}
