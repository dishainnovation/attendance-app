import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:frontend/Models/AttendanceModel.dart';
import 'package:frontend/Models/ErrorObject.dart';
import 'package:frontend/Models/SiteModel.dart';
import 'package:frontend/widgets/ScaffoldPage.dart';
import 'package:frontend/widgets/SpinKit.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';

import 'Models/EmployeeModel.dart';
import 'Models/ShiftModel.dart';
import 'Services/attendanceService.dart';
import 'Services/userNotifier.dart';
import 'Utils/constants.dart';
import 'widgets/Button.dart';
import 'widgets/TakePicture.dart';
import 'Utils/dialogs.dart';
import 'Utils/formatter.dart';
import 'Utils/location.dart';
import 'widgets/loading.dart';

class CheckIn extends StatefulWidget {
  const CheckIn({super.key});

  @override
  State<CheckIn> createState() => _CheckInState();
}

class _CheckInState extends State<CheckIn> {
  EmployeeModel? user;
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
  bool isLoading = true;
  String checkInLabel = 'CHeck-In';
  String attendanceStatus = 'CHECK_IN';
  bool openAttendance = false;
  bool isAllowCheckOut = false;

  getLocation() async {
    await LocationService.getCurrentLocation().then((location) async {
      setState(() {
        latitude = location.latitude;
        longitude = location.longitude;
      });
      await LocationService.getLocationName(location)
          .then((value) => setState(() {
                locationName = value;
              }));
    }).catchError((err) {
      throw Exception('Location permission not granted');
    });
  }

  getData() async {
    try {
      CurrentAttendance? tempAttendance;

      setState(() {
        isLoading = true;
      });
      user = context.read<User>().user!;
      await getLocation();

      tempAttendance = await getCurrentAttendance(user!, latitude!, longitude!);

      if (tempAttendance!.attendance.attendanceType == 'OVERTIME' &&
          tempAttendance.attendance.id == 0) {
        await Dialogs.showAlertDialog(context, 'Overtime',
                "You've wrapped up for the day. Would you like to start your overtime now?")
            .then((result) async {
          if (!result) {
            Navigator.of(context).pop();
          }
        });
      }

      setState(() {
        site = tempAttendance!.site;
        inTerminal = site!.id != 0;
        siteLoaded = true;
        shift = tempAttendance.shift;
        attendance = tempAttendance.attendance;
        openAttendance = tempAttendance.status == AttendanceStatus.CHECKED_OUT;

        checkInLabel = tempAttendance.status != AttendanceStatus.CHECKED_IN
            ? 'Check-In'
            : 'Check-Out';
        attendanceStatus = attendance!.attendanceType == 'OVERTIME'
            ? 'OVERTIME'
            : tempAttendance.status != AttendanceStatus.CHECKED_IN
                ? 'CHECK_IN'
                : 'CHECK_OUT';
        isAllowCheckOut = attendance!.id == 0;
        if (attendance!.attendanceType == 'REGULAR' &&
            attendance!.id > 0 &&
            attendance!.checkOutTime == null) {
          TimeOfDay now = TimeOfDay.now();
          TimeOfDay checkedInTime =
              TimeOfDay.fromDateTime(attendance!.checkInTime);
          TimeOfDay shiftEndTime = shift!.endTime!;
          if (now.isAfter(checkedInTime) && !now.isBefore(shiftEndTime)) {
            isAllowCheckOut = true;
          }
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
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
    Size screenSize = MediaQuery.of(context).size;
    return ScaffoldPage(
      error: error,
      title: user.name,
      body: Stack(
        children: [
          if (!isLoading)
            Column(
              children: [
                pageTitleCard(),
                Visibility(
                  visible: !inTerminal,
                  child: outOfTerminalCard(),
                ),
                Visibility(
                  visible: inTerminal && isAllowCheckOut,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Visibility(
                        visible: openAttendance,
                        child: completedShift(),
                      ),
                      Visibility(
                        visible: openAttendance == false,
                        child: Column(
                          children: [
                            terminalCard(site!),
                            shiftCard(shift),
                            iamgeCard(context, screenSize),
                            const SizedBox(height: 20),
                            Visibility(
                              visible: image == null,
                              child: Text(
                                'Capture photo to $checkInLabel',
                                style: TextStyle(
                                  color: Colors.red[900],
                                ),
                              ),
                            ),
                            Button(
                              label: checkInLabel,
                              color: Colors.green,
                              width: 200,
                              onPressed: image == null || shift == null
                                  ? null
                                  : action,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Visibility(
                    visible: !isAllowCheckOut,
                    child: checkoutDeniedCard(context)),
              ],
            ),
          _isSaving == true
              ? Positioned.fill(
                  child: LoadingWidget(message: 'Saving...'),
                )
              : Container(),
          if (isLoading)
            const Positioned.fill(
              child: SpinKit(
                type: spinkitType,
              ),
            )
        ],
      ),
    );
  }

  SizedBox checkoutDeniedCard(BuildContext context) {
    return SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
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
            const SizedBox(height: 20),
            const Text(
              'You cannot check out before your scheduled shift end time. Please complete your shift before attempting to check out.',
              style: TextStyle(fontSize: 16, color: Colors.black),
              textAlign: TextAlign.center,
            ),
            const Divider(height: 50),
            Button(
                label: 'Back',
                color: Colors.blue,
                onPressed: () {
                  Navigator.of(context).pop();
                })
          ],
        ));
  }

  Column outOfTerminalCard() {
    return Column(
      children: [
        const SizedBox(height: 40),
        Text(
          'You are not in any terminal.',
          style: TextStyle(
            fontSize: 20,
            color: Colors.red[900],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          '$checkInLabel requires you to be within the terminal range.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Card pageTitleCard() {
    return Card(
      color: Colors.white,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              checkInLabel,
              style: const TextStyle(
                  fontFamily: 'Nunito', fontSize: 20, color: Colors.black),
            ),
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
            title: const Text(
              'Shift Completed',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text(
                'Your shift has been successfully completed. Thank you for your dedication and hard work.',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Shift Summary:',
                style:
                    TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              shift != null
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Start Time',
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              Formatter.formatTimeOfDay(
                                  shift!.startTime!, context),
                              style: const TextStyle(
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
                            const Text(
                              'End Time',
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              Formatter.formatTimeOfDay(
                                  shift!.endTime!, context),
                              style: const TextStyle(
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
                            const Text(
                              'Hours Worked',
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              shift!.durationHours.toString(),
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : const Center(
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
        scheduleCheckOutTask();
        setState(() {
          _isSaving = false;
        });
        if (value) {
          Navigator.pop(context);
        } else {
          Dialogs.showMessageDialog(context, 'Attendance',
              "Your photo doesn't match the profile. Please try again.");
        }
      });
    } else {
      TimeOfDay currentTime = TimeOfDay.now();
      if (currentTime.isBefore(shift!.endTime!) &&
          attendance!.attendanceType == 'REGULAR') {
        await Dialogs.showMessageDialog(context, 'Check-out',
            "You cannot check out now as your check-out time doesn't correspond with the shift's end time.");
        setState(() {
          _isSaving = false;
        });
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

  void scheduleCheckOutTask() {
    Workmanager().registerPeriodicTask(
      'autoCheckOutTask', // Unique name for the task
      'autoCheckOut', // Task name
      frequency: const Duration(minutes: 1),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
      ),
      initialDelay: Duration(
          hours: shift!
              .durationHours), // Adjust the duration according to the shift length
      inputData: {
        'user': user?.id, // Pass any necessary data
      },
    );
  }

  Card iamgeCard(BuildContext context, Size screenSize) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              image != null
                  ? Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 0.5),
                          borderRadius: BorderRadius.circular(7)),
                      child: Image.file(
                        image!,
                        height: screenSize.width * 0.4,
                        width: screenSize.width * 0.4,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Icon(
                      Icons.image_outlined,
                      size: screenSize.width * 0.4,
                      color: Colors.grey[300],
                    ),
              Button(
                width: 140,
                label: 'Capture Photo',
                color: Colors.blue,
                onPressed: () async {
                  final cameras = await availableCameras();
                  final preferedtCamera = cameras[1];
                  Navigator.of(context)
                      .push(MaterialPageRoute(
                          builder: (context) =>
                              TakePictureScreen(camera: preferedtCamera)))
                      .then((value) {
                    if (value != null) {
                      setState(() {
                        image = File(value);
                      });
                    }
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget shiftCard(ShiftModel? shift) {
    return shift != null
        ? Card(
            color: Colors.white,
            child: ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current Shift:',
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  // Divider(),
                  Text(
                    shift.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Start Time',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          Text(
                            Formatter.formatTimeOfDay(
                                shift.startTime!, context),
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12),
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
                          const Text(
                            'End Time',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          Text(
                            Formatter.formatTimeOfDay(shift.endTime!, context),
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12),
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
                          const Text(
                            'Duration Hours',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          Text(
                            shift.durationHours.toString(),
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        : Text(
            'No shift available.',
            style: TextStyle(color: Colors.red[900], fontSize: 20),
          );
  }

  Widget terminalCard(SiteModel site) {
    return Card(
      color: Colors.white,
      child: ListTile(
        isThreeLine: true,
        contentPadding: const EdgeInsets.all(10),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "'Hello! You've entered the Terminal:",
              style: TextStyle(
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              site.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
        subtitle: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(
              thickness: 1,
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Latitude',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      '${site.latitude}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
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
                    const Text(
                      'Longitude',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      '${site.longitude}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
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
