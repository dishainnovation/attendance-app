import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:frontend/Models/AttendanceModel.dart';
import 'package:frontend/Models/EmployeeModel.dart';
import 'package:frontend/Models/ErrorObject.dart';
import 'package:frontend/Services/attendanceService.dart';
import 'package:frontend/Services/userNotifier.dart';
import 'package:frontend/widgets/SpinKit.dart';
import 'package:provider/provider.dart';
import 'Services/employeeService.dart';
import 'Services/navigationService.dart';
import 'package:frontend/widgets/ScaffoldPage.dart';
import 'package:frontend/widgets/tile.dart';

import 'Utility.dart';
import 'widgets/Button.dart';
import 'widgets/TakePicture.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  ErrorObject error = ErrorObject(title: '', message: '');
  double cardSize = 100;
  List<Widget> functionTiles = [];
  List<Widget> reportsTiles = [];
  EmployeeModel? employee;
  CurrentAttendance? attendance;
  double? latitude;
  double? longitude;
  String locationName = '';
  bool isProfileCompleted = false;
  bool isLoading = false;
  bool fetchingAttendance = false;

  getUser() {
    try {
      setState(() {
        employee = context.read<User>().user!;
      });
    } catch (e) {
      setState(() {
        error = ErrorObject(title: 'Error', message: e.toString());
      });
    }
  }

  getLocation() async {
    setState(() {
      fetchingAttendance = true;
    });
    await getCurrentLocation().then((location) async {
      await getCurrentAttendance(
              employee!, location.latitude, location.longitude)
          .then((att) {
        setState(() {
          attendance = att;
          fetchingAttendance = false;
        });
      });
      setState(() {
        latitude = location.latitude;
        longitude = location.longitude;
      });
      await getLocationName(location).then((value) => setState(() {
            locationName = value;
          }));
    }).catchError((err) {
      setState(() {
        fetchingAttendance = false;
      });
      throw Exception(err);
    });
  }

  checkProfile() {
    if (employee!.profileImage == null) {
      setState(() {
        isProfileCompleted = false;
      });
    } else {
      setState(() {
        isProfileCompleted = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getUser();
    getLocation();
    checkProfile();
  }

  @override
  Widget build(BuildContext context) {
    setTiles();
    return ScaffoldPage(
      error: error,
      title: 'Attendance Tracker',
      drawer: drawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          employee == null ? Container() : employeeInfo(context),
          Divider(height: 20),
          Flexible(
            flex: 3,
            fit: FlexFit.tight,
            child: functionGrid(),
          ),
          Divider(),
          Text('Reports'),
          SizedBox(height: 20),
          Flexible(
            flex: 2,
            child: reportsGrid(),
          ),
        ],
      ),
    );
  }

  Drawer? drawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 80,
            child: DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green[900]!, Colors.green],
                ),
              ),
              child: Text(
                'Attendance Tracker',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          ListTile(
            title: const Text('Designations'),
            leading: Icon(
              Icons.approval,
            ),
            onTap: () {
              Navigator.pop(context);
              NavigationService.navigateTo('/designations-list');
            },
          ),
        ],
      ),
    );
  }

  Widget employeeInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome ${employee!.name}',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(
          height: 5,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Designation:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  employee!.designation!.name.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            fetchingAttendance
                ? Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: SpinKit(
                      type: SpinType.Circle,
                      size: 40,
                    ),
                  )
                : attendance != null
                    ? Button(
                        label: attendance!.status == AttendanceStatus.CHECKED_IN
                            ? 'Check Out'
                            : 'Check In',
                        color: Colors.blue,
                        onPressed: () {
                          NavigationService.navigateTo('/check-in');
                        },
                      )
                    : Container(),
          ],
        ),
      ],
    );
  }

  Widget functionGrid() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
      ),
      itemCount: functionTiles.length,
      itemBuilder: (context, index) {
        return functionTiles[index];
      },
    );
  }

  Widget reportsGrid() {
    return ListView.builder(
      itemCount: reportsTiles.length,
      itemBuilder: (context, index) {
        return reportsTiles[index];
      },
    );
  }

  setTiles() {
    functionTiles = [
      Tile(
        text: 'Employees',
        color: Colors.teal,
        icon: Icon(
          Icons.groups,
          size: 50,
          color: Colors.white,
        ),
        size: 100,
        onTap: () => NavigationService.navigateTo('/employees-list'),
      ),
      Tile(
        text: 'Ports',
        color: Colors.lightBlue,
        icon: Icon(
          Icons.directions_boat,
          size: 50,
          color: Colors.white,
        ),
        size: 100,
        onTap: () => NavigationService.navigateTo('/ports-list'),
      ),
      Tile(
        text: 'Terminals',
        color: Colors.deepOrange,
        icon: Icon(
          Icons.account_tree_outlined,
          size: 50,
          color: Colors.white,
        ),
        size: 100,
        onTap: () => NavigationService.navigateTo('/terminals-list'),
      ),
      Tile(
        text: 'Shifts',
        color: Colors.purple,
        icon: Icon(
          Icons.pending_actions,
          size: 50,
          color: Colors.white,
        ),
        size: 100,
        onTap: () => NavigationService.navigateTo('/shifts-list'),
      ),
    ];
    reportsTiles = [
      Card(
        elevation: 0,
        color: Colors.white,
        child: ListTile(
          title: Text('Attendance'),
          subtitle: Text(
            'Monthly Report',
            style: TextStyle(color: Colors.grey),
          ),
          leading: Icon(
            Icons.calendar_month,
            size: 40,
            color: Colors.cyan[300],
          ),
          trailing: Icon(
            Icons.arrow_circle_right,
            color: Colors.grey,
          ),
          onTap: () {
            NavigationService.navigateTo('/attendace-report');
          },
        ),
      ),
      Card(
        elevation: 0,
        color: Colors.white,
        child: ListTile(
          title: Text('Overtime'),
          subtitle: Text(
            'Monthly Report',
            style: TextStyle(color: Colors.grey),
          ),
          leading: Icon(
            Icons.calendar_today,
            size: 40,
            color: Colors.pinkAccent,
          ),
          trailing: Icon(
            Icons.arrow_circle_right,
            color: Colors.grey,
          ),
        ),
      ),
    ];
  }

  Widget completeProfile(BuildContext context) {
    return isLoading
        ? SpinKit(
            type: SpinType.PouringHourGlassRefined,
            size: 40,
          )
        : SizedBox(
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
                        employee!.profileImage = value.toString();
                        employee!.employeePhoto = File(value.toString());
                        await updateEmployee(employee!.id, employee!,
                                employee!.employeePhoto!)
                            .then((value) async {
                          context.read<User>().user =
                              EmployeeModel.fromJson(employee!.toJson());
                          storeUserInfo(employee!);
                          await getLocation();
                          setState(() {
                            employee = context.read<User>().user!;
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
