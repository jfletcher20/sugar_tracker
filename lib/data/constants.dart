import 'package:flutter/material.dart';

abstract class IconConstants {
  static const ({IconData regular, IconData outlined}) meal = (
    regular: Icons.fastfood,
    outlined: Icons.fastfood_outlined,
  );
  static const ({IconData regular, IconData outlined}) sugar = (
    regular: Icons.water_drop,
    outlined: Icons.water_drop_outlined,
  );
  static const ({IconData regular, IconData outlined}) insulin = (
    regular: Icons.edit_outlined,
    outlined: Icons.edit_outlined,
  );
  static const ({IconData regular, IconData outlined}) food = (
    regular: Icons.food_bank,
    outlined: Icons.food_bank_outlined,
  );
  static const ({IconData regular, IconData outlined}) settings = (
    regular: Icons.settings,
    outlined: Icons.settings_outlined,
  );
  static const ({IconData regular, IconData outlined}) carbs = (
    regular: Icons.cookie,
    outlined: Icons.cookie_outlined,
  );
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
