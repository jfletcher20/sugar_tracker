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
    scaffoldBackgroundColor: const Color.fromARGB(255, 70, 0, 0),
    colorScheme: const ColorScheme.dark(
      primary: Colors.black,
      secondary: Colors.black,
    ),
    // dataTableTheme: DataTableThemeData(
    //   dataRowColor: const MaterialStatePropertyAll(Color.fromARGB(255, 255, 192, 181)),
    //   dataTextStyle: const TextStyle(color: Colors.black, fontSize: 18),
    //   headingRowColor: const MaterialStatePropertyAll(Color.fromARGB(207, 162, 0, 0)),
    //   decoration: BoxDecoration(
    //     color: const Color.fromARGB(255, 255, 38, 0),
    //     border: Border.all(
    //       color: const Color.fromARGB(185, 177, 27, 0),
    //     ),
    //   ),
    //   columnSpacing: 10,
    //   dividerThickness: 2,
    // ),
  );
  static ThemeData lightTheme = ThemeData.light();
}
