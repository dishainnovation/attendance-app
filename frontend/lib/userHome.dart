import 'dart:async';
import 'package:frontend/Utils/constants.dart';
import 'package:frontend/Utils/location.dart';
import 'package:frontend/widgets/employeeCard.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter/material.dart';
import 'package:frontend/Models/ShiftModel.dart';
import 'package:frontend/Services/shiftService.dart';
import 'package:provider/provider.dart';

import 'Models/AttendanceModel.dart';
import 'Models/EmployeeModel.dart';
import 'Models/ErrorObject.dart';
import 'Services/attendanceService.dart';
import 'Services/navigationService.dart';
import 'Services/userNotifier.dart';
import 'attendance.dart';
import 'employee.dart';
import 'widgets/Button.dart';
import 'widgets/ScaffoldPage.dart';
import 'widgets/ShiftCard.dart';
import 'Utils/formatter.dart';

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

  Future<AttendanceModel?> getAttendance() async {
    AttendanceModel? tempAttendance;
    EmployeeModel user = context.read<User>().user!;
    await getEmployeeAttendance(user.id, Formatter.formatDate(DateTime.now()))
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
    getAttendance();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      error: error,
      title: user != null ? user!.name : 'Home',
      showHeaderClip: true,
      body: Column(
        children: [
          // const SizedBox(
          //   height: 120,
          // ),
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Visibility(
                    visible: user != null,
                    child: EmployeeCard(employee: user!, isActionable: false)),
                Visibility(
                  visible: !isProfileCompleted,
                  child: const SizedBox(
                    height: 20,
                  ),
                ),
                Visibility(
                    visible: !isProfileCompleted,
                    child: completeProfile(context)),
                const SizedBox(
                  height: 20,
                ),
                shift != null
                    ? Visibility(
                        visible: attendance != null && shift != null,
                        child: ShiftCard(shift: shift!),
                      )
                    : Container(),
                const SizedBox(height: 40),
                attendance == null
                    ? Container(
                        padding: const EdgeInsets.all(20),
                        child: const Text(
                            'You are not currently checked in. To check in, please click the "Check-In" button below.'),
                      )
                    : Center(
                        child: LinearPercentIndicator(
                          animation: true,
                          barRadius: const Radius.circular(10),
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
                const SizedBox(height: 40),
                Button(
                  label: attendance != null && attendance!.checkOutTime == null
                      ? 'Check-Out'
                      : 'Check-In',
                  color: Colors.green[900]!,
                  width: 200,
                  onPressed: () {
                    Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const CheckIn()))
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
                const Divider(height: 40),
                tiles(),
              ],
            ),
          ),
        ],
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
          child: const Card(
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
          child: const Card(
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
        const Card(
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
      // width: MediaQuery.of(context).size.width * 0.5,
      child: Column(
        children: [
          const Text(
            'Please update your profile photo before check-in/check-out.',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          Button(
            label: 'Update Profile',
            color: Colors.red[900]!,
            width: MediaQuery.of(context).size.width * 0.5,
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Employee(
                    employee: user,
                    employeeesList: [],
                  ),
                ),
              ).then((value) {
                setState(() {
                  user = context.read<User>().user;
                });
              });
            },
          ),
        ],
      ),
    );
  }
}
