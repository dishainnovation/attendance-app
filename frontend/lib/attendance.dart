import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend/Models/AttendanceModel.dart';
import 'package:frontend/Models/ErrorObject.dart';
import 'package:frontend/Models/SiteModel.dart';
import 'package:frontend/widgets/ScaffoldPage.dart';
import 'package:provider/provider.dart';

import 'Models/EmployeeModel.dart';
import 'Models/ShiftModel.dart';
import 'Services/attendanceService.dart';
import 'Services/shiftService.dart';
import 'Services/terminalService.dart';
import 'Services/userNotifier.dart';
import 'Utility.dart';
import 'widgets/Button.dart';
import 'widgets/loading.dart';

class CheckIn extends StatefulWidget {
  const CheckIn({super.key});

  @override
  State<CheckIn> createState() => _CheckInState();
}

class _CheckInState extends State<CheckIn> {
  ErrorObject error = ErrorObject(title: '', message: '');
  bool _isSaving = false;
  String locationName = '';
  ShiftModel? shift;
  SiteModel? site;
  double? latitude;
  double? longitude;
  File? image;
  bool inTerminal = true;
  bool siteLoaded = false;
  AttendanceModel? attendance;
  bool isLoading = false;
  bool isCheckIn = true;
  String checkIn = "CHeck-In";
  String attendanceStatus = 'CHECK_IN';
  bool openAttendance = false;
  bool allowCheckOut = false;

  getLocation() async {
    await getCurrentLocation().then((location) async {
      setState(() {
        latitude = location.latitude;
        longitude = location.longitude;
      });
      await getLocationName(location).then((value) => setState(() {
            locationName = value;
          }));
    }).catchError((err) {
      throw Exception('Location permission not granted');
    });
  }

  Future<AttendanceModel?> getAttendance() async {
    AttendanceModel? tempAttendance;
    EmployeeModel user = context.read<User>().user!;
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
          } catch (e) {
            tempAttendance = attendances.first;
          }
        } else {
          if (attendances.first.checkOutTime == null) {
            // If only 1 record found then it's REGULAR
            tempAttendance = attendances.first;
          } else {
            // If no record found then it's OVERTIME
            tempAttendance = AttendanceModel(
                id: 0,
                attendanceDate: DateTime.now(),
                employeeId: user.id,
                shiftId: shift?.id,
                siteId: site?.id,
                checkInTime: DateTime.now(),
                checkInPhoto: null,
                attendanceType: 'OVERTIME');
          }
        }
      } else {
        // If no record found then it's REGULAR
        tempAttendance = AttendanceModel(
            id: 0,
            attendanceDate: DateTime.now(),
            employeeId: user.id,
            shiftId: shift?.id,
            siteId: site?.id,
            checkInTime: DateTime.now(),
            checkInPhoto: null,
            attendanceType: 'REGULAR');
      }
    }).catchError((err) {
      tempAttendance = AttendanceModel(
          id: 0,
          attendanceDate: DateTime.now(),
          employeeId: user.id,
          shiftId: shift?.id,
          siteId: site?.id,
          checkInTime: DateTime.now(),
          checkInPhoto: null,
          attendanceType: 'REGULAR');
    });
    return tempAttendance;
  }

  getData() async {
    try {
      ShiftModel? tempShift;
      SiteModel? tempSite;
      bool tempInTerminal = true;
      bool tempSiteLoaded = false;
      AttendanceModel? tempAttendance;

      setState(() {
        isLoading = true;
      });
      EmployeeModel user = context.read<User>().user!;
      await getLocation();
      await getSiteByLocation(user, user.port, latitude!, longitude!)
          .then((site) async {
        tempSite = site;
        tempInTerminal = site.id != 0;
        tempSiteLoaded = true;
      });
      await getCurrentShift(user.port, TimeOfDay.now()).then((shift) async {
        tempShift = shift;
      });
      tempAttendance = await getAttendance();
      if (tempAttendance!.attendanceType == 'OVERTIME' &&
          tempAttendance.id == 0) {
        await showAlertDialog(context, 'Overtime',
                "You've wrapped up for the day. Would you like to start your overtime now?")
            .then((result) async {
          if (!result) {
            Navigator.of(context).pop();
          }
        });
      }
      setState(() {
        site = tempSite;
        inTerminal = tempInTerminal;
        siteLoaded = tempSiteLoaded;
        siteLoaded = true;
        shift = tempShift;
        attendance = tempAttendance;
        attendance!.siteId = site!.id;
        attendance!.shiftId = shift != null ? shift!.id : 0;
        attendance!.latitude = latitude;
        attendance!.longitude = longitude;
        openAttendance = attendance!.checkOutTime != null;
        isCheckIn = attendance!.checkOutTime != null;
        checkIn = isCheckIn ? "Check-In" : "Check-Out";
        attendanceStatus = attendance!.attendanceType == 'OVERTIME'
            ? 'OVERTIME'
            : isCheckIn
                ? 'CHECK_IN'
                : 'CHECK_OUT';
        if (attendance!.attendanceType == 'REGULAR' &&
            attendance!.checkOutTime == null) {
          TimeOfDay now = TimeOfDay.now();
          if (now.isAfter(TimeOfDay.fromDateTime(attendance!.checkInTime)) &&
              !now.isBefore(shift!.endTime!)) {
            allowCheckOut = true;
          }
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = ErrorObject(title: 'Error', message: e.toString());
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    EmployeeModel user = context.read<User>().user!;
    return ScaffoldPage(
      error: error,
      title: user.name,
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  Card(
                    color: Colors.white,
                    child: SizedBox(
                      height: 60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            checkIn,
                            style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 20,
                                color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),
                  allowCheckOut
                      ? Column(
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            openAttendance ? completedShift() : Container(),
                            openAttendance
                                ? Container()
                                : isLoading
                                    ? Center(child: CircularProgressIndicator())
                                    : Column(
                                        children: [
                                          terminalCard(site!),
                                          shift != null
                                              ? Column(children: [
                                                  ...widgets(user),
                                                  SizedBox(height: 20),
                                                  image != null
                                                      ? Container()
                                                      : Text(
                                                          'Capture photo to $checkIn',
                                                          style: TextStyle(
                                                            color: Colors.red,
                                                          ),
                                                        ),
                                                  Button(
                                                    label: checkIn,
                                                    color: Colors.green,
                                                    width: 200,
                                                    onPressed: image == null ||
                                                            shift == null
                                                        ? null
                                                        : action,
                                                  ),
                                                ])
                                              : Padding(
                                                  padding: const EdgeInsets.all(
                                                      20.0),
                                                  child: Text(
                                                    'No shift available.',
                                                    style: TextStyle(
                                                        color: Colors.red[900],
                                                        fontSize: 20),
                                                  ),
                                                ),
                                        ],
                                      ),
                          ],
                        )
                      : SizedBox(
                          height: MediaQuery.of(context).size.height * 0.8,
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Checkout Denied',
                                style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red[900]),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 20),
                              Text(
                                'You cannot check out before your scheduled shift end time. Please complete your shift before attempting to check out.',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black),
                                textAlign: TextAlign.center,
                              ),
                              Divider(height: 50),
                              Button(
                                  label: 'Back',
                                  color: Colors.blue,
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  })
                            ],
                          )),
                  _isSaving == true
                      ? Positioned.fill(
                          child: LoadingWidget(message: 'Saving...'),
                        )
                      : Container(),
                ],
              ),
      ),
    );
  }

  Widget completedShift() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Card(
          color: Colors.white,
          child: ListTile(
            title: Text(
              'Shift Completed',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                'Your shift has been successfully completed. Thank you for your dedication and hard work.',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 13,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Shift Summary:',
                style:
                    TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
              ),
              Divider(),
              shift != null
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Start Time',
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              formatTimeOfDay(shift!.startTime!, context),
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          color: Colors.grey,
                          width: 1,
                          height: 50,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'End Time',
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              formatTimeOfDay(shift!.endTime!, context),
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          color: Colors.grey,
                          width: 1,
                          height: 50,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hours Worked',
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              shift!.durationHours.toString(),
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : Center(
                      child: CircularProgressIndicator(
                      color: Colors.grey,
                    )),
            ]),
          )),
    );
  }

  action() async {
    setState(() {
      _isSaving = true;
    });
    if (attendance!.id == 0) {
      await createAttendance(attendance!, image!).then((value) {
        setState(() {
          _isSaving = false;
        });
        Navigator.pop(context);
      });
    } else {
      TimeOfDay currentTime = TimeOfDay.now();
      if (currentTime.isBefore(shift!.endTime!) &&
          attendance!.attendanceType == 'REGULAR') {
        await showMessageDialog(context, 'Check-out',
            "You cannot check out now as your check-out time doesn't correspond with the shift's end time.");
        return;
      }
      await updateAttendance(attendance!.id, attendance!, image!).then((value) {
        setState(() {
          _isSaving = false;
        });
        Navigator.pop(context);
      });
    }
  }

  List<Widget> widgets(EmployeeModel user) {
    if (!inTerminal) {
      return [
        Column(
          children: [
            SizedBox(height: 40),
            Text(
              'You are not in any terminal.',
              style: TextStyle(
                fontSize: 20,
                color: Colors.red[900],
              ),
            ),
            SizedBox(height: 20),
            Text(
              '$checkIn requires you to be within the terminal range.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ];
    }
    return siteLoaded
        ? [
            shift != null ? shiftCard(shift!) : Text('No shift available.'),
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      image != null
                          ? Image.file(
                              image!,
                              height: 200,
                              width: 200,
                              fit: BoxFit.cover,
                            )
                          : Icon(
                              Icons.image,
                              size: 200,
                              color: Colors.grey,
                            ),
                      Button(
                        width: 140,
                        label: 'Capture Photo',
                        color: Colors.blue,
                        onPressed: () async {
                          final image1 = await captureImage();
                          setState(() {
                            image = File(image1!.path);
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ]
        : [];
  }

  Widget shiftCard(ShiftModel shift) {
    return Card(
      color: Colors.white,
      child: ListTile(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Shift:',
              style: TextStyle(
                fontSize: 14,
              ),
            ),
            // Divider(),
            Text(
              shift.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Start Time',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      formatTimeOfDay(shift.startTime!, context),
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.grey,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'End Time',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      formatTimeOfDay(shift.endTime!, context),
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.grey,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Duration Hours',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      shift.durationHours.toString(),
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget terminalCard(SiteModel site) {
    return Card(
      color: Colors.white,
      child: ListTile(
        isThreeLine: true,
        contentPadding: EdgeInsets.all(10),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "'Hello! You've entered the Terminal:",
              style: TextStyle(
                fontSize: 14,
              ),
            ),
            SizedBox(height: 10),
            Text(
              site.name,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
        subtitle: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(
              thickness: 1,
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Latitude',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      '${site.latitude}',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.grey,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Longitude',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      '${site.longitude}',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
