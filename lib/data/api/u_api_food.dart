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
    return results.map((map) => Food.fromMap(map)).toList();
  }

  // select food entry from db by id
  static Future<Food?> selectById(int id) async {
    List<Map<String, dynamic>> results =
        await DB.db.query("food", where: "id = ?", whereArgs: [id]);
    if (results.isNotEmpty) {
      // get food category and store it in food
      FoodCategory? category = await FoodCategoryAPI.selectById(results.first["food_category_id"]);
      return Food.fromMap(results.first)..category = category;
    }
    return null;
  }
}
