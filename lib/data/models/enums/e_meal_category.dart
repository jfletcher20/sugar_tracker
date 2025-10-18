import 'package:sugar_tracker/data/constants.dart';
import 'package:flutter/material.dart';

enum MealCategory {
  breakfast,
  lunch,
  dinner,
  snack,
  other;

  IconData get icon {
    return switch (this) {
      MealCategory.breakfast => MealCategoryData.mealCategory.breakfast.icon,
      MealCategory.lunch => MealCategoryData.mealCategory.lunch.icon,
      MealCategory.dinner => MealCategoryData.mealCategory.dinner.icon,
      MealCategory.snack => MealCategoryData.mealCategory.snack.icon,
      MealCategory.other => MealCategoryData.mealCategory.other.icon,
    };
  }

  Color get color {
    return switch (this) {
      MealCategory.breakfast => MealCategoryData.mealCategory.breakfast.color,
      MealCategory.lunch => MealCategoryData.mealCategory.lunch.color,
      MealCategory.dinner => MealCategoryData.mealCategory.dinner.color,
      MealCategory.snack => MealCategoryData.mealCategory.snack.color,
      MealCategory.other => MealCategoryData.mealCategory.other.color,
    };
  }
}
