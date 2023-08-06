/* 
      String mealTable = "CREATE TABLE meal("
          "id INTEGER PRIMARY KEY AUTOINCREMENT,"
          "sugar_id INTEGER,"
          "insulin REAL,"
          "food_ids TEXT,"
          ")"; */

import 'package:sugar_tracker/data/models/m_food.dart';
import 'package:sugar_tracker/data/models/m_insulin.dart';
import 'package:sugar_tracker/data/models/m_sugar.dart';

import 'package:flutter/material.dart';

enum MealCategory { breakfast, lunch, dinner, snack, other }

IconData mealCategoryIcon(MealCategory category) {
  return {
    MealCategory.breakfast: Icons.free_breakfast_rounded,
    MealCategory.lunch: Icons.lunch_dining_rounded,
    MealCategory.dinner: Icons.dinner_dining_rounded,
    MealCategory.snack: Icons.fastfood_rounded,
    MealCategory.other: Icons.cake_rounded,
  }[category]!;
}

Color mealCategoryColor(MealCategory? category) {
  return {
    MealCategory.breakfast: Colors.lightBlue,
    MealCategory.lunch: Colors.green,
    MealCategory.dinner: Colors.orange,
    MealCategory.snack: Colors.purpleAccent.withGreen(100),
    MealCategory.other: Colors.yellow,
    null: Colors.black,
  }[category]!;
}

class Meal {
  int id = -1;
  Sugar sugarLevel = Sugar();
  Insulin insulin = Insulin();
  List<Food> food = <Food>[];
  String? notes;
  MealCategory category = MealCategory.other;

  double get carbs {
    double total = 0;
    for (Food f in food) {
      total += f.amount * ((f.carbs) / 100);
    }
    return total;
  }

  String get date {
    DateTime local = sugarLevel.datetime ?? DateTime.now();
    if (local.day == DateTime.now().day) {
      return "Today";
    } else if (local.day == DateTime.now().subtract(const Duration(days: 1)).day) {
      return "Yesterday";
    } /* else if in the past 7 days return the weekday name like Sunday, Monday, Tuesday...*/ else {
      // check that local day is within the past 7 days
      if (local.isAfter(DateTime.now().subtract(const Duration(days: 7)))) {
        switch (local.weekday) {
          case 1:
            return "Monday";
          case 2:
            return "Tuesday";
          case 3:
            return "Wednesday";
          case 4:
            return "Thursday";
          case 5:
            return "Friday";
          case 6:
            return "Saturday";
          case 7:
            return "Sunday";
          default:
            return "${local.day}.${local.month}.${local.year}";
        }
      } else {
        return "${local.day}.${local.month}.${local.year}";
      }
    }
  }

  String get time {
    DateTime date = sugarLevel.datetime ?? DateTime.now();
    String minute = date.minute.toString();
    if (minute.length == 1) {
      minute = "0$minute";
    }
    String hour = date.hour.toString();
    if (hour.length == 1) {
      hour = "0$hour";
    }
    return "$hour:$minute";
  }

  Meal({
    this.id = -1,
    required this.sugarLevel,
    required this.food,
    required this.insulin,
    this.category = MealCategory.other,
    this.notes,
  });

  Meal.fromMap(Map<String, dynamic> map) {
    id = map["id"];
    notes = map["notes"];
    category = MealCategory.values[map["category"]];
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id == -1 ? null : id,
      "insulin": insulin.id,
      "sugar_id": sugarLevel.id,
      "food_ids": foodToCsv(),
      "food_amounts": food.map((e) => e.amount.toString()).join(","),
      "notes": notes,
      "category": category.index,
    };
  }

  String foodToCsv() {
    return food.map((e) => e.id.toString()).join(",");
  }

  @override
  String toString() {
    /*Meal category name (time, date)
      Sugar level: sugarLevel.sugar
        1. Food1 (amount, calcCarbs)
        2. Food2 (amount, calcCarbs)
        3. ...
      Σ Carbs: totalCarbs
      Insulin taken: insulin*/
    String categoryName = MealCategory.values[category.index].name.substring(0, 1).toUpperCase();
    categoryName += MealCategory.values[category.index].name.substring(1);
    String meal = "$categoryName ($time, $date)\n";
    meal += "Sugar level: ${sugarLevel.level}\n";
    meal += "Food (${food.length} items):\n";
    for (int i = 0; i < food.length; i++) {
      int calculations = (food[i].amount * ((food[i].carbs) / 100)).round();
      String weightAndCarbs = "(${food[i].amount}g, ${calculations}g carbs)";
      meal += "\t${i + 1}. ${food[i].name} $weightAndCarbs\n";
    }
    meal += "Σ Carbs: ${carbs.round()}\n";
    meal += "Insulin units taken: $insulin";
    return meal;
  }
}
