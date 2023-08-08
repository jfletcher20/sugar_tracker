import 'package:sugar_tracker/data/preferences.dart';
import 'package:sugar_tracker/presentation/theme/i_theme.dart';
import 'package:sugar_tracker/presentation/w_homepage.dart';
import 'data/api/u_db.dart';

import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DB.open();
  await Profile.futureWeight;
  await Profile.futureDividers;
  await Profile.futureDateAsDayOfWeek;
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeManager.lightTheme,
      darkTheme: ThemeManager.darkTheme,
      themeMode: ThemeMode.system,
      home: const Homepage(),
    );
  }
}
