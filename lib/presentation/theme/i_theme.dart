import 'package:flutter/material.dart';

class ThemeManager {
  static bool isDark = false;
  static void toggleTheme() {
    isDark = !isDark;
  }

  static ThemeData darkTheme = ThemeData.dark().copyWith(
    appBarTheme: const AppBarTheme(
      backgroundColor: Color.fromARGB(255, 183, 0, 0),
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(
        color: Colors.white,
        fontSize: 20,
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      labelStyle: TextStyle(color: Colors.white),
      hintStyle: TextStyle(color: Colors.red),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: Colors.red, width: 2),
      ),
    ),
    scaffoldBackgroundColor: const Color.fromARGB(255, 70, 0, 0),
    colorScheme: const ColorScheme.dark(
      primary: Colors.black,
      secondary: Colors.black,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.redAccent,
        textStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        minimumSize: const Size(300, 32),
        padding: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    ),
  );
  static ThemeData lightTheme = ThemeData.light();
}
