// ignore_for_file: curly_braces_in_flow_control_structures
import 'package:sugar_tracker/data/riverpod.dart/u_provider_food.dart';
import 'package:sugar_tracker/data/riverpod.dart/u_provider_food_category.dart';
import 'package:sugar_tracker/data/riverpod.dart/u_provider_insulin.dart';
import 'package:sugar_tracker/data/riverpod.dart/u_provider_meal.dart';
import 'package:sugar_tracker/data/riverpod.dart/u_provider_sugar.dart';
import 'package:sugar_tracker/presentation/theme/i_theme.dart';
import 'package:sugar_tracker/presentation/s_homepage.dart';
import 'package:sugar_tracker/data/preferences.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import 'data/api/u_db.dart';

import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DB.open();
  await Profile.futureWeight;
  await Profile.futureDividers;
  await Profile.futureDateAsDayOfWeek;
  runApp(const ProviderScope(child: MainApp()));
}

late final FirebaseApp firebaseAppInstance;

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
      darkTheme: ThemeManager.darkTheme,
      themeMode: ThemeMode.dark,
      home: Consumer(
        builder: (context, ref, child) {
          Future loadDB() async {
            await ref.read(SugarManager.provider.notifier).load();
            await ref.read(InsulinManager.provider.notifier).load();
            await ref.read(FoodCategoryManager.provider.notifier).load();
            await ref.read(FoodManager.provider.notifier).load();
            await ref.read(MealManager.provider.notifier).load(ref: ref);
            firebaseAppInstance = await Firebase.initializeApp();
          }

          return FutureBuilder(
            future: loadDB(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) return const HomePage();
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
