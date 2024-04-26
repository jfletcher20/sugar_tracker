import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sugar_tracker/data/api/u_api_food.dart';
import 'package:sugar_tracker/data/models/m_food.dart';
import 'package:sugar_tracker/data/models/m_food_category.dart';

class FoodModelState extends StateNotifier<Set<Food>> {
  FoodModelState() : super(const {}) {
    load();
  }

  Future<void> load() async => setFoods((await FoodAPI.selectAll()).toSet());

  List<Food> getFoods() {
    var sorted = state.toList()..sort((a, b) => a.name.compareTo(b.name));
    return sorted;
  }

  List<Food> getFilteredFoods(List<FoodCategory> foodCategories) {
    var foods = state.toList();
    if (foodCategories.isEmpty) return foods;
    return foods..retainWhere((food) => foodCategories.any((c) => c.id == food.foodCategory.id));
  }

  Food getFood(int id) {
    return state.firstWhere((t) {
      return t.id == id;
    }, orElse: () => Food());
  }

  Future<int> addFood(Food food) async {
    int id = await FoodAPI.insert(food);
    food = food.copyWith(id: id);
    state = {...state, food};
    return id;
  }

  Future<void> removeFood(Food food) async {
    if (state.where((element) => element.id == food.id).isEmpty) return;
    state = state.where((element) => element != food).toSet();
    await FoodAPI.delete(food);
  }

  void setFoods(Set<Food> foods) => state = foods;

  Future<int> updateFood(Food food) async {
    if (state.where((element) => element.id == food.id).isEmpty) return -1;
    state = state.map((m) => m.id == food.id ? food : m).toSet();
    return await FoodAPI.update(food);
  }

  List<Food> getFoodsByIds(List<String> notParsed) {
    List<int> ids = notParsed.map((e) => int.parse(e)).toList();
    return ids.map((id) => getFood(id)).toList();
  }
}

class FoodManager {
  static final provider = StateNotifierProvider<FoodModelState, Set<Food>>((ref) {
    return FoodModelState();
  });
}
