// create model based on sql command:

/* "CREATE TABLE food("
          "id INTEGER PRIMARY KEY AUTOINCREMENT,"
          "name TEXT,"
          "carbs REAL,"
          "weight REAL,"
          "picture TEXT,"
          "notes TEXT,"
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

  Food({this.id, this.name, this.category, this.carbs, this.weight, this.picture, this.notes});

  Food.fromMap(Map<String, dynamic> map) {
    id = map["id"];
    name = map["name"];
    carbs = map["carbs"];
    weight = map["weight"];
    picture = map["picture"];
    notes = map["notes"];
  }

  Future<void> fromId(int id) async {
    Food category = await FoodAPI.selectById(id) ?? Food(name: "Unknown");
    this.id = category.id;
    this.category = category.category;
    name = category.name;
    carbs = category.carbs;
    weight = category.weight;
    picture = category.picture;
    notes = category.notes;
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
    };
  }
}
