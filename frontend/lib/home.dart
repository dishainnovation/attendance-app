import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/widgets/Button.dart';
import 'package:frontend/widgets/ScaffoldPage.dart';
import 'package:intl/intl.dart';
import 'Utility.dart';
import 'Models/EmployeeModel.dart';
import 'checkIn.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Employeemodel? user;
  String locationName = '';
  String time = '';
  Timer? _timer;
  int _start = 10;
  //DateFormat("HH:mm a").format(DateTime.now())

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
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
          Text('Location: $locationName'),
          SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Card(
                color: Colors.green,
                child: Container(
                  height: 100,
                  width: 100,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),
              Card(
                color: Colors.blue,
                child: Container(
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
                child: Container(
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
            color: Colors.purpleAccent,
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
                        color: Colors.white),
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
