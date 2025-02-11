import 'package:flutter/material.dart';
import 'package:frontend/Models/EmployeeModel.dart';
import 'package:frontend/adminHome.dart';
import 'package:frontend/home.dart';
import 'package:frontend/userHome.dart';

import 'Utility.dart';

class Screen extends StatefulWidget {
  const Screen({super.key});

  @override
  State<Screen> createState() => _ScreenState();
}

class _ScreenState extends State<Screen> {
  EmployeeModel? user;

  @override
  void initState() {
    super.initState();
    startApp();
  }

  startApp() async {
    EmployeeModel? user = await getUserInfo();
    if (user != null) {
      setState(() {
        this.user = user;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    } else {
      if (user!.designationName == 'Super Admin') {
        return AdminHome();
      } else if (user!.designationName == 'Admin') {
        return HomePage();
      }
      return UserHome();
    }
  }
}
