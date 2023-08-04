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
  int id = -1;
  String name = "Unknown";
  FoodCategory foodCategory = FoodCategory(name: "Unknown");
  double carbs = 0;
  double weight = 0;
  String picture = "";
  String? notes;
  int _amount = 0;
  int get amount => _amount;
  set amount(int value) {
    if (value >= 0) {
      _amount = value;
    } else {
      _amount = 0;
    }
  }

  Food({
    this.id = -1,
    this.name = "Unknown",
    required this.foodCategory,
    this.carbs = 0,
    this.weight = 0,
    this.picture = "",
    this.notes,
    int amount = 0,
  }) : _amount = amount;

  Food.fromMap(Map<String, dynamic> map) {
    id = map["id"];
    name = map["name"];
    carbs = map["carbs"];
    weight = map["weight"];
    picture = map["picture"];
    notes = map["notes"];
    amount = map["amount"];
    foodCategory = FoodCategory(id: map["food_category_id"] ?? -1);
  }

  Future<void> fromId(int id) async {
    Food food = await FoodAPI.selectById(id) ??
        Food(name: "Unknown", foodCategory: FoodCategory(name: "Unknown"));
    this.id = food.id;
    foodCategory = food.foodCategory;
    name = food.name;
    carbs = food.carbs;
    weight = food.weight;
    picture = food.picture;
    notes = food.notes;
    amount = food.amount;
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id == -1 ? null : id,
      "name": name,
      "food_category_id": foodCategory.id,
      "carbs": carbs,
      "weight": weight,
      "picture": picture,
      "notes": notes,
      "amount": amount,
    };
  }

  @override
  String toString() {
    String result = "$name - ${carbs.round()}g of carbs";
    result += notes == null ? "" : "($notes)";
    return result;
  }
}
