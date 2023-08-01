// ignore_for_file: avoid_print

import 'package:sugar_tracker/data/api/u_db.dart';
import 'package:sugar_tracker/data/models/m_meal.dart';
import 'package:sugar_tracker/data/models/m_sugar.dart';
import 'package:sugar_tracker/presentation/routes/w_meal_history.dart';
import 'package:sugar_tracker/presentation/routes/w_sugar_history.dart';
import 'package:flutter/material.dart';
import 'package:sugar_tracker/presentation/widgets/meal/w_meals_form.dart';

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
            setState(() => child = MealFormWidget(meal: Meal(sugarLevel: Sugar(), food: [])));
          },
          icon: const Icon(Icons.add),
        ),
        IconButton(
          onPressed: () {
            // show dialog with text field for table name and button to clear the table
            TextEditingController tableName = TextEditingController();
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
}
