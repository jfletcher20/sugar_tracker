import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sugar_tracker/data/api/u_api_food.dart';
import 'package:sugar_tracker/data/models/m_food.dart';

class FoodModelState extends StateNotifier<Set<Food>> {
  FoodModelState() : super(const {}) {
    load();
  }

  Future<void> load() async => setFoods((await FoodAPI.selectAll()).toSet());

  Food getFood(int id) {
    return state.firstWhere((t) {
      return t.id == id;
    }, orElse: () => Food());
  }

  Future<Food> addFood(Food food) async {
    int id = await FoodAPI.insert(food);
    food = food.copyWith(id: id);
    state = {...state, food};
    return food;
  }

  Future<void> removeFood(Food food) async {
    if (state.where((element) => element.id == food.id).isEmpty) return;
    state = state.where((element) => element != food).toSet();
    await FoodAPI.delete(food);
  }

  void setFoods(Set<Food> foods) => state = foods;

  Future<void> updateFood(Food food) async {
    if (state.where((element) => element.id == food.id).isEmpty) return;
    state = state.map((m) => m.id == food.id ? food : m).toSet();
    await FoodAPI.update(food);
  }
}

class FoodManager {
  static final provider = StateNotifierProvider<FoodModelState, Set<Food>>((ref) {
    return FoodModelState();
  });
}
