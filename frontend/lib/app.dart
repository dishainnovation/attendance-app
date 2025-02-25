import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'Services/RouteGenerator.dart';
import 'Services/navigationService.dart';
import 'Utils/themeData.dart';
import 'splashScreen.dart';

class App extends StatelessWidget {
  final bool isLoggedIn;
  const App({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MaterialApp(
          navigatorKey: NavigationService.navigatorKey,
          initialRoute: '/',
          onGenerateRoute: RouteGenerator.generateRoute,
          debugShowCheckedModeBanner: false,
          title: 'Attendance Tracker',
          theme: theme(),
          home: child,
        );
      },
      child: Splashscreen(isLoggedIn: isLoggedIn),
    );
  }
}
