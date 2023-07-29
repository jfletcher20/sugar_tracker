import 'package:flutter/material.dart';
import 'package:sugar_tracker/data/models/m_food.dart';

class FoodCard extends StatelessWidget {
  final Food food;
  const FoodCard({super.key, required this.food});

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
                  imageWithCounter(food),
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

  Widget imageWithCounter(Food food) {
    return Stack(
      children: [
        img(),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.redAccent,
            ),
            padding: const EdgeInsets.all(4),
            child: Text(
              "${food.amount}",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ),
      ],
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
    return DataTable(
      horizontalMargin: 10,
      columnSpacing: 25,
      showBottomBorder: true,
      columns: const [
        DataColumn(label: Center(child: Text("Carbs"))),
        DataColumn(label: Center(child: Text("Average weight"))),
        DataColumn(label: Center(child: Text("Category"))),
      ],
      rows: [
        DataRow(cells: [
          DataCell(Center(child: Text("${food.carbs}g"))),
          DataCell(Center(child: Text("${food.weight}g"))),
          DataCell(Center(child: Text("${food.category}"))),
        ]),
      ],
    );
  }

  Widget img() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.redAccent),
        color: Colors.white,
      ),
      padding: const EdgeInsets.all(4),
      child: SizedBox(
        height: 64 - 8,
        width: 64 - 8,
        child: Center(
          child: Stack(
            fit: StackFit.expand,
            children: [image(food)],
          ),
        ),
      ),
    );
  }

  Image image(Food food) {
    return Image.asset(
      height: 48,
      width: 48,
      food.picture ?? "assets/images/food/unknown.png",
      color: food.picture == null ? Colors.greenAccent : null,
      errorBuilder: imageNotFound,
    );
  }

  Widget imageNotFound(BuildContext context, Object error, StackTrace? stackTrace) {
    return Image.asset(
      "assets/images/food/unknown.png",
      color: Colors.redAccent,
      height: 48,
      width: 48,
    );
  }
}
