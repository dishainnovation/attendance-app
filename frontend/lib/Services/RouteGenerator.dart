import 'package:flutter/material.dart';
import 'package:frontend/adminHome.dart';
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
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => HomePage());
      case '/login':
        return MaterialPageRoute(builder: (_) => Login());
      case '/screen':
        return MaterialPageRoute(builder: (_) => Screen());
      case '/super-admin-home':
        return MaterialPageRoute(builder: (_) => AdminHome());
      case '/admin-home':
        return MaterialPageRoute(builder: (_) => HomePage());
      case '/user-home':
        return MaterialPageRoute(builder: (_) => UserHome());
      case '/port':
        return MaterialPageRoute(builder: (_) => Port());
      case '/ports-list':
        return MaterialPageRoute(builder: (_) => Portslist());
      case '/terminal':
        return MaterialPageRoute(builder: (_) => Terminal());
      case '/terminals-list':
        return MaterialPageRoute(builder: (_) => TerminalsList());
      case '/shifts-list':
        return MaterialPageRoute(builder: (_) => ShiftsList());
      case '/shift':
        return MaterialPageRoute(builder: (_) => Shift());
      case '/designations-list':
        return MaterialPageRoute(builder: (_) => DesignationsList());
      case '/designation':
        return MaterialPageRoute(builder: (_) => Designation());
      case '/employees-list':
        return MaterialPageRoute(builder: (_) => EmployeesList());
      case '/employee':
        return MaterialPageRoute(
            builder: (_) => Employee(
                  employeeesList: [],
                ));
      case '/check-in':
        return MaterialPageRoute(builder: (_) => CheckIn());

      default:
        return errorRoute();
    }
  }

  static Route<dynamic> errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Error'),
        ),
        body: Center(
          child: Text('Page not found!'),
        ),
      );
    });
  }
}
