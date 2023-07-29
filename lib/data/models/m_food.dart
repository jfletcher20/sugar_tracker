// create model based on sql command:

/* "CREATE TABLE food("
          "id INTEGER PRIMARY KEY,"
          "name TEXT,"
          "carbs REAL,"
          "weight REAL,"
          "picture TEXT,"
          "notes TEXT,"
          "amount INTEGER"
          ")"; */

import 'package:sugar_tracker/data/api/u_api_food.dart';
import 'package:sugar_tracker/data/models/m_food_category.dart';

class Food {
  int? id;
  String? name;
  FoodCategory? category;
  double? carbs;
  double? weight;
  String? picture;
  String? notes;
  int amount = 0;

  Food(
      {this.id,
      this.name,
      this.category,
      this.carbs,
      this.weight,
      this.picture,
      this.notes,
      this.amount = 0});

  Food.fromMap(Map<String, dynamic> map) {
    id = map["id"];
    name = map["name"];
    carbs = map["carbs"];
    weight = map["weight"];
    picture = map["picture"];
    notes = map["notes"];
    amount = map["amount"] ?? 0;
  }

  Future<void> fromId(int id) async {
    Food food = await FoodAPI.selectById(id) ?? Food(name: "Unknown");
    this.id = food.id;
    category = food.category;
    name = food.name;
    carbs = food.carbs;
    weight = food.weight;
    picture = food.picture;
    notes = food.notes;
    amount = food.amount;
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "category": category?.id,
      "carbs": carbs,
      "weight": weight,
      "picture": picture,
      "notes": notes,
      "amount": amount,
    };
  }
}
