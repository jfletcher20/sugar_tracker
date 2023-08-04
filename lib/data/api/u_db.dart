import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DB {
  static late Database db;
  static String rootPicturePath = "assets/images";
  static String rootFoodPicturePath = "$rootPicturePath/food";
  static String foodCategoryPicturePath = "$rootPicturePath/food_category";
  static Future open() async {
    db = await openDatabase(join(await getDatabasesPath(), "st.db"), version: 1,
        onCreate: (database, version) {
      String foodCategoryTable =
          "CREATE TABLE food_category (id INTEGER PRIMARY KEY, name TEXT, picture TEXT, notes TEXT)";
      // table variables should be oneline for readability
      String foodTable =
          "CREATE TABLE food (id INTEGER PRIMARY KEY, name TEXT, food_category_id INTEGER, carbs REAL, weight REAL, picture TEXT, notes TEXT, amount INTEGER)";
      String sugarTable =
          "CREATE TABLE sugar (id INTEGER PRIMARY KEY, sugar REAL, date TEXT, notes TEXT)";
      String insulinTable =
          "CREATE TABLE insulin (id INTEGER PRIMARY KEY, name TEXT, date TEXT, insulin_category INTEGER, notes TEXT)";
      String mealTable =
          "CREATE TABLE meal (id INTEGER PRIMARY KEY, sugar_id INTEGER, food_ids TEXT, food_amounts TEXT, insulin INTEGER, notes TEXT, category INTEGER)";
      // create table called entire_meal which is a join of sugar and meal
      database.execute(foodCategoryTable);
      database.execute(foodTable);
      database.execute(sugarTable);
      database.execute(insulinTable);
      database.execute(mealTable);

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

      // insert foods with database.insert
      database.insert("food", {
        "name": "Apple",
        "food_category_id": 1,
        "carbs": 14,
        "weight": 100,
        "picture": "$rootFoodPicturePath/apple.png",
        "notes": "1 medium apple",
        "amount": 0,
      });

      database.insert("food", {
        "name": "Banana",
        "food_category_id": 1,
        "carbs": 23,
        "weight": 100,
        "picture": "$rootFoodPicturePath/banana.png",
        "notes": "1 medium banana",
        "amount": 0,
      });

      database.insert("food", {
        "name": "Grapes",
        "food_category_id": 1,
        "carbs": 17,
        "weight": 100,
        "picture": "$rootFoodPicturePath/grapes.png",
        "notes": "1 cup grapes",
        "amount": 0,
      });

      database.insert("food", {
        "name": "Orange",
        "food_category_id": 1,
        "carbs": 12,
        "weight": 100,
        "picture": "$rootFoodPicturePath/orange.png",
        "notes": "1 medium orange",
        "amount": 0,
      });

      // insert sugar entries with database.insert

      database.insert("sugar", {
        "sugar": 5.5,
        "date": "2021-10-01 12:00:00",
        "notes": "before lunch",
      });

      database.insert("sugar", {
        "sugar": 6.5,
        "date": "2021-10-01 18:00:00",
        "notes": "before dinner",
      });

      database.insert("sugar", {
        "sugar": 7.5,
        "date": "2021-10-02 12:00:00",
        "notes": "before lunch",
      });

      database.insert("sugar", {
        "sugar": 8.5,
        "date": "2021-10-02 18:00:00",
        "notes": "before dinner",
      });

      database.insert("sugar", {
        "sugar": 9.5,
        "date": "2021-10-03 12:00:00",
        "notes": "before lunch",
      });

      database.insert("sugar", {
        "sugar": 10.5,
        "date": "2021-10-03 18:00:00",
        "notes": "before dinner",
      });

      database.insert("sugar", {
        "sugar": 11.5,
        "date": "2021-10-04 12:00:00",
        "notes": "before lunch",
      });

      database.insert("sugar", {
        "sugar": 12.5,
        "date": "2021-10-04 18:00:00",
        "notes": "before dinner",
      });

      // insert meals with database.insert
      database.insert("meal", {
        "sugar_id": 1,
        "food_ids": "1,2,3",
        "food_amounts": "60,50,50",
        "insulin": 1,
        "notes": "lunch",
        "category": 1,
      });

      database.insert("meal", {
        "sugar_id": 2,
        "food_ids": "2,4,1",
        "food_amounts": "100,200,150",
        "insulin": 2,
        "notes": "dinner",
        "category": 2,
      });

      database.insert("meal", {
        "sugar_id": 3,
        "food_ids": "3,2",
        "food_amounts": "100,20",
        "insulin": 3,
        "notes": "breakfast",
        "category": 0,
      });

      database.insert("meal", {
        "sugar_id": 4,
        "food_ids": "4,1",
        "food_amounts": "50,30",
        "insulin": 4,
        "notes": "dinner",
        "category": 2,
      });

      database.insert("meal", {
        "sugar_id": 5,
        "food_ids": "1",
        "food_amounts": "180",
        "insulin": 5,
        "notes": "A simple treat on the side",
        "category": 4,
      });

      // insert snack
      database.insert("meal", {
        "sugar_id": 6,
        "food_ids": "1,2,3,4",
        "food_amounts": "30,20,40,20",
        "insulin": 6,
        "notes": "A fruit bowl with a side of nuts and cheese",
        "category": 3,
      });

      database.insert("meal", {
        "sugar_id": 7,
        "food_ids": "1,2",
        "food_amounts": "100,250",
        "insulin": 7,
        "notes": "breakfast",
        "category": 0,
      });

      // insert snack
      database.insert("meal", {
        "sugar_id": 8,
        "food_ids": "4",
        "food_amounts": "360",
        "insulin": 8,
        "notes": "A couple oranges",
        "category": 4,
      });
    });

    // insert 8 insulins with database.insert and random units
    db.insert("insulin", {
      "name": "Humalog",
      "date": "2021-10-01 12:00:00",
      "units": 5,
      "insulin_category": 0,
      "notes": "before lunch",
    });

    db.insert("insulin", {
      "name": "Humalog",
      "date": "2021-10-01 18:00:00",
      "units": 10,
      "insulin_category": 0,
      "notes": "before dinner",
    });

    db.insert("insulin", {
      "name": "Humalog",
      "date": "2021-10-02 12:00:00",
      "units": 15,
      "insulin_category": 0,
      "notes": "before lunch",
    });

    db.insert("insulin", {
      "name": "Humalog",
      "date": "2021-10-01 12:00:00",
      "units": 5,
      "insulin_category": 0,
      "notes": "before lunch",
    });

    db.insert("insulin", {
      "name": "Humalog",
      "date": "2021-10-01 18:00:00",
      "units": 10,
      "insulin_category": 0,
      "notes": "before dinner",
    });

    db.insert("insulin", {
      "name": "Humalog",
      "date": "2021-10-02 12:00:00",
      "units": 15,
      "insulin_category": 0,
      "notes": "before lunch",
    });

    db.insert("insulin", {
      "name": "Humalog",
      "date": "2021-10-01 18:00:00",
      "units": 10,
      "insulin_category": 0,
      "notes": "before dinner",
    });

    db.insert("insulin", {
      "name": "Humalog",
      "date": "2021-10-02 12:00:00",
      "units": 15,
      "insulin_category": 0,
      "notes": "before lunch",
    });
  }

  // generate insert commands
  static Future<int> insert(String table, Map<String, dynamic> data) async {
    return await db.insert(table, data);
  }

  // generate update commands
  static Future<int> update(String table, Map<String, dynamic> data) async {
    return await db.update(table, data, where: "id = ?", whereArgs: [data["id"]]);
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
