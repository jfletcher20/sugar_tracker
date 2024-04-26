// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sugar_tracker/data/api/u_api_meal.dart';
import 'package:sugar_tracker/data/models/m_insulin.dart';
import 'package:sugar_tracker/data/models/m_meal.dart';
import 'package:sugar_tracker/data/models/m_sugar.dart';

class MealModelState extends StateNotifier<Set<Meal>> {
  MealModelState() : super(const {}) {
    load();
  }

  Future<void> load({WidgetRef? ref}) async =>
      setMeals((await MealAPI.selectAll(ref: ref)).toSet());

  List<Meal> getMeals() {
    var sorted = state.where((element) => element.datetime != null).toList()
      ..sort((a, b) => a.datetime!.compareTo(b.datetime!));
    return sorted;
  }

  Meal getMeal(int id) {
    return state.firstWhere((t) {
      return t.id == id;
    }, orElse: () => Meal());
  }

  Meal getMealByFoodId(int id) {
    return state.firstWhere((t) {
      return t.food.any((f) => f.id == id);
    }, orElse: () => Meal());
  }

  Future<MealCategory> determineCategory() async {
    List<Meal> meals = state.where((element) => element.datetime != null).toList();
    meals.sort((a, b) => a.datetime!.compareTo(b.datetime!));

    // check if the current time is between 6am and 2pm, and if the last 5 meals' breakfast entries are all before then
    if (DateTime.now().hour >= 6 && DateTime.now().hour < 14) {
      Meal breakfastInstance = meals.lastWhere(
        (element) => element.category == MealCategory.breakfast,
        orElse: () => Meal.empty(),
      );
      if (breakfastInstance.id == -1) return MealCategory.breakfast;
      if (breakfastInstance.datetime!.day != DateTime.now().day) {
        return MealCategory.breakfast;
      } else {
        int hoursPassed = DateTime.now().hour - breakfastInstance.datetime!.hour;
        if (hoursPassed > 2)
          return MealCategory.lunch;
        else if (hoursPassed < 2) return MealCategory.snack;
      }
    }

    // check for lunch
    else if (DateTime.now().hour >= 12 && DateTime.now().hour < 18) {
      Meal lunchInstance = meals.lastWhere(
        (element) => element.category == MealCategory.lunch,
        orElse: () => Meal.empty(),
      );
      if (lunchInstance.id == -1) return MealCategory.lunch;
      if (lunchInstance.datetime!.day != DateTime.now().day) {
        return MealCategory.lunch;
      } else {
        int hoursPassed = DateTime.now().hour - lunchInstance.datetime!.hour;
        if (hoursPassed > 4)
          return MealCategory.dinner;
        else if (hoursPassed < 4) return MealCategory.snack;
      }
    }

    // check for dinner
    else if (DateTime.now().hour >= 18 && DateTime.now().hour < 23) {
      Meal dinnerInstance = meals.lastWhere(
        (element) => element.category == MealCategory.dinner,
        orElse: () => Meal.empty(),
      );
      if (dinnerInstance.id == -1) return MealCategory.dinner;
      if (dinnerInstance.datetime!.day != DateTime.now().day) return MealCategory.dinner;
    }

    return MealCategory.snack;
  }

  Future<int> addMeal(Meal meal) async {
    int id = await MealAPI.insert(meal);
    meal = meal.copyWith(id: id);
    state = {...state, meal};
    return id;
  }

  Future<void> removeMeal(Meal meal) async {
    if (state.where((element) => element.id == meal.id).isEmpty) return;
    state = state.where((element) => element != meal).toSet();
    await MealAPI.delete(meal);
  }

  void setMeals(Set<Meal> meals) => state = meals;

  Future<int> updateMeal(Meal meal) async {
    if (state.where((element) => element.id == meal.id).isEmpty) return -1;
    state = state.map((m) => m.id == meal.id ? meal : m).toSet();
    return await MealAPI.update(meal);
  }

  Meal getMealByInsulinId(Insulin insulin) {
    return state.firstWhere((element) => element.insulin.id == insulin.id, orElse: () => Meal());
  }

  Meal getMealBySugarId(Sugar sugarLevel) {
    return state.firstWhere((element) => element.sugarLevel.id == sugarLevel.id,
        orElse: () => Meal());
  }
}

class MealManager {
  static final provider = StateNotifierProvider<MealModelState, Set<Meal>>((ref) {
    return MealModelState();
  });
}
