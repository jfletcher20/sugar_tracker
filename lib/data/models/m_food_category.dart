// ignore_for_file: curly_braces_in_flow_control_structures

/* String foodCategoryTable = "CREATE TABLE food_category("
          "id INTEGER PRIMARY KEY AUTOINCREMENT,"
          "name TEXT,"
          "picture TEXT,"
          ")"; */

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
