import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sugar_tracker/data/api/u_api_food_category.dart';
import 'package:sugar_tracker/data/models/m_food_category.dart';

class FoodCategoryModelState extends StateNotifier<Set<FoodCategory>> {
  FoodCategoryModelState() : super(const {}) {
    load();
  }

  Future<void> load() async => setFoodCategories((await FoodCategoryAPI.selectAll()).toSet());

  FoodCategory getFoodCategory(int id) {
    return state.firstWhere((t) {
      return t.id == id;
    }, orElse: () => FoodCategory());
  }

  Future<FoodCategory> addFoodCategory(FoodCategory foodCategory) async {
    int id = await FoodCategoryAPI.insert(foodCategory);
    foodCategory = foodCategory.copyWith(id: id);
    state = {...state, foodCategory};
    return foodCategory;
  }

  Future<void> removeFoodCategory(FoodCategory foodCategory) async {
    if (state.where((element) => element.id == foodCategory.id).isEmpty) return;
    state = state.where((element) => element != foodCategory).toSet();
    await FoodCategoryAPI.delete(foodCategory);
  }

  void setFoodCategories(Set<FoodCategory> foodCategories) => state = foodCategories;

  Future<void> updateFoodCategory(FoodCategory foodCategory) async {
    if (state.where((element) => element.id == foodCategory.id).isEmpty) return;
    state = state.map((m) => m.id == foodCategory.id ? foodCategory : m).toSet();
    await FoodCategoryAPI.update(foodCategory);
  }
}

class FoodCategoryManager {
  static final provider = StateNotifierProvider<FoodCategoryModelState, Set<FoodCategory>>((ref) {
    return FoodCategoryModelState();
  });
}
