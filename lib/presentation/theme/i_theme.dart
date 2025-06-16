import 'package:flutter/material.dart';

class ThemeManager {
  static bool isDark = false;
  static void toggleTheme() {
    isDark = !isDark;
  }

  static ThemeData darkTheme = ThemeData.dark().copyWith(
    appBarTheme: const AppBarTheme(backgroundColor: Color.fromARGB(255, 163, 0, 0)),
    buttonTheme: ButtonThemeData(
      buttonColor: Colors.redAccent,
      textTheme: ButtonTextTheme.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: Colors.white),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      landscapeLayout: BottomNavigationBarLandscapeLayout.spread,
      backgroundColor: Colors.black,
      selectedItemColor: Color.fromARGB(255, 255, 32, 32),
      unselectedItemColor: Colors.white,
    ),
    timePickerTheme: TimePickerThemeData(
      cancelButtonStyle: const ButtonStyle(
        foregroundColor: WidgetStatePropertyAll<Color>(Colors.grey),
      ),
      confirmButtonStyle: const ButtonStyle(
        foregroundColor: WidgetStatePropertyAll<Color>(Colors.red),
      ),
      dialHandColor: Colors.red.withValues(alpha: 0.5),
      dialTextColor: Colors.white,
      dialTextStyle: const TextStyle(color: Colors.grey),
      dayPeriodTextStyle: const TextStyle(
        backgroundColor: Color.fromARGB(255, 131, 45, 45),
      ),
      hourMinuteTextColor: Colors.white,
    ),
    datePickerTheme: const DatePickerThemeData(
      todayForegroundColor: WidgetStatePropertyAll<Color>(Colors.red),
      dayOverlayColor: WidgetStatePropertyAll<Color>(Colors.red),
      // add white shadow to day text
      dayForegroundColor: WidgetStatePropertyAll<Color>(Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.red,
        textStyle: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        padding: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.white, fontSize: 18),
      titleLarge: TextStyle(color: Colors.white, fontSize: 20),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      labelStyle: TextStyle(color: Colors.white),
      hintStyle: TextStyle(color: Colors.red),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: Colors.red, width: 2),
      ),
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: Colors.redAccent,
      selectionColor: Colors.redAccent,
      selectionHandleColor: Colors.redAccent,
    ),
    scaffoldBackgroundColor: const Color.fromARGB(255, 70, 0, 0),
    colorScheme: const ColorScheme.dark(primary: Colors.black, secondary: Colors.black),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    ),
  );
  static ThemeData lightTheme = ThemeData.light();
}
