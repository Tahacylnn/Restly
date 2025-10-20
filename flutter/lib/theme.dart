import 'package:flutter/material.dart';

ThemeData buildTheme() {
  final primary = Color(0xFFc53030);
  return ThemeData(
    primaryColor: primary,
    colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.red).copyWith(secondary: primary),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: primary,
      elevation: 0,
      centerTitle: true
    ),
    textTheme: TextTheme(
      headline6: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      bodyText2: TextStyle(fontSize: 16)
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(backgroundColor: primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: EdgeInsets.symmetric(vertical:14,horizontal:24))
    ),
  );
}
