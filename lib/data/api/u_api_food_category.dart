// class for CRUD on food_category table

import 'package:sugar_tracker/data/models/m_food_category.dart';
import 'package:sugar_tracker/data/api/u_db.dart';

class FoodCategoryAPI {
  // insert food_category entry into db
  static Future<int> insert(FoodCategory foodCategory) async {
    return await DB.db.insert("food_category", foodCategory.toMap());
  }

  // update food_category entry in db
  static Future<int> update(FoodCategory foodCategory) async {
    return await DB.db.update("food_category", foodCategory.toMap(),
        where: "id = ?", whereArgs: [foodCategory.id]);
  }

  // delete food_category entry from db
  static Future<int> delete(FoodCategory foodCategory) async {
    return await DB.db.delete("food_category", where: "id = ?", whereArgs: [foodCategory.id]);
  }

  // select all food_category entries from db
  static Future<List<FoodCategory>> selectAll() async {
    List<Map<String, dynamic>> results = await DB.db.query("food_category");
    return results.map((map) => FoodCategory.fromMap(map)).toList();
  }

  // select food_category entry from db by id
  static Future<FoodCategory?> selectById(int id) async {
    List<Map<String, dynamic>> results =
        await DB.db.query("food_category", where: "id = ?", whereArgs: [id]);
    if (results.isNotEmpty) {
      return FoodCategory.fromMap(results.first);
    }
    return null;
  }
}
