import 'package:flutter/material.dart';

abstract class IconConstants {
  static const IconData sugar = Icons.query_stats;
  static const IconData insulin = Icons.edit_outlined;
  static const IconData meal = Icons.fastfood;
  static const IconData food = Icons.food_bank;
  static const IconData settings = Icons.settings;
}

extension InsulinCategoryData on IconConstants {
  static const ({
    ({IconData icon, Color color}) bolus,
    ({IconData icon, Color color}) basal,
  }) insulinCategory = (
    bolus: (icon: Icons.fast_forward, color: Colors.deepOrange),
    basal: (icon: Icons.slow_motion_video, color: Colors.lightGreen),
  );
}

extension MealCategoryData on IconConstants {
  static const ({
    ({IconData icon, Color color}) breakfast,
    ({IconData icon, Color color}) lunch,
    ({IconData icon, Color color}) dinner,
    ({IconData icon, Color color}) snack,
    ({IconData icon, Color color}) other,
  }) mealCategory = (
    breakfast: (icon: Icons.free_breakfast_rounded, color: Colors.lightBlue),
    lunch: (icon: Icons.lunch_dining_rounded, color: Colors.green),
    dinner: (icon: Icons.dinner_dining_rounded, color: Colors.orange),
    snack: (icon: Icons.fastfood_rounded, color: Color.fromARGB(255, 224, 100, 251)),
    other: (icon: Icons.cake_rounded, color: Colors.yellow),
  );
}
