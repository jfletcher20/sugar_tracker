/* 
      String mealTable = "CREATE TABLE meal("
          "id INTEGER PRIMARY KEY AUTOINCREMENT,"
          "sugar_id INTEGER,"
          "insulin REAL,"
          "food_ids TEXT,"
          ")"; */

import 'package:sugar_tracker/data/models/m_food.dart';
import 'package:sugar_tracker/data/models/m_sugar.dart';

class Meal {
  int? id;
  Sugar? sugar;
  double insulin = 0;
  List<Food> food = <Food>[];
  String? notes;

  Meal({this.id, this.sugar, required this.food, this.insulin = 0, this.notes});

  Meal.fromMap(Map<String, dynamic> map) {
    id = map["id"];
    insulin = map["insulin"];
    notes = map["notes"];
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "insulin": insulin,
      "sugar_id": sugar?.id,
      "food_ids": foodToCsv(),
      "notes": notes,
    };
  }

  String foodToCsv() {
    return food.map((e) => e.id.toString()).join(",");
  }

  @override
  String toString() {
    return "Meal(id: $id, insulin: $insulin, sugar: $sugar, food: $food)";
  }
}
