import 'package:flutter/material.dart';
import 'package:sugar_tracker/data/models/m_food.dart';
import 'package:sugar_tracker/presentation/widgets/food/w_food_count.dart';

class FoodCard extends StatelessWidget {
  final Food food;
  final Set<int> columns;
  const FoodCard({super.key, required this.food, this.columns = const {0, 1, 2}});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.redAccent.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    food.name ?? "Unknown",
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  FoodCountWidget(food: food),
                ],
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  data(food),
                  const SizedBox(height: 8),
                  if (food.notes != null) notes(food.notes, context),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget notes(String? notes, BuildContext context) {
    return Positioned(
      bottom: 0,
      right: 0,
      child: Text(
        "${food.notes}",
        style: const TextStyle(
          fontSize: 12,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  DataTable data(Food food) {
    List<DataColumn> columns = const <DataColumn>[
      DataColumn(label: Center(child: Text("Carbs"))),
      DataColumn(label: Center(child: Text("Average weight"))),
      DataColumn(label: Center(child: Text("Category"))),
    ];
    List<DataCell> cells = [
      DataCell(Center(child: Text("${(food.carbs! * food.amount).round()}g"))),
      DataCell(Center(child: Text("${(food.weight! * food.amount).round()}g"))),
      DataCell(Center(child: Text("${food.category}"))),
    ];
    return DataTable(
      horizontalMargin: 10,
      columnSpacing: 25,
      showBottomBorder: true,
      columns: this.columns.map((e) => columns[e]).toList(),
      rows: [DataRow(cells: this.columns.map((e) => cells[e]).toList())],
    );
  }
}
