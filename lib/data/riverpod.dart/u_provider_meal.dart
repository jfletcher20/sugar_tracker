import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sugar_tracker/data/api/u_api_meal.dart';
import 'package:sugar_tracker/data/models/m_meal.dart';

class MealModelState extends StateNotifier<Set<Meal>> {
  MealModelState() : super(const {}) {
    load();
  }

  Future<void> load() async => setMeals((await MealAPI.selectAll()).toSet());

  Meal getMeal(int id) {
    return state.firstWhere((t) {
      return t.id == id;
    }, orElse: () => Meal());
  }

  Future<Meal> addMeal(Meal meal) async {
    int id = await MealAPI.insert(meal);
    meal = meal.copyWith(id: id);
    state = {...state, meal};
    return meal;
  }

  Future<void> removeMeal(Meal meal) async {
    if (state.where((element) => element.id == meal.id).isEmpty) return;
    state = state.where((element) => element != meal).toSet();
    await MealAPI.delete(meal);
  }

  void setMeals(Set<Meal> meals) => state = meals;

  Future<void> updateMeal(Meal meal) async {
    if (state.where((element) => element.id == meal.id).isEmpty) return;
    state = state.map((m) => m.id == meal.id ? meal : m).toSet();
    await MealAPI.update(meal);
  }
}

class MealManager {
  static final provider = StateNotifierProvider<MealModelState, Set<Meal>>((ref) {
    return MealModelState();
  });
}
