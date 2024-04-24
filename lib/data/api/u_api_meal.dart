// api for inserting, updating, deleting, and selecting data from meal table in db

// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:sugar_tracker/data/api/u_api_food.dart';
import 'package:sugar_tracker/data/api/u_api_insulin.dart';
import 'package:sugar_tracker/data/api/u_api_sugar.dart';
import 'package:sugar_tracker/data/api/u_db.dart';
import 'package:sugar_tracker/data/models/m_food.dart';
import 'package:sugar_tracker/data/models/m_food_category.dart';
import 'package:sugar_tracker/data/models/m_insulin.dart';
import 'package:sugar_tracker/data/models/m_meal.dart';
import 'package:sugar_tracker/data/models/m_sugar.dart';

class MealAPI {
  // insert meal entry into db
  static Future<int> insert(Meal meal) async => await DB.insert("meal", meal.toMap());

  // update meal entry in db
  static Future<int> update(Meal meal) async => await DB.update("meal", meal.toMap());

  // delete meal entry from db
  static Future<int> delete(Meal meal) async => await DB.delete("meal", meal.id);

  // select all meal entries from db as meals
  static Future<List<Meal>> selectAll() async {
    // get all meals, and for each meal, get the sugar and food
    List<Meal> result = List.empty(growable: true);
    List<Map<String, dynamic>> meals = await DB.select("meal");

    for (Map<String, dynamic> meal in meals) {
      Sugar sugar = await SugarAPI.selectById(meal["sugar_id"]) ?? Sugar(notes: "Unknown");
      Insulin insulin = await InsulinAPI.selectById(meal["insulin"]) ?? Insulin(notes: "Unknown");
      if (meal["food_ids"] is String) {
        String ids = meal["food_ids"];
        List<String> notParsed = ids.split(",");
        List<Food> food = await FoodAPI.selectByIds(notParsed);
        meal["food_amounts"].split(",").asMap().forEach((i, amount) {
          food[i].amount = int.parse(amount);
        });
        result.add(Meal.fromMap(meal)
          ..sugarLevel = sugar
          ..insulin = insulin
          ..food = food);
      } else {
        List<Food> food = [
          await FoodAPI.selectById(meal["food_ids"]) ??
              Food(foodCategory: FoodCategory(name: "Unknown"))
        ];
        meal["food_amounts"].split(",").asMap().forEach((i, amount) {
          food[i].amount = int.parse(amount);
        });
        result.add(Meal.fromMap(meal)
          ..sugarLevel = sugar
          ..insulin = insulin
          ..food = food);
      }
    }

    return result;
  }

  // determines meal category
  static Future<MealCategory> determineCategory() async {
    // get the last 5 meals and cleverly determine if the new one, based on the time of day and the recent meal history, is supposed to be breakfast, lunch, dinner, or snack
    List<Map<String, dynamic>> lastFiveResults =
        (await DB.db.rawQuery("SELECT * FROM meal ORDER BY id DESC LIMIT 5"));
    List<Meal> lastFive =
        await Future.wait(lastFiveResults.map((e) => parseResultsAndGetSugarInsulinFood(e)))
          ..sort((a, b) => a.datetime.compareTo(b.datetime));
    // check if the current time is between 6am and 2pm, and if the last 5 meals' breakfast entries are all before then
    if (DateTime.now().hour >= 6 && DateTime.now().hour < 14) {
      Meal breakfastInstance =
          lastFive.lastWhere((element) => element.category == MealCategory.breakfast);
      if (breakfastInstance.datetime.day != DateTime.now().day) {
        return MealCategory.breakfast;
      } else {
        int hoursPassed = DateTime.now().hour - breakfastInstance.datetime.hour;
        if (hoursPassed > 2)
          return MealCategory.lunch;
        else if (hoursPassed < 2) return MealCategory.snack;
      }
    }
    // check for lunch
    else if (DateTime.now().hour >= 12 && DateTime.now().hour < 18) {
      Meal lunchInstance = lastFive.lastWhere((element) => element.category == MealCategory.lunch);
      if (lunchInstance.datetime.day != DateTime.now().day) {
        return MealCategory.lunch;
      } else {
        int hoursPassed = DateTime.now().hour - lunchInstance.datetime.hour;
        if (hoursPassed > 4)
          return MealCategory.dinner;
        else if (hoursPassed < 4) return MealCategory.snack;
      }
    }

    // check for dinner
    else if (DateTime.now().hour >= 18 && DateTime.now().hour < 23) {
      Meal dinnerInstance =
          lastFive.lastWhere((element) => element.category == MealCategory.dinner);
      if (dinnerInstance.datetime.day != DateTime.now().day) return MealCategory.dinner;
    }

    return MealCategory.snack;
  }

  // select meal entry from db by id
  static Future<Meal> selectByFoodId(int foodId) async {
    Map<String, dynamic> result =
        (await DB.db.rawQuery("SELECT * FROM meal WHERE food_ids = ?", [foodId.toString()])).first;

    Sugar sugar = await SugarAPI.selectById(result["sugar_id"]) ?? Sugar(notes: "Unknown");
    Insulin insulin = await InsulinAPI.selectById(result["insulin"]) ?? Insulin(notes: "Unknown");
    List<Food> food = await FoodAPI.selectByIds(result["food_ids"].split(","));

    result["food_amounts"].split(",").asMap().forEach((i, amount) {
      food[i].amount = int.parse(amount);
    });

    return Meal.fromMap(result)
      ..sugarLevel = sugar
      ..insulin = insulin
      ..food = food;
  }

  static Future<Meal> parseResultsAndGetSugarInsulinFood(Map<String, dynamic> result) async {
    Sugar sugar = Sugar(notes: "Unknown");
    Insulin insulin = Insulin(notes: "Unknown");
    List<Food> food = [];

    if (result["sugar_id"] != null)
      sugar = await SugarAPI.selectById(result["sugar_id"]) ?? Sugar(notes: "Unknown");
    if (result["insulin"] != null)
      insulin = await InsulinAPI.selectById(result["insulin"]) ?? Insulin(notes: "Unknown");
    if (result["food_ids"] != null) {
      List<String> ids = result["food_ids"].split(",");
      food = await FoodAPI.selectByIds(ids);
      result["food_amounts"].split(",").asMap().forEach((i, amount) {
        food[i].amount = int.parse(amount);
      });
    }

    return Meal.fromMap(result)
      ..sugarLevel = sugar
      ..insulin = insulin
      ..food = food;
  }

  // select meal entries from db by sugar id
  static Future<Meal> selectBySugarId(Sugar sugar) async {
    Map<String, dynamic> result;
    try {
      result = (await DB.db.rawQuery("SELECT * FROM meal WHERE sugar_id = ?", [sugar.id])).first;
    } catch (e) {
      return Meal(
        sugarLevel: Sugar(notes: "Unknown"),
        insulin: Insulin(notes: "Unknown"),
        food: [],
      );
    }

    Insulin insulin = await InsulinAPI.selectById(result["insulin"]) ?? Insulin(notes: "Unknown");
    List<String> ids = result["food_ids"].split(",");
    List<Food> food = await FoodAPI.selectByIds(ids);

    result["food_amounts"].split(",").asMap().forEach((i, amount) {
      food[i].amount = int.parse(amount);
    });

    return Meal.fromMap(result)
      ..sugarLevel = sugar
      ..insulin = insulin
      ..food = food;
  }

  static Future<Meal> selectById(int id) async {
    Map<String, dynamic> result =
        (await DB.db.rawQuery("SELECT * FROM meal WHERE id = ?", [id])).first;

    Sugar sugar = await SugarAPI.selectById(result["sugar_id"]) ?? Sugar(notes: "Unknown");
    Insulin insulin = await InsulinAPI.selectById(result["insulin"]) ?? Insulin(notes: "Unknown");
    List<Food> food = await FoodAPI.selectByIds(result["food_ids"].split(","));

    result["food_amounts"].split(",").asMap().forEach((i, amount) {
      food[i].amount = int.parse(amount);
    });

    return Meal.fromMap(result)
      ..sugarLevel = sugar
      ..insulin = insulin
      ..food = food;
  }

  static Future<Meal> selectByInsulinId(Insulin insulin) async {
    Map<String, dynamic> result;
    try {
      result = (await DB.db.rawQuery("SELECT * FROM meal WHERE insulin = ?", [insulin.id])).first;
    } catch (e) {
      return Meal(
        sugarLevel: Sugar(notes: "Unknown"),
        insulin: Insulin(notes: "Unknown"),
        food: [],
      );
    }

    Sugar sugar = await SugarAPI.selectById(result["sugar_id"]) ?? Sugar(notes: "Unknown");
    var ids = result["food_ids"];
    if (ids == "") {
      await MealAPI.delete(Meal.fromMap(result));
      return Meal(
        sugarLevel: sugar,
        insulin: insulin,
        food: [],
      );
    }
    List<Food> food = await FoodAPI.selectByIds(result["food_ids"].split(","));

    result["food_amounts"].split(",").asMap().forEach((i, amount) {
      food[i].amount = int.parse(amount);
    });

    return Meal.fromMap(result)
      ..sugarLevel = sugar
      ..insulin = insulin
      ..food = food;
  }

  static Future<String> export() async {
    List<Map<String, dynamic>> results = await DB.select("meal");
    String output = "";
    for (Map<String, dynamic> map in results) {
      output +=
          "INSERT INTO meal VALUES(${map["id"]}, ${map["insulin"]}, ${map["sugar_id"]}, '${map["food_ids"]}', '${map["food_amounts"]}', '${map["notes"]}', ${map["category"]});\n";
    }
    return output;
  }
}
