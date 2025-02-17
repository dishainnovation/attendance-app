// ignore: file_names
import 'package:flutter/material.dart';
import 'package:frontend/Models/EmployeeModel.dart';
import 'package:provider/provider.dart';

import 'Services/userNotifier.dart';
import 'Utility.dart';

class Splashscreen extends StatefulWidget {
  final bool isLoggedIn;
  const Splashscreen({super.key, required this.isLoggedIn});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1), () {
      startApp();
    });
  }

  startApp() async {
    if (widget.isLoggedIn == false) {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      EmployeeModel? user = await getUserInfo();
      context.read<User>().user = EmployeeModel.fromJson(user!.toJson());

      // if (user == null) {
      //   Navigator.pushReplacementNamed(context, '/login');
      // } else {
      if (user.designation!.user_type == 'SUPER_ADMIN') {
        Navigator.pushReplacementNamed(context, '/super-admin-home');
      } else if (user.designation!.user_type == 'ADMIN') {
        Navigator.pushReplacementNamed(context, '/admin-home');
      } else if (user.designation!.user_type == 'USER') {
        Navigator.pushReplacementNamed(context, '/user-home');
      }
      // }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/splash.png'))),
          child: Image.asset('assets/images/splash.png'),
        ),
      ),
    );
  }
}
