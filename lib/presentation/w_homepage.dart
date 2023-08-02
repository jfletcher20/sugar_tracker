// ignore_for_file: avoid_print

import 'package:sugar_tracker/data/api/u_db.dart';
import 'package:sugar_tracker/data/models/m_food.dart';
import 'package:sugar_tracker/data/models/m_food_category.dart';
import 'package:sugar_tracker/data/models/m_meal.dart';
import 'package:sugar_tracker/data/models/m_sugar.dart';
import 'package:sugar_tracker/presentation/routes/w_meal_history.dart';
import 'package:sugar_tracker/presentation/routes/w_sugar_history.dart';
import 'package:flutter/material.dart';
import 'package:sugar_tracker/presentation/widgets/food/w_food_form.dart';
import 'package:sugar_tracker/presentation/widgets/meal/w_meal_form.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  Widget child = const SugarHistoryWidget();
  int index = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sugar Tracker"), actions: [
        _mealHistoryTab(),
        _sugarHistoryTab(),
        _createMealButton(),
        _createFoodItemButton(),
        _tableEditorButton(),
      ]),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: child,
      ),
      bottomNavigationBar: _bottomNavigation(),
    );
  }

  IconButton _mealHistoryTab() {
    return IconButton(
      onPressed: () => setState(() => child = const MealHistoryWidget()),
      icon: const Icon(Icons.fastfood),
    );
  }

  IconButton _sugarHistoryTab() {
    return IconButton(
      onPressed: () => setState(() => child = const SugarHistoryWidget()),
      icon: const Icon(Icons.query_stats),
    );
  }

  IconButton _createMealButton() {
    return IconButton(
      onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: const Text("Create a meal")),
              body: MealFormWidget(
                meal: Meal(sugarLevel: Sugar(), food: []),
              ),
            ),
          ),
        );
        if (context.mounted) setState(() {});
      },
      icon: const Icon(Icons.add),
    );
  }

  IconButton _createFoodItemButton() {
    return IconButton(
      onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: const Text("Create a food item")),
              body: FoodFormWidget(food: Food(foodCategory: FoodCategory(name: "Unknown"))),
            ),
          ),
        );
        if (context.mounted) setState(() {});
      },
      icon: const Icon(Icons.food_bank),
    );
  }

  void debug(TextEditingController tableNameController) async {
    List tables = await DB.db.query('sqlite_master', columns: ['type', 'name']);
    tables = tables.getRange(1, tables.length).toList();
    String tableNames = "";
    for (var table in tables) {
      tableNames += table["name"] + "\n";
    }
    print(tableNames);
    // show dialog with list of tables as textbuttons
    // when pressed, set the tableNameController's value to the table name
    // and close the dialog
    // ignore: use_build_context_synchronously
    showDialog(
      context: context,
      builder: (context) {
        return ListView(
          children: tableNames
              .split("\n")
              .map(
                (e) => TextButton(
                  onPressed: () {
                    tableNameController.text = e;
                    Navigator.pop(context);
                  },
                  child: Text(e),
                ),
              )
              .toList(),
        );
      },
    );
  }

  IconButton _tableEditorButton() {
    return IconButton(
      onPressed: () {
        TextEditingController tableNameController = TextEditingController();
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text("Table editor"),
              IconButton(
                onPressed: () {
                  debug(tableNameController);
                  setState(() {});
                },
                icon: const Icon(Icons.code),
              ),
            ]),
            content: TextField(
              controller: tableNameController,
              decoration: const InputDecoration(hintText: "Table Name"),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  void printTable() async {
                    List val = await DB.select(tableNameController.text.toLowerCase());
                    String output = "";
                    output = val.map((e) => e.toString()).toList().join("\n\n");
                    print(output);
                    // ignore: use_build_context_synchronously
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Table Data"),
                        content: SingleChildScrollView(child: Text(output)),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("Close"),
                          ),
                        ],
                      ),
                    );
                  }

                  printTable();
                  // Navigator.pop(context);
                },
                child: const Text("Get"),
              ),
              TextButton(
                onPressed: () {
                  DB.db.delete(tableNameController.text.toLowerCase());
                  Navigator.pop(context);
                },
                child: const Text("Clear"),
              ),
              TextButton(
                onPressed: () {
                  // raw query drop table
                  DB.db.rawDelete("DROP TABLE ${tableNameController.text.toLowerCase()}");
                  Navigator.pop(context);
                },
                child: const Text("Drop table"),
              ),
            ],
          ),
        );
        setState(() {});
      },
      icon: const Icon(Icons.create),
    );
  }

  Widget _bottomNavigation() {
    return BottomNavigationBar(
      landscapeLayout: BottomNavigationBarLandscapeLayout.spread,
      type: BottomNavigationBarType.fixed,
      currentIndex: index,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.fastfood),
          label: "Meals",
          backgroundColor: Colors.black,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.query_stats),
          label: "Sugars",
          backgroundColor: Colors.black,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.food_bank),
          label: "Foods",
          backgroundColor: Colors.black,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.category),
          label: "Categories",
          backgroundColor: Colors.black,
        ),
      ],
      onTap: (index) {
        setState(() {
          this.index = index;
          if (index == 0) {
            child = const MealHistoryWidget();
          } else {
            child = const SugarHistoryWidget();
          }
        });
      },
    );
  }
}
