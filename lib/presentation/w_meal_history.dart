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
    return FutureBuilder(
      builder: (builder, snapshot) {
        if (snapshot.hasData) {
          List<Meal> meals = snapshot.data as List<Meal>;
          return Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: ListView(
              children: [
                for (int i = 0; i < meals.length; i++)
                  ListTile(
                    title: Text(meals[i].food.map((e) => e.name).join(", ")),
                    subtitle: Text(meals[i].sugar?.sugar.toString() ?? "Unknown"),
                  ),
              ],
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
      future: MealAPI.selectAll(),
    );
  }
}
