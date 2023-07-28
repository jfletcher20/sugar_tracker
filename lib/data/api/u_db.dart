import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DB {
  static late Database db;
  static String rootPicturePath = "assets/images/foods/";
  static Future open() async {
    db = await openDatabase(join(await getDatabasesPath(), "st.db"), version: 1,
        onCreate: (database, version) {
      String foodCategoryTable =
          "CREATE TABLE food_category (id INTEGER PRIMARY KEY, name TEXT, picture TEXT)";
      // table variables should be oneline for readability
      String foodTable =
          "CREATE TABLE food (id INTEGER PRIMARY KEY, name TEXT, food_category_id INTEGER, carbs REAL, weight REAL, picture TEXT, notes TEXT)";
      String sugarTable =
          "CREATE TABLE sugar (id INTEGER PRIMARY KEY, sugar REAL, insulin REAL, date TEXT, notes TEXT)";
      String mealTable =
          "CREATE TABLE meal (id INTEGER PRIMARY KEY, sugar_id INTEGER, food_id INTEGER)";
      // create table called entire_meal which is a join of sugar and meal
      database.execute(foodCategoryTable);
      database.execute(foodTable);
      database.execute(sugarTable);
      database.execute(mealTable);

      database.insert("food_category", {
        "name": "Fruits",
        "picture": "${rootPicturePath}fruits.png",
      });
      database.insert("food_category", {
        "name": "Vegetables",
        "picture": "${rootPicturePath}vegetables.png",
      });
      database.insert("food_category", {
        "name": "Grains",
        "picture": "${rootPicturePath}grains.png",
      });
      database.insert("food_category", {
        "name": "Dairy",
        "picture": "${rootPicturePath}dairy.png",
      });
      database.insert("food_category", {
        "name": "Protein",
        "picture": "${rootPicturePath}protein.png",
      });
      database.insert("food_category", {
        "name": "Fats",
        "picture": "${rootPicturePath}fats.png",
      });
      database.insert("food_category", {
        "name": "Sweets",
        "picture": "${rootPicturePath}sweets.png",
      });
      database.insert("food_category", {
        "name": "Beverages",
        "picture": "${rootPicturePath}beverages.png",
      });
      database.insert("food_category", {
        "name": "Miscellaneous",
        "picture": "${rootPicturePath}miscellaneous.png",
      });

      // insert foods with database.insert
      database.insert("food", {
        "name": "Apple",
        "food_category_id": 1,
        "carbs": 25.13,
        "weight": 100,
        "picture": rootPicturePath + "apple.png",
        "notes": "1 medium apple",
      });

      database.insert("food", {
        "name": "Banana",
        "food_category_id": 1,
        "carbs": 26.95,
        "weight": 100,
        "picture": rootPicturePath + "banana.png",
        "notes": "1 medium banana",
      });

      database.insert("food", {
        "name": "Grapes",
        "food_category_id": 1,
        "carbs": 18.1,
        "weight": 100,
        "picture": rootPicturePath + "grapes.png",
        "notes": "1 cup grapes",
      });

      database.insert("food", {
        "name": "Orange",
        "food_category_id": 1,
        "carbs": 11.75,
        "weight": 100,
        "picture": rootPicturePath + "orange.png",
        "notes": "1 medium orange",
      });

      // insert sugar entries with database.insert

      database.insert("sugar", {
        "sugar": 5.5,
        "insulin": 0,
        "date": "2021-10-01 12:00:00",
        "notes": "before lunch",
      });

      database.insert("sugar", {
        "sugar": 6.5,
        "insulin": 0,
        "date": "2021-10-01 18:00:00",
        "notes": "before dinner",
      });

      database.insert("sugar", {
        "sugar": 7.5,
        "insulin": 0,
        "date": "2021-10-02 12:00:00",
        "notes": "before lunch",
      });

      database.insert("sugar", {
        "sugar": 8.5,
        "insulin": 0,
        "date": "2021-10-02 18:00:00",
        "notes": "before dinner",
      });

      database.insert("sugar", {
        "sugar": 9.5,
        "insulin": 0,
        "date": "2021-10-03 12:00:00",
        "notes": "before lunch",
      });

      database.insert("sugar", {
        "sugar": 10.5,
        "insulin": 0,
        "date": "2021-10-03 18:00:00",
        "notes": "before dinner",
      });

      database.insert("sugar", {
        "sugar": 11.5,
        "insulin": 0,
        "date": "2021-10-04 12:00:00",
        "notes": "before lunch",
      });

      database.insert("sugar", {
        "sugar": 12.5,
        "insulin": 0,
        "date": "2021-10-04 18:00:00",
        "notes": "before dinner",
      });

      // insert meals with database.insert

      database.insert("meal", {
        "sugar_id": 1,
        "food_id": 1,
      });

      database.insert("meal", {
        "sugar_id": 1,
        "food_id": 2,
      });

      database.insert("meal", {
        "sugar_id": 1,
        "food_id": 3,
      });

      database.insert("meal", {
        "sugar_id": 1,
        "food_id": 4,
      });

      database.insert("meal", {
        "sugar_id": 2,
        "food_id": 1,
      });

      database.insert("meal", {
        "sugar_id": 2,
        "food_id": 2,
      });

      database.insert("meal", {
        "sugar_id": 2,
        "food_id": 3,
      });
    });
  }

  // generate insert commands
  static Future<int> insert(String table, Map<String, dynamic> data) async {
    return await db.insert(table, data);
  }

  // generate update commands
  static Future<int> update(String table, Map<String, dynamic> data) async {
    return await db.update(table, data);
  }

  // generate delete commands
  static Future<int> delete(String table, int id) async {
    return await db.delete(table, where: "id = ?", whereArgs: [id]);
  }

  // generate select commands
  static Future<List<Map<String, dynamic>>> select(String table) async {
    return await db.query(table);
  }

  // generate select commands with where clause
  static Future<List<Map<String, dynamic>>> selectWhere(
      String table, String where, List<dynamic> whereArgs) async {
    return await db.query(table, where: where, whereArgs: whereArgs);
  }
}
