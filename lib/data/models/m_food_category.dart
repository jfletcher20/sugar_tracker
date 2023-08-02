/* String foodCategoryTable = "CREATE TABLE food_category("
          "id INTEGER PRIMARY KEY AUTOINCREMENT,"
          "name TEXT,"
          "picture TEXT,"
          ")"; */

import 'package:sugar_tracker/data/api/u_api_food_category.dart';

class FoodCategory {
  int? id;
  String name = "Undefined";
  String? picture;
  String? notes;

  FoodCategory({this.id, this.name = "Undefined", this.picture, this.notes});

  FoodCategory.fromMap(Map<String, dynamic> map) {
    id = map["id"];
    name = map["name"];
    picture = map["picture"];
    notes = map["notes"];
  }

  Future<void> fromId(int id) async {
    FoodCategory category = await FoodCategoryAPI.selectById(id) ?? FoodCategory(name: "Unknown");
    this.id = category.id;
    name = category.name;
    picture = category.picture;
    notes = category.notes;
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id == -1 ? null : id,
      "name": name,
      "picture": picture,
      "notes": notes,
    };
  }

  @override
  String toString() {
    return name;
  }
}
