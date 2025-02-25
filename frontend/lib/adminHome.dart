import 'package:flutter/material.dart';
import 'package:frontend/Models/AttendanceModel.dart';
import 'package:frontend/Models/EmployeeModel.dart';
import 'package:frontend/Models/ErrorObject.dart';
import 'package:frontend/Services/attendanceService.dart';
import 'package:frontend/Services/userNotifier.dart';
import 'package:frontend/widgets/SpinKit.dart';
import 'package:provider/provider.dart';
import 'Services/navigationService.dart';
import 'package:frontend/widgets/ScaffoldPage.dart';
import 'package:frontend/widgets/tile.dart';

import 'Utils/formatter.dart';
import 'widgets/Button.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  ErrorObject error = ErrorObject(title: '', message: '');
  List<Widget> functionTiles = [];
  List<Widget> reportsTiles = [];
  EmployeeModel? employee;
  AttendanceModel? attendance;
  bool isLoading = false;
  bool fetchingAttendance = false;

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

    setState(() {
      attendance = tempAttendance;
    });
    return tempAttendance;
  }

  @override
  void initState() {
    super.initState();
    employee = context.read<User>().user!;
    getAttendance();
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
          const Divider(
            height: 40,
          ),
          Flexible(
            flex: 4,
            fit: FlexFit.tight,
            child: functionGrid(),
          ),
          const Divider(),
          const Text(
            'Reports',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
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
              child: const Text(
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
            leading: const Icon(
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
        RichText(
          text: TextSpan(
              text: 'Welcome ',
              style: Theme.of(context).textTheme.headlineSmall,
              children: [
                TextSpan(
                  text: employee!.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold),
                ),
              ]),
        ),
        const SizedBox(
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
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  employee!.designation!.name.toString(),
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        // color: Theme.of(context).,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            fetchingAttendance
                ? const Padding(
                    padding: EdgeInsets.only(right: 20.0),
                    child: SpinKit(
                      type: SpinType.Circle,
                      size: 40,
                    ),
                  )
                : Button(
                    label:
                        attendance != null && attendance!.checkOutTime == null
                            ? 'Check Out'
                            : 'Check In',
                    color:
                        attendance != null && attendance!.checkOutTime == null
                            ? Colors.red
                            : Theme.of(context).primaryColor,
                    onPressed: () {
                      NavigationService.navigateTo('/check-in');
                    },
                  ),
          ],
        ),
      ],
    );
  }

  Widget functionGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
        icon: const Icon(
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
        icon: const Icon(
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
        icon: const Icon(
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
        icon: const Icon(
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
          title: const Text('Attendance'),
          subtitle: const Text(
            'Monthly Report',
            style: TextStyle(color: Colors.grey),
          ),
          leading: Icon(
            Icons.calendar_month,
            size: 40,
            color: Colors.cyan[300],
          ),
          trailing: const Icon(
            Icons.arrow_circle_right,
            color: Colors.grey,
          ),
          onTap: () {
            NavigationService.navigateTo('/attendace-report');
          },
        ),
      ),
      const Card(
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
}
