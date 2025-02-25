import 'package:flutter/material.dart';
import 'package:frontend/widgets/ScaffoldPage.dart';
import 'package:provider/provider.dart';
import 'Models/AttendanceModel.dart';
import 'Models/ErrorObject.dart';
import 'Services/attendanceService.dart';
import 'Services/navigationService.dart';
import 'Services/userNotifier.dart';
import 'Models/EmployeeModel.dart';
import 'Utils/formatter.dart';
import 'widgets/Button.dart';
import 'widgets/tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ErrorObject error = ErrorObject(title: '', message: '');
  List<Widget> functionTiles = [];
  List<Widget> reportsTiles = [];
  EmployeeModel? user;
  AttendanceModel? attendance;

  Future<AttendanceModel?> getAttendance() async {
    AttendanceModel? tempAttendance;
    await getEmployeeAttendance(user!.id, Formatter.formatDate(DateTime.now()))
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
    user = context.read<User>().user!;
    if (user != null) {
      getAttendance();
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
          const Divider(),
          const SizedBox(height: 10),
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
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                const Text(
                  'Designation:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  user!.designation!.name.toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.normal,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            attendance == null
                ? Container()
                : Button(
                    label:
                        attendance != null && attendance!.checkOutTime == null
                            ? 'Check Out'
                            : 'Check In',
                    color:
                        attendance != null && attendance!.checkOutTime == null
                            ? Colors.red
                            : Colors.green[900]!,
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
      const Divider(),
      const Text('Reports'),
      const SizedBox(height: 20),
      reportsGrid(),
    ];
  }

  Widget functionGrid() {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
          icon: const Icon(
            Icons.groups,
            size: 50,
            color: Colors.white,
          ),
          size: 100,
          onTap: () => NavigationService.navigateTo('/employees-list')),
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
    ];
    reportsTiles = [
      const Tile(
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
