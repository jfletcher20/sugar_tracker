import 'package:flutter/material.dart';
import 'package:sugar_tracker/data/api/u_api_food.dart';
import 'package:sugar_tracker/data/models/m_food.dart';
import 'package:sugar_tracker/presentation/widgets/food/w_food_card.dart';

class FoodListWidget extends StatefulWidget {
  const FoodListWidget({super.key});

  @override
  State<FoodListWidget> createState() => _FoodListWidgetState();
}

class _FoodListWidgetState extends State<FoodListWidget> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: (builder, snapshot) {
        if (snapshot.hasData) {
          List<Food> foods = snapshot.data as List<Food>;
          foods.sort((a, b) => a.name!.compareTo(b.name!));
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: foods.map((e) => foodCard(context, e)).toList(),
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
      future: FoodAPI.selectAll(),
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
