import 'package:flutter/material.dart';
import 'package:frontend/login.dart';
import 'package:frontend/splashScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Services/RouteGenerator.dart';
import 'Services/navigationService.dart';
import 'adminHome.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final String? data = prefs.getString('user_data');

  final bool isLoggedIn = data != null;
  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: NavigationService.navigatorKey,
      initialRoute: '/',
      onGenerateRoute: RouteGenerator.generateRoute,
      debugShowCheckedModeBanner: false,
      title: 'Attendance Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Splashscreen(isLoggedIn: isLoggedIn),
    );
  }
}
