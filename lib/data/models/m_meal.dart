/* 
      String mealTable = "CREATE TABLE meal("
          "id INTEGER PRIMARY KEY AUTOINCREMENT,"
          "sugar_id INTEGER,"
          "food_id INTEGER,"
          "FOREIGN KEY(sugar_id) REFERENCES sugar(id),"
          "FOREIGN KEY(food_id) REFERENCES food(id)"
          ")"; */

import 'package:sugar_tracker/data/models/m_food.dart';
import 'package:sugar_tracker/data/models/m_sugar.dart';

class Meal {
  int? id;
  Sugar? sugar;
  Food? food;

  Meal({this.id, this.sugar, this.food});

  Meal.fromMap(Map<String, dynamic> map) {
    id = map["id"];
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "sugar_id": sugar?.toMap(),
      "food_id": food?.toMap(),
    };
  }

  @override
  String toString() {
    return "Meal(id: $id, sugar: $sugar, food: $food)";
  }
}
