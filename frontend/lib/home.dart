import 'package:flutter/material.dart';
import 'package:frontend/widgets/ScaffoldPage.dart';
import 'package:provider/provider.dart';
import 'Models/AttendanceModel.dart';
import 'Models/ErrorObject.dart';
import 'Services/attendanceService.dart';
import 'Services/navigationService.dart';
import 'Services/userNotifier.dart';
import 'Models/EmployeeModel.dart';
import 'Utility.dart';
import 'widgets/Button.dart';
import 'widgets/tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ErrorObject error = ErrorObject(title: '', message: '');
  double cardSize = 100;
  List<Widget> functionTiles = [];
  List<Widget> reportsTiles = [];
  EmployeeModel? user;
  CurrentAttendance? attendance;
  double? latitude;
  double? longitude;
  String locationName = '';

  getUser() {
    try {
      setState(() {
        user = context.read<User>().user!;
      });
    } catch (e) {
      setState(() {
        error = ErrorObject(title: 'Error', message: e.toString());
      });
    }
  }

  getLocation() async {
    await getCurrentLocation().then((location) async {
      await getCurrentAttendance(user!, location.latitude, location.longitude)
          .then((att) {
        setState(() {
          attendance = att;
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
        error = ErrorObject(title: 'Error', message: err.toString());
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getUser();
    if (user != null) {
      getLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    setTiles(context);
    return ScaffoldPage(
      error: error,
      title: 'Attendance Tracker',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          user == null ? Flexible(flex: 1, child: Container()) : employeeInfo(),
          Divider(),
          SizedBox(height: 10),
          ...homeContent(),
        ],
      ),
    );
  }

  Widget employeeInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome ${user!.name}',
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
                  user!.designation!.name.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            attendance == null
                ? Container()
                : Button(
                    label: attendance!.status == AttendanceStatus.CHECKED_IN
                        ? 'Check Out'
                        : 'Check In',
                    color: Colors.blue,
                    onPressed: () {
                      NavigationService.navigateTo('/check-in');
                    },
                  ),
          ],
        ),
      ],
    );
  }

  List<Widget> homeContent() {
    return [
      functionGrid(),
      Divider(),
      Text('Reports'),
      SizedBox(height: 20),
      reportsGrid(),
    ];
  }

  Widget functionGrid() {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // Number of columns in the functionGrid
        crossAxisSpacing: 10.0, // Space between columns
        mainAxisSpacing: 10.0, // Space between rows
      ),
      itemCount: functionTiles.length,
      itemBuilder: (context, index) {
        return functionTiles[index];
      },
    );
  }

  Widget reportsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // Number of columns in the functionGrid
        crossAxisSpacing: 10.0, // Space between columns
        mainAxisSpacing: 10.0, // Space between rows
      ),
      itemCount: reportsTiles.length,
      itemBuilder: (context, index) {
        return reportsTiles[index];
      },
    );
  }

  setTiles(BuildContext context) {
    functionTiles = [
      Tile(
          text: 'Employees',
          color: Colors.green,
          icon: Icon(
            Icons.groups,
            size: 50,
            color: Colors.white,
          ),
          size: 100,
          onTap: () => NavigationService.navigateTo('/employees-list')),
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
    ];
    reportsTiles = [
      Tile(
        text: 'Attendance',
        color: Colors.lightBlueAccent,
        icon: Icon(
          Icons.calendar_month,
          size: 50,
          color: Colors.white,
        ),
        size: 100,
      ),
    ];
  }
}
