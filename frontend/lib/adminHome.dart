import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/Models/AttendanceModel.dart';
import 'package:frontend/Models/EmployeeModel.dart';
import 'package:frontend/Models/ErrorObject.dart';
import 'package:frontend/Services/attendanceService.dart';
import 'package:frontend/Services/userNotifier.dart';
import 'package:frontend/Services/navigationService.dart';
import 'package:frontend/Utils/formatter.dart';
import 'package:frontend/widgets/SpinKit.dart';
import 'package:frontend/widgets/ScaffoldPage.dart';
import 'package:frontend/widgets/Tile.dart';
import 'package:frontend/widgets/Button.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> with TickerProviderStateMixin {
  ErrorObject error = ErrorObject(title: '', message: '');
  List<Widget> functionTiles = [];
  List<Widget> reportsTiles = [];
  EmployeeModel? employee;
  AttendanceModel? attendance;
  bool fetchingAttendance = false;

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    employee = context.read<User>().user!;

    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _getAttendance();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _getAttendance() async {
    try {
      setState(() {
        fetchingAttendance = true;
      });

      EmployeeModel user = context.read<User>().user!;
      List<AttendanceModel> attendances = await getEmployeeAttendance(
          user.id, Formatter.formatDate(DateTime.now()));

      if (attendances.isNotEmpty) {
        setState(() {
          attendance =
              attendances.firstWhere((att) => att.checkOutTime == null);
        });
      }

      setState(() {
        fetchingAttendance = false;
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    _setTiles();
    return ScaffoldPage(
      error: error,
      title: 'Attendance Tracker',
      showHeaderClip: true,
      drawer: _drawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (employee != null) _employeeInfo(context),
          const SizedBox(height: 40),
          Flexible(flex: 4, fit: FlexFit.tight, child: _functionGrid()),
          const Divider(),
          const Text(
            'Reports',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Flexible(flex: 2, child: _reportsGrid()),
        ],
      ),
    );
  }

  Drawer? _drawer() {
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
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
          ListTile(
            title: const Text('Designations'),
            leading: const Icon(Icons.approval),
            onTap: () {
              Navigator.pop(context);
              NavigationService.navigateTo('/designations-list');
            },
          ),
        ],
      ),
    );
  }

  Widget _employeeInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: 'Welcome ',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                ),
            children: [
              TextSpan(
                text: employee!.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Designation:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                      ),
                ),
                Text(
                  employee!.designation!.name.toString(),
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Colors.white,
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
                    borderRadius: 40,
                    label:
                        attendance != null && attendance!.checkOutTime == null
                            ? 'Check Out'
                            : 'Check In',
                    color:
                        attendance != null && attendance!.checkOutTime == null
                            ? Colors.red
                            : Colors.greenAccent,
                    onPressed: () {
                      NavigationService.navigateTo('/check-in');
                    },
                  ),
          ],
        ),
      ],
    );
  }

  Widget _functionGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
      ),
      itemCount: functionTiles.length,
      itemBuilder: (context, index) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: functionTiles[index],
          ),
        );
      },
    );
  }

  Widget _reportsGrid() {
    return ListView.builder(
      itemCount: reportsTiles.length,
      itemBuilder: (context, index) {
        return reportsTiles[index];
      },
    );
  }

  void _setTiles() {
    functionTiles = [
      Tile(
        text: 'Employees',
        color: Colors.teal,
        icon: const Icon(Icons.groups, size: 50, color: Colors.white),
        size: 100,
        onTap: () => NavigationService.navigateTo('/employees-list'),
      ),
      Tile(
        text: 'Ports',
        color: Colors.lightBlue,
        icon: const Icon(Icons.directions_boat, size: 50, color: Colors.white),
        size: 100,
        onTap: () => NavigationService.navigateTo('/ports-list'),
      ),
      Tile(
        text: 'Terminals',
        color: Colors.deepOrange,
        icon: const Icon(Icons.account_tree_outlined,
            size: 50, color: Colors.white),
        size: 100,
        onTap: () => NavigationService.navigateTo('/terminals-list'),
      ),
      Tile(
        text: 'Shifts',
        color: Colors.purple,
        icon: const Icon(Icons.pending_actions, size: 50, color: Colors.white),
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
          subtitle: const Text('Monthly Report',
              style: TextStyle(color: Colors.grey)),
          leading:
              Icon(Icons.calendar_month, size: 40, color: Colors.cyan[300]),
          trailing: const Icon(Icons.arrow_circle_right, color: Colors.grey),
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
          subtitle:
              Text('Monthly Report', style: TextStyle(color: Colors.grey)),
          leading:
              Icon(Icons.calendar_today, size: 40, color: Colors.pinkAccent),
          trailing: Icon(Icons.arrow_circle_right, color: Colors.grey),
        ),
      ),
    ];
  }
}
