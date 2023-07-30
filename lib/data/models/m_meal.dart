/* 
      String mealTable = "CREATE TABLE meal("
          "id INTEGER PRIMARY KEY AUTOINCREMENT,"
          "sugar_id INTEGER,"
          "insulin REAL,"
          "food_ids TEXT,"
          ")"; */

import 'package:sugar_tracker/data/models/m_food.dart';
import 'package:sugar_tracker/data/models/m_sugar.dart';

enum MealCategory { breakfast, lunch, dinner, snack, other }

class Meal {
  int? id;
  Sugar? sugar;
  double insulin = 0;
  List<Food> food = <Food>[];
  String? notes;
  MealCategory? category;

  double get carbs {
    double total = 0;
    for (Food f in food) {
      total += (f.carbs ?? 0) * f.amount;
    }
    return total;
  }

  String get date {
    // parse sugar date into format hh:mm dd.mm.'yy
    DateTime date = sugar!.date!;
    String hourMinute = "${date.hour}:${date.minute}";
    // if ends with :0 or starts with 0: then append or add another 0
    if (hourMinute.endsWith(":0")) {
      hourMinute += "0";
    } else if (hourMinute.startsWith("0:")) {
      hourMinute = "0$hourMinute";
    }
    return "$hourMinute, ${date.day}.${date.month}.${date.year}";
  }

  Meal({this.id, this.sugar, required this.food, this.insulin = 0, this.category, this.notes});

  Meal.fromMap(Map<String, dynamic> map) {
    id = map["id"];
    insulin = map["insulin"];
    notes = map["notes"];
    category = MealCategory.values[map["category"]];
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "insulin": insulin,
      "sugar_id": sugar?.id,
      "food_ids": foodToCsv(),
      "food_amounts": food.map((e) => e.amount.toString()).join(","),
      "notes": notes,
      "category": category?.index,
    };
  }

  String foodToCsv() {
    return food.map((e) => e.id.toString()).join(",");
  }

  @override
  String toString() {
    return "Meal(id: $id, insulin: $insulin, sugar: $sugar, food: $food, notes: $notes, category: $category)";
  }
}
