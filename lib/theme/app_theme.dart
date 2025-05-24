import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.blue,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.blue,
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: Colors.white,
    ),
    iconTheme: const IconThemeData(color: Colors.blue),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.black),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.teal,
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.teal,
      foregroundColor: Colors.white,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.teal,
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: Color(0xFF1E1E1E),
    ),
    iconTheme: const IconThemeData(color: Colors.tealAccent),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.white70),
    ),
  );
}
