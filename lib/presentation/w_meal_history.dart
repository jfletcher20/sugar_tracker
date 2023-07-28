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
          Map<int, List<Meal>> mealsBySugarId = {};
          for (Meal meal in meals) {
            if (mealsBySugarId.containsKey(meal.sugar!.id)) {
              mealsBySugarId[meal.sugar!.id]!.add(meal);
            } else {
              mealsBySugarId[meal.sugar!.id!] = [meal];
            }
          }
          return DataTable(
            columns: const [
              DataColumn(label: Text("Meal")),
              DataColumn(label: Text("Sugar level")),
              DataColumn(label: Text("Insulin give")),
              DataColumn(label: Text("Total carbs")),
            ],
            rows: mealsBySugarId
                .map((key, value) {
                  return MapEntry(
                    key,
                    DataRow(
                      cells: [
                        DataCell(Text(value.map((e) => e.food!.name).join(", "))),
                        DataCell(Text(key.toString())),
                        DataCell(Text(value.map((e) => e.food!.id.toString()).join(", "))),
                      ],
                    ),
                  );
                })
                .values
                .toList(),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
      future: MealAPI.selectAll(),
    );
  }
}
