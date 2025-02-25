import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Formatter {
  static String formatTimeOfDay(TimeOfDay timeOfDay, BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    return localizations.formatTimeOfDay(timeOfDay,
        alwaysUse24HourFormat: false);
  }

  static TimeOfDay stringToTimeOfDay(String time) {
    final format = DateFormat.Hms();
    final dateTime = format.parse(time);
    return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
  }

  static String formatDate(DateTime date) {
    return DateFormat("yyyy-MM-dd").format(date);
  }

  static String displayDate(DateTime date) {
    return DateFormat("dd-MM-yyyy").format(date);
  }

  static String displayTime(DateTime date) {
    return DateFormat("hh:mm a").format(date);
  }
}
