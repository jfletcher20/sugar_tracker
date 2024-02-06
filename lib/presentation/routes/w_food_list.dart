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

class _FoodListWidgetState extends State<FoodListWidget> with AutomaticKeepAliveClientMixin {
  final GlobalKey<FoodCategoryGridViewState> foodCategoryKey = GlobalKey();
  bool loadFoods = true;
  List<Food> foods = [];

  void initFoods(List<Food> foods) {
    if (loadFoods) {
      this.foods = foods;
      foods.sort((a, b) => a.name.compareTo(b.name));
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              const SizedBox(height: 64 + 12),
              _foodListBuilder(),
            ],
          ),
        ),
        _foodCategoryFilter(),
      ],
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
              loadFoods = true;
              initFoods(await FoodAPI.selectAll());
              setState(() {});
            } else {
              loadFoods = true;
              initFoods(await FoodAPI.selectAll());
              foods.retainWhere((food) => fc.any((c) => c.id == food.foodCategory.id));
              loadFoods = false;
              if (context.mounted) setState(() => {});
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

  @override
  bool get wantKeepAlive => true;
}
