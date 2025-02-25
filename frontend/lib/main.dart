import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/Models/EmployeeModel.dart';
import 'package:frontend/Utils/userInfo.dart';
import 'package:frontend/app.dart';
import 'package:frontend/widgets/errorFallback.dart';
import 'package:provider/provider.dart';
import 'Services/attendanceService.dart';
import 'Services/userNotifier.dart';
import 'package:workmanager/workmanager.dart';

import 'Utils/themeData.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);

  final EmployeeModel? data = await UserInfo.getUserInfo();
  final bool isLoggedIn = data != null;

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(
      ChangeNotifierProvider(
        create: (context) => User(),
        child: App(isLoggedIn: isLoggedIn),
      ),
    );
  });
}

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == 'autoCheckOut') {
      await autoCheckout();
    }

    return Future.value(true);
  });
}
