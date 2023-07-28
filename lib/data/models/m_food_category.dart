/* String foodCategoryTable = "CREATE TABLE food_category("
          "id INTEGER PRIMARY KEY AUTOINCREMENT,"
          "name TEXT,"
          "picture TEXT,"
          ")"; */

import 'package:sugar_tracker/data/api/u_api_food_category.dart';

class FoodCategory {
  int? id;
  String? name;
  String? picture;

  FoodCategory({this.id, required this.name, this.picture});

  FoodCategory.fromMap(Map<String, dynamic> map) {
    id = map["id"];
    name = map["name"];
    picture = map["picture"];
  }

  Future<void> fromId(int id) async {
    FoodCategory category = await FoodCategoryAPI.selectById(id) ?? FoodCategory(name: "Unknown");
    this.id = category.id;
    name = category.name;
    picture = category.picture;
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "picture": picture,
    };
  }
}
