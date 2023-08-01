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
          meals.sort((a, b) => a.sugarLevel.datetime!.compareTo(b.sugarLevel.datetime!));
          return SizedBox(
            height: maxSize.height,
            width: maxSize.width,
            child: Column(
              children: [
                for (int i = 0; i < meals.length; i++) mealCard(context, meals[i]),
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

  Card mealCard(BuildContext context, Meal meal) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      borderOnForeground: true,
      child: Stack(
        children: [
          category(meal.category),
          Row(children: [
            FoodsGridView(foods: meal.food, scrollDirection: Axis.horizontal),
            MealDataWidget(meal: meal),
          ]),
        ],
      ),
    );
  }

  Widget category(MealCategory category) {
    return Positioned(
      right: 0,
      child: InkWell(
        child: categoryStrip(category),
        onTap: () {
          showModalBottomSheet(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
            ),
            showDragHandle: true,
            context: context,
            builder: (context) => SizedBox(
              height: 64 + 16,
              child: GridView(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  childAspectRatio: 2,
                ),
                children: [
                  IconButton(
                    icon: const Icon(Icons.food_bank),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget categoryStrip(MealCategory category) {
    return Container(
      width: 8,
      height: 60,
      decoration: BoxDecoration(
        color: mealCategoryColor(category),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(16),
          bottomLeft: Radius.circular(16),
        ),
      ),
    );
  }
}
