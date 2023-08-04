import 'package:flutter/material.dart';
import 'package:sugar_tracker/data/api/u_api_food.dart';
import 'package:sugar_tracker/data/models/m_food.dart';
import 'package:sugar_tracker/data/models/m_food_category.dart';
import 'package:sugar_tracker/data/models/m_meal.dart';
import 'package:sugar_tracker/presentation/widgets/food/w_food_counter.dart';
import 'package:sugar_tracker/presentation/widgets/food_category/w_dgv_food_category.dart';

class FoodSelectorWidget extends StatefulWidget {
  final Meal meal;
  const FoodSelectorWidget({super.key, required this.meal});

  @override
  State<FoodSelectorWidget> createState() => _FoodSelectorWidgetState();
}

class _FoodSelectorWidgetState extends State<FoodSelectorWidget> {
  final GlobalKey<FoodCategoryGridViewState> foodCategoryKey = GlobalKey();
  late List<Food> allFoods = List.empty(growable: true);
  bool loadCategories = true;

  Future<void> initFoods() async {
    if (allFoods.isEmpty) allFoods = await FoodAPI.selectAll();
    widget.meal.food = widget.meal.food.where((element) => element.amount > 0).toList();
    for (Food food in allFoods) {
      if (!widget.meal.food.any((element) => element.id == food.id)) {
        widget.meal.food.add(food);
      }
    }
    if (foodCategoryKey.currentState!.allSelected.isNotEmpty) {
      widget.meal.food.retainWhere(
        (food) => foodCategoryKey.currentState!.allSelected.any(
          (c) => c.id == food.foodCategory.id || food.amount > 0,
        ),
      );
    }
    if (context.mounted) setState(() {});
    return;
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (widget.meal.food.isNotEmpty) {
      child = listView();
    } else {
      child = FutureBuilder(
        future: initFoods(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return listView();
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          return Card(
            child: Container(
              padding: const EdgeInsets.all(64),
              height: 321,
              child: const Text("No food in this category"),
            ),
          );
        },
      );
    }
    return WillPopScope(
      child: SingleChildScrollView(
        child: Column(
          children: [_foodCategoryFilter(), child],
        ),
      ),
      onWillPop: () {
        Navigator.pop(context, widget.meal.food);
        return Future.value(false);
      },
    );
  }

  Widget _foodCategoryFilter() {
    return Card(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: FoodCategoryGridView(
          key: foodCategoryKey,
          multiSelect: true,
          crossAxisCount: 8,
          crossAxisSpacing: 0,
          mainAxisSpacing: 0,
          onSelect: (category) async {
            await initFoods();
          },
        ),
      ),
    );
  }

  Widget listView() {
    widget.meal.food.sort((a, b) => a.name.compareTo(b.name));
    widget.meal.food.sort((a, b) => a.foodCategory.name.compareTo(b.foodCategory.name));
    List<Food> selected = [];
    List<Food> unselected = [];
    for (int i = 0; i < widget.meal.food.length; i++) {
      if (widget.meal.food[i].amount > 0) {
        selected.add(widget.meal.food[i]);
      } else {
        unselected.add(widget.meal.food[i]);
      }
    }
    selected.sort((a, b) => b.amount.compareTo(a.amount));
    selected.sort((a, b) => a.name.compareTo(b.name));
    selected.sort((a, b) => a.foodCategory.name.compareTo(b.foodCategory.name));
    widget.meal.food = selected + unselected;
    return SingleChildScrollView(
      child: Column(
        children: [
          for (int i = 0; i < widget.meal.food.length; i++)
            FoodCounterWidget(food: widget.meal.food[i], modifiable: true),
          if (widget.meal.food.isEmpty) const Text("No food items found"),
        ],
      ),
    );
  }
}
