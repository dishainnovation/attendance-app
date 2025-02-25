import 'package:flutter/material.dart';
import 'package:frontend/adminHome.dart';
import 'package:frontend/attendanceReport.dart';
import 'package:frontend/designation.dart';
import 'package:frontend/designationsList.dart';
import 'package:frontend/employeesList.dart';
import 'package:frontend/home.dart';
import 'package:frontend/login.dart';
import 'package:frontend/port.dart';
import 'package:frontend/portsList.dart';
import 'package:frontend/screen.dart';
import 'package:frontend/shift.dart';
import 'package:frontend/terminal.dart';
import 'package:frontend/terminalsList.dart';
import 'package:frontend/userHome.dart';
import '../attendance.dart';
import '../employee.dart';
import '../shiftsList.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final WidgetBuilder builder;
    switch (settings.name) {
      case '/':
        builder = (_) => const HomePage();
        break;
      case '/login':
        builder = (_) => const Login();
        break;
      case '/screen':
        builder = (_) => const Screen();
        break;
      case '/super-admin-home':
        builder = (_) => const AdminHome();
        break;
      case '/admin-home':
        builder = (_) => const HomePage();
        break;
      case '/user-home':
        builder = (_) => const UserHome();
        break;
      case '/port':
        builder = (_) => const Port();
        break;
      case '/ports-list':
        builder = (_) => const Portslist();
        break;
      case '/terminal':
        builder = (_) => const Terminal();
        break;
      case '/terminals-list':
        builder = (_) => const TerminalsList();
        break;
      case '/shifts-list':
        builder = (_) => const ShiftsList();
        break;
      case '/shift':
        builder = (_) => const Shift();
        break;
      case '/designations-list':
        builder = (_) => const DesignationsList();
        break;
      case '/designation':
        builder = (_) => const Designation();
        break;
      case '/employees-list':
        builder = (_) => const EmployeesList();
        break;
      case '/employee':
        builder = (_) => const Employee(employeeesList: []);
        break;
      case '/check-in':
        builder = (_) => const CheckIn();
        break;
      case '/attendace-report':
        builder = (_) => const AttendanceReport();
        break;
      default:
        return _errorRoute();
    }
    return MaterialPageRoute(builder: builder);
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: const Center(
          child: Text('Page not found!'),
        ),
      );
    });
  }
}
