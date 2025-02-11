import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend/Models/SiteModel.dart';
import 'package:frontend/widgets/ScaffoldPage.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'Models/EmployeeModel.dart';
import 'Models/ShiftModel.dart';
import 'Services/shiftService.dart';
import 'Services/terminalService.dart';
import 'Services/userNotifier.dart';
import 'Utility.dart';
import 'widgets/Button.dart';

class CheckIn extends StatefulWidget {
  const CheckIn({super.key});

  @override
  State<CheckIn> createState() => _CheckInState();
}

class _CheckInState extends State<CheckIn> {
  String time = '';
  Timer? _timer;
  String locationName = '';
  ShiftModel? shift;
  double? latitude;
  double? longitude;
  File? image;
  bool inTerminal = true;
  bool siteLoaded = false;

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        setState(() {
          time = DateFormat('hh:mm:ss a').format(DateTime.now());
        });
      },
    );
  }

  getLocation() async {
    await getCurrentLocation().then((location) async {
      setState(() {
        latitude = location.latitude;
        longitude = location.longitude;
      });
      await getLocationName(location).then((value) => setState(() {
            locationName = value;
          }));
    });
  }

  @override
  void initState() {
    super.initState();
    startTimer();
    getLocation();
  }

  @override
  Widget build(BuildContext context) {
    EmployeeModel user = context.read<User>().user!;
    return ScaffoldPage(
      title: user.name,
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(children: [
          Card(
            color: Colors.green[200],
            child: SizedBox(
              height: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    time,
                    style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[900]),
                  ),
                ],
              ),
            ),
          ),
          latitude != null && longitude != null
              ? FutureBuilder<SiteModel?>(
                  future: getSiteByLocation(user.port, latitude!, longitude!),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      SiteModel site = snapshot.data!;
                      if (site.id == 0) {
                        inTerminal = false;
                        siteLoaded = false;
                        return Container();
                      }
                      siteLoaded = true;
                      return terminalCard(site);
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                )
              : Center(child: CircularProgressIndicator()),
          ...widgets(user),
        ]),
      ),
    );
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
              'Check-in requires you to be within the terminal range.',
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
            FutureBuilder<ShiftModel?>(
              future: getCurrentShift(user.port, TimeOfDay.now()),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  shift = snapshot.data!;
                  return Column(children: [
                    shiftCard(shift!),
                  ]);
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
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
            SizedBox(height: 20),
            image != null
                ? Container()
                : Text(
                    'Capture photo to check-in',
                    style: TextStyle(
                      color: Colors.red[900],
                    ),
                  ),
            Button(
                label: 'Check-In',
                color: Colors.green,
                width: 200,
                onPressed: image == null
                    ? null
                    : () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => CheckIn()));
                      }),
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

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
