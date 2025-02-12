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
      if (user == null) {
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        context.read<User>().user = EmployeeModel.fromJson(user.toJson());
        Navigator.pushReplacementNamed(context, '/screen');
      }
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
