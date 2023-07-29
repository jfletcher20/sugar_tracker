// ignore_for_file: avoid_print

import 'package:sugar_tracker/data/api/u_db.dart';
import 'package:sugar_tracker/presentation/routes/w_meal_history.dart';
import 'package:sugar_tracker/presentation/routes/w_sugar_history.dart';
import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  Widget child = const SugarHistoryWidget();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sugar Tracker"), actions: [
        IconButton(
          onPressed: () {
            setState(() => child = const MealHistoryWidget());
          },
          icon: const Icon(Icons.food_bank),
        ),
        IconButton(
          onPressed: () {
            setState(() => child = const SugarHistoryWidget());
          },
          icon: const Icon(Icons.query_stats),
        ),
        IconButton(
          onPressed: () {
            // show dialog with text field for table name and button to clear the table
            TextEditingController tableName = TextEditingController();
            TextEditingController text2 = TextEditingController();
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("Clear Table"),
                content: TextField(
                  controller: tableName,
                  decoration: const InputDecoration(hintText: "Table Name"),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      DB.db.delete(tableName.text);
                      Navigator.pop(context);
                    },
                    child: const Text("Clear"),
                  ),
                  TextButton(
                    onPressed: () {
                      // raw query drop table
                      DB.db.rawDelete("DROP TABLE ${tableName.text}");
                      Navigator.pop(context);
                    },
                    child: const Text("Drop table"),
                  ),
                  // create textbutton that shows dialog to insert data into db
                  TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Insert Data into meals"),
                          content: TextField(
                            controller: text2,
                            decoration: const InputDecoration(hintText: "this does nothing rn"),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                // randomly generate meal entries
                                _meals();
                                Navigator.pop(context);
                              },
                              child: const Text("Insert"),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text("Insert"),
                  ),
                ],
              ),
            );
            setState(() {});
          },
          icon: const Icon(Icons.create),
        ),
        IconButton(
          onPressed: () {
            debug();
            setState(() {});
          },
          icon: const Icon(Icons.code),
        ),
      ]),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: child,
      ),
    );
  }

  void debug() async {
    // ignore: avoid_function_literals_in_foreach_calls
    (await DB.db.query('sqlite_master', columns: ['type', 'name'])).forEach((row) {
      print(row.values);
    });
  }

  void func() {
    String rootPicturePath = "assets/images/food/";
    // insert food categories with DB.db.insert
    DB.db.insert("food_category", {
      "name": "Fruits",
      "picture": "${rootPicturePath}fruits.png",
    });
    DB.db.insert("food_category", {
      "name": "Vegetables",
      "picture": "${rootPicturePath}vegetables.png",
    });
    DB.db.insert("food_category", {
      "name": "Grains",
      "picture": "${rootPicturePath}grains.png",
    });
    DB.db.insert("food_category", {
      "name": "Dairy",
      "picture": "${rootPicturePath}dairy.png",
    });
    DB.db.insert("food_category", {
      "name": "Protein",
      "picture": "${rootPicturePath}protein.png",
    });
    DB.db.insert("food_category", {
      "name": "Fats",
      "picture": "${rootPicturePath}fats.png",
    });
    DB.db.insert("food_category", {
      "name": "Sweets",
      "picture": "${rootPicturePath}sweets.png",
    });
    DB.db.insert("food_category", {
      "name": "Beverages",
      "picture": "${rootPicturePath}beverages.png",
    });
    DB.db.insert("food_category", {
      "name": "Miscellaneous",
      "picture": "${rootPicturePath}miscellaneous.png",
    });

    // insert foods with DB.db.insert
    DB.db.insert("food", {
      "name": "Apple",
      "food_category_id": 1,
      "carbs": 25.13,
      "weight": 100,
      "picture": rootPicturePath + "apple.png",
      "notes": "1 medium apple",
    });

    DB.db.insert("food", {
      "name": "Banana",
      "food_category_id": 1,
      "carbs": 26.95,
      "weight": 100,
      "picture": rootPicturePath + "banana.png",
      "notes": "1 medium banana",
    });

    DB.db.insert("food", {
      "name": "Grapes",
      "food_category_id": 1,
      "carbs": 18.1,
      "weight": 100,
      "picture": rootPicturePath + "grapes.png",
      "notes": "1 cup grapes",
    });

    DB.db.insert("food", {
      "name": "Orange",
      "food_category_id": 1,
      "carbs": 11.75,
      "weight": 100,
      "picture": rootPicturePath + "orange.png",
      "notes": "1 medium orange",
    });

    // insert sugar entries with DB.db.insert

    DB.db.insert("sugar", {
      "sugar": 5.5,
      "insulin": 0,
      "date": "2021-10-01 12:00:00",
      "notes": "before lunch",
    });

    DB.db.insert("sugar", {
      "sugar": 6.5,
      "insulin": 0,
      "date": "2021-10-01 18:00:00",
      "notes": "before dinner",
    });

    DB.db.insert("sugar", {
      "sugar": 7.5,
      "insulin": 0,
      "date": "2021-10-02 12:00:00",
      "notes": "before lunch",
    });

    DB.db.insert("sugar", {
      "sugar": 8.5,
      "insulin": 0,
      "date": "2021-10-02 18:00:00",
      "notes": "before dinner",
    });

    DB.db.insert("sugar", {
      "sugar": 9.5,
      "insulin": 0,
      "date": "2021-10-03 12:00:00",
      "notes": "before lunch",
    });

    DB.db.insert("sugar", {
      "sugar": 10.5,
      "insulin": 0,
      "date": "2021-10-03 18:00:00",
      "notes": "before dinner",
    });

    DB.db.insert("sugar", {
      "sugar": 11.5,
      "insulin": 0,
      "date": "2021-10-04 12:00:00",
      "notes": "before lunch",
    });

    DB.db.insert("sugar", {
      "sugar": 12.5,
      "insulin": 0,
      "date": "2021-10-04 18:00:00",
      "notes": "before dinner",
    });

    // insert meals with DB.db.insert

    DB.db.insert("meal", {
      "sugar_id": 1,
      "food_ids": 1,
    });

    DB.db.insert("meal", {
      "sugar_id": 1,
      "food_ids": 2,
    });

    DB.db.insert("meal", {
      "sugar_id": 1,
      "food_ids": 3,
    });

    DB.db.insert("meal", {
      "sugar_id": 1,
      "food_ids": 4,
    });

    DB.db.insert("meal", {
      "sugar_id": 2,
      "food_ids": 1,
    });

    DB.db.insert("meal", {
      "sugar_id": 2,
      "food_ids": 2,
    });

    DB.db.insert("meal", {
      "sugar_id": 2,
      "food_ids": 3,
    });

    setState(() {});
  }
}

void _meals() {
  DB.db.insert("meal", {
    "sugar_id": 1,
    "food_ids": 1,
  });

  DB.db.insert("meal", {
    "sugar_id": 1,
    "food_ids": 2,
  });

  DB.db.insert("meal", {
    "sugar_id": 1,
    "food_ids": 3,
  });

  DB.db.insert("meal", {
    "sugar_id": 1,
    "food_ids": 4,
  });

  DB.db.insert("meal", {
    "sugar_id": 2,
    "food_ids": 1,
  });

  DB.db.insert("meal", {
    "sugar_id": 2,
    "food_ids": 2,
  });

  DB.db.insert("meal", {
    "sugar_id": 2,
    "food_ids": 3,
  });
}
