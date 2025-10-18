// class for CRUD on food_category table

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sugar_tracker/data/models/m_food_category.dart';
import 'package:sugar_tracker/data/api/u_db.dart';
import 'package:sugar_tracker/data/riverpod.dart/u_provider_food_category.dart';

class FoodCategoryAPI {
  static Future<int> insert(FoodCategory foodCategory) async {
    return await DB.db.insert("food_category", foodCategory.toMap());
  }

  static Future<int> update(FoodCategory foodCategory) async {
    return await DB.db.update("food_category", foodCategory.toMap(),
        where: "id = ?", whereArgs: [foodCategory.id]);
  }

  static Future<int> delete(FoodCategory foodCategory) async {
    return await DB.db.delete("food_category", where: "id = ?", whereArgs: [foodCategory.id]);
  }

  static Future<List<FoodCategory>> selectAll({WidgetRef? ref}) async {
    if (ref != null) {
      var categories = ref.read(FoodCategoryManager.provider.notifier).getFoodCategories();
      if (categories.isNotEmpty) return categories;
    }
    List<Map<String, dynamic>> results = await DB.db.query("food_category");
    return results.map((map) => FoodCategory.fromMap(map)).toList();
  }

  static Future<FoodCategory?> selectById(int id, {WidgetRef? ref}) async {
    if (ref != null) {
      var category = ref.read(FoodCategoryManager.provider.notifier).getFoodCategory(id);
      if (category.id != -1) return category;
    }
    List<Map<String, dynamic>> results =
        await DB.db.query("food_category", where: "id = ?", whereArgs: [id]);
    if (results.isNotEmpty) {
      return FoodCategory.fromMap(results.first);
    }
    return null;
  }

  static Future<String> export() async {
    List<Map<String, dynamic>> results = await DB.select("food_category");
    String output = "";
    for (Map<String, dynamic> map in results) {
      output +=
          "INSERT INTO food_category VALUES(${map["id"]}, '${map["name"]}', '${map["picture"]}', '${map["notes"]}');\n";
    }
    return output;
  }
}
