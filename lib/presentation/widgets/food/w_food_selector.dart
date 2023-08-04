import 'package:flutter/material.dart';
import 'package:sugar_tracker/data/api/u_api_food.dart';
import 'package:sugar_tracker/data/models/m_food.dart';
import 'package:sugar_tracker/data/models/m_meal.dart';
import 'package:sugar_tracker/presentation/widgets/food/w_food_counter.dart';

class FoodSelectorWidget extends StatefulWidget {
  final Meal meal;
  const FoodSelectorWidget({super.key, required this.meal});

  @override
  State<FoodSelectorWidget> createState() => _FoodSelectorWidgetState();
}

class _FoodSelectorWidgetState extends State<FoodSelectorWidget> {
  @override
  Widget build(BuildContext context) {
    Widget child;
    if (widget.meal.food.isNotEmpty) {
      child = listView();
    } else {
      child = FutureBuilder(
        future: FoodAPI.selectAll(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            widget.meal.food = snapshot.data as List<Food>;
            return listView();
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          return const CircularProgressIndicator();
        },
      );
    }
    return WillPopScope(
      child: child,
      onWillPop: () {
        Navigator.pop(context, widget.meal.food);
        return Future.value(false);
      },
    );
  }

  ListView listView() {
    widget.meal.food.sort((a, b) => a.name.compareTo(b.name));
    widget.meal.food.sort((a, b) => a.foodCategory.name.compareTo(b.foodCategory.name));
    List<Food> selected = [];
    List<Food> unselected = [];
    for (int i = 0; i < widget.meal.food.length; i++) {
      if (widget.meal.food[i].amount > 0) {
        selected.add(widget.meal.food[i]);
      } else {
        unselected.add(widget.meal.food[i]);
      }
    }
    selected.sort((a, b) => b.amount.compareTo(a.amount));
    selected.sort((a, b) => a.name.compareTo(b.name));
    selected.sort((a, b) => a.foodCategory.name.compareTo(b.foodCategory.name));
    widget.meal.food = selected + unselected;
    return ListView.builder(
      itemCount: widget.meal.food.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return FoodCounterWidget(food: widget.meal.food[index], modifiable: true);
      },
    );
  }
}
