import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';

import '../Utils/dialogs.dart';
import '../widgets/RestartWidget.dart';

class UpdateService {
  static Future<void> checkForUpdate(BuildContext context) async {
    await InAppUpdate.checkForUpdate().then((value) async {
      if (value.updateAvailability == UpdateAvailability.updateAvailable) {
        if (value.updateAvailability == UpdateAvailability.updateAvailable) {
          await Dialogs.showAlertDialog(
            context,
            'Update Available',
            'A new version of the app is available. Please update to the latest version.',
          ).then((result) async {
            if (result) {
              await performUpdate();
              RestartWidget.restartApp(context);
            }
          });
        }
      }
    });
  }

  static Future<void> performUpdate() async {
    await InAppUpdate.performImmediateUpdate();
  }
}
