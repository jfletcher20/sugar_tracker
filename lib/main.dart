// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sugar_tracker/data/preferences.dart';
import 'package:sugar_tracker/data/riverpod.dart/u_provider_food.dart';
import 'package:sugar_tracker/data/riverpod.dart/u_provider_food_category.dart';
import 'package:sugar_tracker/data/riverpod.dart/u_provider_insulin.dart';
import 'package:sugar_tracker/data/riverpod.dart/u_provider_meal.dart';
import 'package:sugar_tracker/data/riverpod.dart/u_provider_sugar.dart';
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
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeManager.lightTheme,
      darkTheme: ThemeManager.darkTheme,
      themeMode: ThemeMode.system,
      home: Consumer(
        builder: (context, ref, child) {
          Future loadDB() async {
            await ref.read(SugarManager.provider.notifier).load();
            await ref.read(InsulinManager.provider.notifier).load();
            await ref.read(FoodCategoryManager.provider.notifier).load();
            await ref.read(FoodManager.provider.notifier).load();
            await ref.read(MealManager.provider.notifier).load();
          }

          return FutureBuilder(
            future: loadDB(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done)
                return const HomePage();
              else
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
            },
          );
        },
      ),
    );
  }
}
