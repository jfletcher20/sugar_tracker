// ignore_for_file: avoid_print

import 'package:sugar_tracker/data/models/m_food.dart';
import 'package:sugar_tracker/data/models/m_food_category.dart';
import 'package:sugar_tracker/data/models/m_meal.dart';
import 'package:sugar_tracker/data/models/m_sugar.dart';
import 'package:sugar_tracker/presentation/routes/w_food_list.dart';
import 'package:sugar_tracker/presentation/routes/w_meal_history.dart';
import 'package:sugar_tracker/presentation/routes/w_sugar_history.dart';
import 'package:sugar_tracker/presentation/widgets/food/w_food_form.dart';
import 'package:sugar_tracker/presentation/widgets/meal/w_meal_form.dart';
import 'package:sugar_tracker/presentation/widgets/w_table_editor.dart';
import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  Widget child = const MealHistoryWidget();
  int index = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sugar Tracker"), actions: [
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

  Widget _tableEditorButton() {
    return const TableEditorWidget();
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
      ],
      onTap: (index) {
        setState(() {
          this.index = index;
          // shorthand switch for index
          switch (index) {
            case 0:
              child = const MealHistoryWidget();
            case 1:
              child = const SugarHistoryWidget();
            case 2:
              child = const FoodListWidget();
          }
        });
      },
    );
  }
}
