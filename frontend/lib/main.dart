import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frontend/splashScreen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'Services/RouteGenerator.dart';
import 'Services/navigationService.dart';
import 'Services/userNotifier.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final String? data = prefs.getString('user_data');

  final bool isLoggedIn = data != null;
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(ChangeNotifierProvider(
        create: (context) => User(), child: MyApp(isLoggedIn: isLoggedIn)));
  });
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

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
          theme: _buildTheme(Brightness.light),
          home: child,
        );
      },
      child: Splashscreen(isLoggedIn: isLoggedIn),
    );
  }

  ThemeData _buildTheme(brightness) {
    var baseTheme = ThemeData(brightness: brightness);

    return baseTheme.copyWith(
      textTheme: GoogleFonts.nunitoTextTheme(baseTheme.textTheme),
    );
  }
}
