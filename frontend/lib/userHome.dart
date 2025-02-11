import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'Models/EmployeeModel.dart';
import 'Utility.dart';
import 'checkIn.dart';
import 'register.dart';
import 'widgets/Button.dart';
import 'widgets/ScaffoldPage.dart';

class UserHome extends StatefulWidget {
  const UserHome({super.key});

  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  EmployeeModel? user;
  String locationName = '';
  String time = '';
  Timer? _timer;

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        setState(() {
          time = DateFormat("hh:mm:ss a").format(DateTime.now());
        });
      },
    );
  }

  getLocation() async {
    await getCurrentLocation().then((location) async {
      await getLocationName(location).then((value) => setState(() {
            locationName = value;
          }));
    });
  }

  getUserData() async {
    await getUserInfo().then((value) => setState(() {
          user = value;
        }));
  }

  @override
  void initState() {
    super.initState();
    startTimer();
    getLocation();
    getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      title: user != null ? user!.name : 'Home',
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(children: [
          locationName == ''
              ? Text('Getting current location...')
              : Text('Location: $locationName'),
          SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RegisterPage(
                                isProfile: true,
                                employee: user!,
                              )));
                },
                child: Card(
                  color: Colors.green,
                  child: SizedBox(
                    height: 100,
                    width: 100,
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Card(
                color: Colors.blue,
                child: SizedBox(
                  height: 100,
                  width: 100,
                  child: Icon(
                    Icons.calendar_month_outlined,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),
              Card(
                color: Colors.deepOrange,
                child: SizedBox(
                  height: 100,
                  width: 100,
                  child: Icon(
                    Icons.calendar_today_outlined,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 40),
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
          SizedBox(height: 40),
          Button(
              label: 'Check-In',
              color: Colors.green,
              width: 200,
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => CheckIn()));
              }),
        ]),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
