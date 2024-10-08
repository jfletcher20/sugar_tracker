// api for CRUD on food table

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sugar_tracker/data/api/u_api_food_category.dart';
import 'package:sugar_tracker/data/api/u_api_meal.dart';
import 'package:sugar_tracker/data/models/m_food.dart';
import 'package:sugar_tracker/data/api/u_db.dart';
import 'package:sugar_tracker/data/models/m_food_category.dart';
import 'package:sugar_tracker/data/models/m_meal.dart';
import 'package:sugar_tracker/data/riverpod.dart/u_provider_meal.dart';

class FoodAPI {
  // insert food entry into db
  static Future<int> insert(Food food) async {
    var data = food.toMap()..remove("id");
    return await DB.insert("food", data);
  }

  // update food entry in db
  static Future<int> update(Food food) async {
    return await DB.db.update("food", food.toMap(), where: "id = ?", whereArgs: [food.id]);
  }

  // delete food entry from db
  static Future<int> delete(Food food, {WidgetRef? ref}) async {
    List<Meal> meals = ref == null
        ? await MealAPI.selectAll()
        : ref.read(MealManager.provider.notifier).getMeals();
    meals = meals.where((meal) => meal.food.any((f) => f.id == food.id)).toList();
    for (Meal meal in meals) {
      meal.food.removeWhere((f) => f.id == food.id);
      if (meal.food.isEmpty && ref != null) {
        await ref.read(MealManager.provider.notifier).removeMeal(meal);
      } else if (ref == null && meal.food.isEmpty) {
        throw Exception("Cannot delete food entry, because it is used in a meal");
      } else
        await MealAPI.update(meal);
    }
    return await DB.delete("food", food.id);
  }

  // select all food entries from db
  static Future<List<Food>> selectAll() async {
    List<Map<String, dynamic>> results = await DB.select("food");
    List<Food> food = results.map((map) => Food.fromMap(map)).toList();
    for (int i = 0; i < food.length; i++) {
      food[i].foodCategory = await FoodCategoryAPI.selectById(food[i].foodCategory.id) ??
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
      return Food.fromMap(results.first)..foodCategory = category;
    }
    return null;
  }

  static Future<List<Food>> selectByIds(List<String> ids) async {
    // for each id in ids store result from selectById function
    List<Food> food = List.empty(growable: true);
    for (String id in ids) {
      food.add(
        await selectById(int.parse(id)) ?? Food(foodCategory: FoodCategory(name: "Unknown")),
      );
    }
    return food;
  }

  static Future<String> export() async {
    // export table as list of insert commands and include the null-values
    List<Map<String, dynamic>> results = await DB.select("food");
    String output = "";
    for (Map<String, dynamic> map in results) {
      output += "INSERT INTO food VALUES (";
      output += "${map["id"]}, ";
      output += "'${map["name"]}', ";
      output += "${map["food_category_id"]}, ";
      output += "${map["carbs"]}, ";
      output += "${map["weight"]}, ";
      output += "'${map["picture"]}', ";
      output += "'${map["notes"]}'";
      output += ");\n";
    }
    return output;
  }
}
