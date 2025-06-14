// ignore_for_file: curly_braces_in_flow_control_structures

/* String foodCategoryTable = "CREATE TABLE food_category("
          "id INTEGER PRIMARY KEY AUTOINCREMENT,"
          "name TEXT,"
          "picture TEXT,"
          ")"; */

import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sugar_tracker/data/api/u_api_food_category.dart';
import 'package:sugar_tracker/data/riverpod.dart/u_provider_food_category.dart';

class FoodCategory {
  int id = -1;
  String name = "Undefined";
  String picture = "assets/images/food/unknown.png";
  String notes = "";

  FoodCategory({
    this.id = -1,
    this.name = "Undefined",
    this.picture = "assets/images/food/unknown.png",
    this.notes = "",
  });

  FoodCategory copyWith({int? id, String? name, String? picture, String? notes}) {
    return FoodCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      picture: picture ?? this.picture,
      notes: notes ?? this.notes,
    );
  }

  FoodCategory.fromMap(Map<String, dynamic> map) {
    id = map["id"];
    name = map["name"];
    picture = map["picture"];
    notes = map["notes"];
  }

  Color get color {
    /*
      database.insert("food_category", {
        "name": "Fruit",
        "picture": "$foodCategoryPicturePath/fruit.png",
        "notes": "Fruits are high in carbs",
      });
      database.insert("food_category", {
        "name": "Veggies",
        "picture": "$foodCategoryPicturePath/veggies.png",
        "notes": "Vegetables are low in carbs",
      });
      database.insert("food_category", {
        "name": "Grain",
        "picture": "$foodCategoryPicturePath/grain.png",
        "notes": "Grains are high in carbs",
      });
      database.insert("food_category", {
        "name": "Dairy",
        "picture": "$foodCategoryPicturePath/dairy.png",
        "notes": "Dairy is high in carbs",
      });
      database.insert("food_category", {
        "name": "Protein",
        "picture": "$foodCategoryPicturePath/protein.png",
        "notes": "Protein is low in carbs",
      });
      database.insert("food_category", {
        "name": "Dessert",
        "picture": "$foodCategoryPicturePath/dessert.png",
        "notes": "Desserts are high in carbs",
      });
      database.insert("food_category", {
        "name": "Drinks",
        "picture": "$foodCategoryPicturePath/drinks.png",
        "notes": "Beverages are high in carbs",
      });
      database.insert("food_category", {
        "name": "Misc",
        "picture": "$foodCategoryPicturePath/misc.png",
        "notes": "Miscellaneous foods.",
      });
*/
    switch (name.toLowerCase()) {
      case "fruit":
        return const Color.fromARGB(255, 59, 255, 180); // Amber
      case "veggies":
        return const Color.fromARGB(255, 5, 206, 11); // Green
      case "grain":
        return const Color.fromARGB(255, 255, 188, 62); // Brown
      case "dairy":
        return const Color.fromARGB(255, 44, 135, 255); // Grey
      case "protein":
        return const Color.fromARGB(255, 233, 36, 29); // Blue
      case "dessert":
        return const Color.fromARGB(255, 27, 255, 217); // Pink
      case "drinks":
        return const Color.fromARGB(255, 255, 34, 200); // Deep Orange
      case "misc":
        return const Color(0xFF9E9E9E); // Blue Grey
      default:
        return const Color(0xFF9E9E9E); // Default Grey
    }
  }

  Future<void> fromId(int id, {WidgetRef? ref}) async {
    FoodCategory category;
    if (ref != null)
      category = ref.read(FoodCategoryManager.provider.notifier).getFoodCategory(id);
    else
      category = await FoodCategoryAPI.selectById(id) ?? FoodCategory(name: "Unknown");
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
