import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData theme() {
  return ThemeData(
    useMaterial3: true,
    colorSchemeSeed: Colors.green[900],
    scaffoldBackgroundColor: Colors.green[50],
    appBarTheme: AppBarTheme(
      color: Colors.green[900]!,
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 20,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      elevation: 2,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Colors.green[900],
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: Colors.green[900],
      textTheme: ButtonTextTheme.primary,
    ),
    textTheme: GoogleFonts.nunitoTextTheme(),
  );
}
