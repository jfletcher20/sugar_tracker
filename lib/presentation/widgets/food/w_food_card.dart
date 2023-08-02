import 'package:sugar_tracker/presentation/widgets/food/w_food_count.dart';
import 'package:sugar_tracker/data/models/m_food.dart';
import 'package:flutter/material.dart';

class FoodCard extends StatelessWidget {
  final Food food;
  final Set<int> columns;
  final bool modifiable;
  const FoodCard({
    super.key,
    required this.food,
    this.columns = const {0, 1, 2},
    this.modifiable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      shadowColor: Colors.grey.shade200,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              prefix(context),
              const SizedBox(width: 16),
              cardData(context),
            ],
          ),
        ),
      ),
    );
  }

  Column prefix(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 64 + 16,
          child: FractionallySizedBox(
            widthFactor: 1.5,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: title(context),
            ),
          ),
        ),
        const SizedBox(height: 16),
        FoodCountWidget(food: food, modifiable: modifiable),
      ],
    );
  }

  Column cardData(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        data(food),
        const SizedBox(height: 8),
        if (food.notes != null) notes(food.notes, context),
      ],
    );
  }

  Text title(BuildContext context) {
    String title = food.name ?? "Unknown";
    int wrap = 12;
    if (title.length > wrap) {
      int i = wrap;
      while (i < title.length) {
        title = title.replaceRange(i, i, "\n");
        i += wrap;
      }
    }
    TextStyle titleLarge = Theme.of(context).textTheme.titleLarge!;
    titleLarge = titleLarge.copyWith(
      fontWeight: FontWeight.w500,
    );
    return Text(
      title,
      style: titleLarge,
    );
  }

  Widget notes(String? notes, BuildContext context) {
    return Text(
      "${food.notes}",
      style: const TextStyle(
        fontSize: 12,
        fontStyle: FontStyle.italic,
      ),
    );
  }

  DataTable data(Food food) {
    List<DataColumn> columns = const <DataColumn>[
      DataColumn(label: Center(child: Text("Carbs"))),
      DataColumn(label: Center(child: Text("Σ Carbs"))),
      DataColumn(label: Center(child: Text("Category"))),
    ];
    List<DataCell> cells = [
      DataCell(Center(child: Text("${(food.carbs).round()}g"))),
      DataCell(Center(child: Text("${((food.carbs / 100) * food.amount).round()}g"))),
      DataCell(Center(child: Text(food.category.name))),
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
