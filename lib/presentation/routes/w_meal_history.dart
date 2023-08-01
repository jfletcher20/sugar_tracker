import 'package:sugar_tracker/presentation/widgets/meal/w_meals_data.dart';
import 'package:sugar_tracker/presentation/widgets/food/w_dgv_foods.dart';
import 'package:sugar_tracker/data/api/u_api_meal.dart';
import 'package:sugar_tracker/data/models/m_meal.dart';

import 'package:flutter/material.dart';

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
          meals.sort((a, b) => a.sugarLevel.date!.compareTo(b.sugarLevel.date!));
          return SizedBox(
            height: maxSize.height,
            width: maxSize.width,
            child: Column(
              children: [
                for (int i = 0; i < meals.length; i++)
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    borderOnForeground: true,
                    child: Stack(
                      children: [
                        Row(children: [
                          FoodsGridView(foods: meals[i].food, scrollDirection: Axis.horizontal),
                          MealDataWidget(meal: meals[i]),
                        ]),
                        category(meals[i].category),
                      ],
                    ),
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

  Widget category(MealCategory category) {
    return Positioned(
      right: 0,
      child: Container(
        width: 8,
        height: 60,
        decoration: BoxDecoration(
          color: mealCategoryColor(category),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
          ),
        ),
      ),
    );
  }
}
