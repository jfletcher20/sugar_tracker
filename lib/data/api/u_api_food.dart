// api for CRUD on food table

import 'package:sugar_tracker/data/api/u_api_food_category.dart';
import 'package:sugar_tracker/data/models/m_food.dart';
import 'package:sugar_tracker/data/api/u_db.dart';
import 'package:sugar_tracker/data/models/m_food_category.dart';

class FoodAPI {
  // insert food entry into db
  static Future<int> insert(Food food) async {
    return await DB.db.insert("food", food.toMap());
  }

  // update food entry in db
  static Future<int> update(Food food) async {
    return await DB.db.update("food", food.toMap(), where: "id = ?", whereArgs: [food.id]);
  }

  // delete food entry from db
  static Future<int> delete(Food food) async {
    return await DB.db.delete("food", where: "id = ?", whereArgs: [food.id]);
  }

  // select all food entries from db
  static Future<List<Food>> selectAll() async {
    List<Map<String, dynamic>> results = await DB.db.query("food");
    List<Food> food = results.map((map) => Food.fromMap(map)).toList();
    for (int i = 0; i < food.length; i++) {
      food[i].category = await FoodCategoryAPI.selectById(results[i]["food_category_id"]) ??
          FoodCategory(name: "Unknown");
    }
    return food;
  }

  // select food entry from db by id
  static Future<Food?> selectById(int id) async {
    List<Map<String, dynamic>> results =
        await DB.db.query("food", where: "id = ?", whereArgs: [id]);
    if (results.isNotEmpty) {
      // get food category and store it in food
      FoodCategory category = await FoodCategoryAPI.selectById(results.first["food_category_id"]) ??
          FoodCategory(name: "Unknown");
      return Food.fromMap(results.first)..category = category;
    }
    return null;
  }

  static Future<List<Food>> selectByIds(List<int> ids) async {
    // for each id in ids store result from selectById function
    List<Food> food = List.empty(growable: true);
    for (int id in ids) {
      food.add(await selectById(id) ?? Food(category: FoodCategory(name: "Unknown")));
    }
    return food;
  }
}
