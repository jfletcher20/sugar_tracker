import 'package:flutter/material.dart';
import 'package:sugar_tracker/data/api/u_api_food.dart';
import 'package:sugar_tracker/data/models/m_food.dart';
import 'package:sugar_tracker/data/models/m_food_category.dart';
import 'package:sugar_tracker/presentation/widgets/food/w_food_card.dart';
import 'package:sugar_tracker/presentation/widgets/food_category/w_dgv_food_category.dart';

class FoodListWidget extends StatefulWidget {
  const FoodListWidget({super.key});

  @override
  State<FoodListWidget> createState() => _FoodListWidgetState();
}

class _FoodListWidgetState extends State<FoodListWidget> {
  final GlobalKey<FoodCategoryGridViewState> foodCategoryKey = GlobalKey();
  bool loadCategories = true;
  List<Food> foods = [];

  void initFoods(List<Food> foods) {
    if (loadCategories) {
      this.foods = foods;
      foods.sort((a, b) => a.name.compareTo(b.name));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [_foodCategoryFilter(), _foodListBuilder()],
    );
  }

  FutureBuilder _foodListBuilder() {
    return FutureBuilder(
      builder: (builder, snapshot) {
        if (snapshot.hasData) {
          initFoods(snapshot.data as List<Food>);
          return _foodList();
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
      future: FoodAPI.selectAll(),
    );
  }

  Widget _foodList() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(children: foods.map((e) => foodCard(context, e)).toList()),
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
            FoodCategoryGridViewState foodCategoryGridViewState = foodCategoryKey.currentState!;
            List<FoodCategory> fc = foodCategoryGridViewState.allSelected;
            if (fc.isEmpty) {
              if (context.mounted) {
                setState(() => loadCategories = true);
              }
              initFoods(await FoodAPI.selectAll());
            } else {
              loadCategories = true;
              initFoods(await FoodAPI.selectAll());
              loadCategories = false;
              foods.retainWhere((food) => fc.any((c) => c.id == food.foodCategory.id));
              if (context.mounted) {
                setState(() => loadCategories = false);
              }
            }
          },
        ),
      ),
    );
  }

  Widget foodCard(BuildContext context, Food food) {
    return FractionallySizedBox(
      widthFactor: 1,
      child: FoodCard(
        food: food,
        modifiable: false,
        showAmount: false,
        columns: const {0, 2},
        showAdditionalOptions: true,
      ),
    );
  }
}
