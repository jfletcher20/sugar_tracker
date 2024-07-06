// ignore_for_file: curly_braces_in_flow_control_structures
import 'package:sugar_tracker/data/riverpod.dart/u_provider_meal.dart';
import 'package:sugar_tracker/presentation/widgets/food_category/w_dgv_food_category.dart';
import 'package:sugar_tracker/presentation/widgets/food/w_food_counter.dart';
import 'package:sugar_tracker/data/riverpod.dart/u_provider_food.dart';
import 'package:sugar_tracker/data/models/m_food.dart';
import 'package:sugar_tracker/data/models/m_meal.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

class FoodSelectorWidget extends ConsumerStatefulWidget {
  final Meal meal;
  const FoodSelectorWidget({super.key, required this.meal});

  @override
  ConsumerState<FoodSelectorWidget> createState() => _FoodSelectorWidgetState();
}

class _FoodSelectorWidgetState extends ConsumerState<FoodSelectorWidget> {
  final GlobalKey<FoodCategoryGridViewState> foodCategoryKey = GlobalKey();
  late List<Food> allFoods = List.empty(growable: true);
  bool loadCategories = true;

  void initFoods({bool withSetState = false}) {
    if (allFoods.isEmpty) allFoods = ref.read(FoodManager.provider.notifier).getFoods();
    widget.meal.food = widget.meal.food.where((element) => element.amount > 0).toList();
    for (Food food in allFoods)
      if (!widget.meal.food.any((element) => element.id == food.id)) widget.meal.food.add(food);
    if (foodCategoryKey.currentState!.allSelected.isNotEmpty)
      widget.meal.food.retainWhere(
        (food) => foodCategoryKey.currentState!.allSelected.any(
          (c) => c.id == food.foodCategory.id || food.amount > 0,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (widget.meal.food.isNotEmpty) {
      child = listView();
    } else {
      child = FutureBuilder(
        future: Future.delayed(Duration.zero, () => initFoods()),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done)
            return listView();
          else if (snapshot.hasError) return Text("${snapshot.error}");
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
      child: SingleChildScrollView(child: Column(children: [_foodCategoryFilter(), child])),
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
          onSelect: (category) => setState(() => initFoods()),
        ),
      ),
    );
  }

  Widget listView() {
    widget.meal.food.sort((a, b) => a.name.compareTo(b.name));
    widget.meal.food.sort((a, b) => a.foodCategory.name.compareTo(b.foodCategory.name));

    List<Meal> allMeals = ref.read(MealManager.provider.notifier).getMeals();
    List<Food> foodUsage = [];

    for (Meal meal in allMeals) {
      for (Food food in meal.food) {
        foodUsage.firstWhere((element) => element.id == food.id, orElse: () {
          foodUsage.add(food.copyWith(amount: 1));
          return food;
        }).amount++;
      }
    }

    foodUsage.sort((a, b) {
      int aUsage = a.amount;
      int bUsage = b.amount;
      return bUsage.compareTo(aUsage);
    });

    List<Food> selected = [];
    List<Food> unselected = [];
    for (int i = 0; i < widget.meal.food.length; i++)
      if (widget.meal.food[i].amount > 0)
        selected.add(widget.meal.food[i]);
      else
        unselected.add(widget.meal.food[i]);
    selected.sort((a, b) => b.amount.compareTo(a.amount));
    selected.sort((a, b) => a.name.compareTo(b.name));
    selected.sort((a, b) => a.foodCategory.name.compareTo(b.foodCategory.name));

    unselected.sort((a, b) {
      int? aUsage = foodUsage.where((element) => element.id == a.id).firstOrNull?.amount;
      int? bUsage = foodUsage.where((element) => element.id == b.id).firstOrNull?.amount;
      return aUsage == null || bUsage == null ? 0 : bUsage.compareTo(aUsage);
    });

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
