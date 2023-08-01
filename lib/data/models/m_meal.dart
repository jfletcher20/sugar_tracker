/* 
      String mealTable = "CREATE TABLE meal("
          "id INTEGER PRIMARY KEY AUTOINCREMENT,"
          "sugar_id INTEGER,"
          "insulin REAL,"
          "food_ids TEXT,"
          ")"; */

import 'package:sugar_tracker/data/models/m_food.dart';
import 'package:sugar_tracker/data/models/m_sugar.dart';

import 'package:flutter/material.dart';

enum MealCategory { breakfast, lunch, dinner, snack, other }

Color mealCategoryColor(MealCategory category) {
  return {
    MealCategory.breakfast: Colors.lightBlue,
    MealCategory.lunch: Colors.green,
    MealCategory.dinner: Colors.orange,
    MealCategory.snack: Colors.purpleAccent.withGreen(100),
    MealCategory.other: Colors.yellow,
  }[category]!;
}

class Meal {
  int? id;
  Sugar sugarLevel = Sugar();
  int insulin = 0;
  List<Food> food = <Food>[];
  String? notes;
  MealCategory category = MealCategory.other;

  double get carbs {
    double total = 0;
    for (Food f in food) {
      total += f.amount * ((f.carbs ?? 0) / 100);
    }
    return total;
  }

  String get date {
    DateTime date = sugarLevel.datetime ?? DateTime.now();
    return "${date.day}.${date.month}.${date.year}";
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
    this.id,
    required this.sugarLevel,
    required this.food,
    this.insulin = 0,
    this.category = MealCategory.other,
    this.notes,
  });

  Meal.fromMap(Map<String, dynamic> map) {
    id = map["id"];
    insulin = map["insulin"].round();
    notes = map["notes"];
    category = MealCategory.values[map["category"]];
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "insulin": insulin,
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
    return "Meal(id: $id, insulin: $insulin, sugar: $sugarLevel, food: $food, notes: $notes, category: $category)";
  }
}
