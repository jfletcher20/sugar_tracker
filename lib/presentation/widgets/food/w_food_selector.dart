import 'package:flutter/material.dart';
import 'package:sugar_tracker/data/api/u_api_food.dart';
import 'package:sugar_tracker/data/models/m_food.dart';
import 'package:sugar_tracker/presentation/widgets/food/w_food_counter.dart';

class FoodSelectorWidget extends StatefulWidget {
  const FoodSelectorWidget({super.key});

  @override
  State<FoodSelectorWidget> createState() => _FoodSelectorWidgetState();
}

class _FoodSelectorWidgetState extends State<FoodSelectorWidget> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FoodAPI.selectAll(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Food> foods = snapshot.data as List<Food>;
          return ListView.builder(
            itemCount: foods.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return FoodCounterWidget(food: foods[index]);
            },
          );
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return const CircularProgressIndicator();
      },
    );
  }
}
