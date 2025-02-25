import 'package:flutter/material.dart';
import 'package:frontend/Models/EmployeeModel.dart';
import 'package:frontend/adminHome.dart';
import 'package:frontend/home.dart';
import 'package:frontend/userHome.dart';
import 'package:provider/provider.dart';

import 'Services/userNotifier.dart';
import 'Utils/constants.dart';
import 'widgets/SpinKit.dart';

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
    user = context.read<User>().user!;
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(
          body: const Center(
              child: const SpinKit(
        type: spinkitType,
      )));
    } else {
      if (user!.designation!.user_type == 'SUPER_ADMIN') {
        return const AdminHome();
      } else if (user!.designation!.user_type == 'ADMIN') {
        return const HomePage();
      } else if (user!.designation!.user_type == 'SUPERVISOR' ||
          user!.designation!.user_type == 'OPERATOR') {
        return const UserHome();
      }
      return const UserHome();
    }
  }
}
