import 'package:sugar_tracker/data/api/u_api_meal.dart';
import 'package:sugar_tracker/data/models/m_meal.dart';

import 'package:flutter/material.dart';
import 'package:sugar_tracker/presentation/widgets/food/w_dgv_foods.dart';
import 'package:sugar_tracker/presentation/widgets/meal/w_meals_data.dart';

class MealHistoryWidget extends StatefulWidget {
  const MealHistoryWidget({super.key});

  @override
  State<MealHistoryWidget> createState() => _MealHistoryWidgetState();
}

class _MealHistoryWidgetState extends State<MealHistoryWidget> {
  @override
  Widget build(BuildContext context) {
    Size maxSize = MediaQuery.of(context).size;
    return FutureBuilder(
      builder: (builder, snapshot) {
        if (snapshot.hasData) {
          List<Meal> meals = snapshot.data as List<Meal>;
          return SizedBox(
            height: maxSize.height,
            width: maxSize.width,
            child: Column(
              children: [
                for (int i = 0; i < meals.length; i++)
                  Card(
                    child: Row(children: [
                      FoodsGridView(foods: meals[i].food),
                      MealDataWidget(meal: meals[i]),
                    ]),
                  ),
              ],
            ),
          );
        } else {
          return SizedBox(
            height: maxSize.height,
            width: maxSize.width,
            child: const Center(child: CircularProgressIndicator()),
          );
        }
      },
      future: MealAPI.selectAll(),
    );
  }
}
