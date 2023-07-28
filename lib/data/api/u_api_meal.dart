// api for inserting, updating, deleting, and selecting data from meal table in db

import 'package:sugar_tracker/data/api/u_api_food.dart';
import 'package:sugar_tracker/data/api/u_api_sugar.dart';
import 'package:sugar_tracker/data/api/u_db.dart';
import 'package:sugar_tracker/data/models/m_food.dart';
import 'package:sugar_tracker/data/models/m_meal.dart';
import 'package:sugar_tracker/data/models/m_sugar.dart';

class MealAPI {
  // insert meal entry into db
  static Future<int> insert(int sugarId, int foodId) async {
    return await DB.db
        .rawInsert("INSERT INTO meal(sugar_id, food_id) VALUES(?, ?)", [sugarId, foodId]);
  }

  // update meal entry in db
  static Future<int> update(int sugarId, int foodId) async {
    return await DB.db.rawUpdate(
        "UPDATE meal SET sugar_id = ?, food_id = ? WHERE sugar_id = ? AND food_id = ?",
        [sugarId, foodId, sugarId, foodId]);
  }

  // delete meal entry from db
  static Future<int> delete(int sugarId, int foodId) async {
    return await DB.db
        .rawDelete("DELETE FROM meal WHERE sugar_id = ? AND food_id = ?", [sugarId, foodId]);
  }

  // select all meal entries from db as meals
  static Future<List<Meal>> selectAll() async {
    List<Meal> result = List.empty(growable: true);
    // get all meals, and for each meal, get the sugar and food
    List<Map<String, dynamic>> meals = await DB.db.rawQuery("SELECT * FROM meal");
    for (Map<String, dynamic> meal in meals) {
      Sugar? sugar = await SugarAPI.selectById(meal["sugar_id"]);
      Food? food = await FoodAPI.selectById(meal["food_id"]);
      result.add(Meal.fromMap(meal)
        ..sugar = sugar
        ..food = food);
    }
    return result;
  }

  // select meal entry from db by id
  static Future<Meal> selectById(int sugarId, int foodId) async {
    List<Map<String, dynamic>> results = await DB.db
        .rawQuery("SELECT * FROM meal WHERE sugar_id = ? AND food_id = ?", [sugarId, foodId]);
    return Meal.fromMap(results[0]);
  }
}
