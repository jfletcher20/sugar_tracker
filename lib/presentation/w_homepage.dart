// ignore_for_file: avoid_print

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sugar_tracker/data/models/m_food.dart';
import 'package:sugar_tracker/data/models/m_food_category.dart';
import 'package:sugar_tracker/data/models/m_insulin.dart';
import 'package:sugar_tracker/data/models/m_meal.dart';
import 'package:sugar_tracker/data/models/m_sugar.dart';
import 'package:sugar_tracker/data/preferences.dart';
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
        _profileButton(),
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
                meal: Meal(sugarLevel: Sugar(), food: [], insulin: Insulin()),
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

  Widget _profileButton() {
    return IconButton(
      onPressed: () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        double storedWeight = prefs.getDouble("weight") ?? 60;
        TextEditingController weight = TextEditingController(
          text: storedWeight > 0
              ? storedWeight == storedWeight.round()
                  ? storedWeight.toInt().toString()
                  : storedWeight.toString()
              : "",
        );
        List<double> storedDividers =
            prefs.getStringList("dividers")?.map((e) => double.parse(e)).toList() ??
                [10, 10, 10, 10, 10];
        List<TextEditingController> dividers =
            List.from(storedDividers.map((e) => TextEditingController(
                text: e > 0
                    ? e == e.round()
                        ? e.toInt().toString()
                        : e.toString()
                    : "")));
        // ignore: use_build_context_synchronously
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Profile"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: weight,
                    // add label at end saying "kg" for kilograms, and hint text should be "Weight"
                    decoration: const InputDecoration(
                      labelText: "Weight",
                      suffixText: "kg",
                      suffixStyle: TextStyle(color: Colors.white),
                    ),
                    inputFormatters: limitDecimals,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                  for (int i = 0; i < dividers.length; i++)
                    TextField(
                      controller: dividers[i],
                      decoration: InputDecoration(
                        labelText: MealCategory.values[i].name.substring(0, 1).toUpperCase() +
                            MealCategory.values[i].name.substring(1),
                        hintText: "Divider for ${MealCategory.values[i].name}",
                        labelStyle: TextStyle(color: mealCategoryColor(MealCategory.values[i])),
                      ),
                      // ensure input is a number of at least 1
                      inputFormatters: limitDecimals,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  bool showWarning = false;
                  List<String> offenders = [];
                  for (TextEditingController divider in dividers) {
                    if (divider.text == "" || double.parse(divider.text) < 1) {
                      divider.text = "1";
                      offenders.add(MealCategory.values[dividers.indexOf(divider)].name);
                      showWarning = true;
                    }
                  }
                  if (showWarning) {
                    String warning = "Dividers must be at least 1";
                    String mealCategories = offenders.join(", ");
                    String plural = offenders.length > 1 ? "s" : "";
                    String warningText = "$warning (set divider$plural for $mealCategories to 1)";
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(warningText),
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                  await Profile.setWeight(double.parse(weight.text == "" ? "60" : weight.text));
                  await Profile.setDividers(dividers.map((e) => e.text).toList());
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text("Save"),
              ),
            ],
          ),
        );
      },
      icon: const Icon(Icons.person),
    );
  }

  Widget _bottomNavigation() {
    return BottomNavigationBar(
      landscapeLayout: BottomNavigationBarLandscapeLayout.spread,
      type: BottomNavigationBarType.shifting,
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
          icon: Icon(Icons.edit_outlined),
          label: "Insulin",
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
            // case 2:
            //   child = const InsulinHistoryWidget();
            case 3:
              child = const FoodListWidget();
          }
          // change to fancy short-handswitch
        });
      },
    );
  }

  List<TextInputFormatter> get limitDecimals {
    return <TextInputFormatter>[
      LengthLimitingTextInputFormatter(5),
      TextInputFormatter.withFunction((oldValue, newValue) {
        if (newValue.text.contains(",")) {
          return TextEditingValue(
            text: newValue.text.replaceAll(",", "."),
            selection: newValue.selection,
          );
        }
        return newValue;
      }),
      TextInputFormatter.withFunction((oldValue, newValue) {
        if (newValue.text.split(".").length > 2) {
          return oldValue;
        }
        return newValue;
      }),
      TextInputFormatter.withFunction((oldValue, newValue) {
        if (newValue.text.contains(".")) {
          if (newValue.text.split(".")[0].length > 3) {
            return oldValue;
          } else if (newValue.text.split(".")[1].length > 1) {
            return oldValue;
          }
        } else {
          if (newValue.text.length > 3) {
            return oldValue;
          }
        }
        return newValue;
      }),
    ];
  }
}
