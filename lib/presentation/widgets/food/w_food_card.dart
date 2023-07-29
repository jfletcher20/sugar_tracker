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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            img(),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food.name ?? "Unknown",
                  style:
                      Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  "Carbs per 100g: ${food.carbs}g\n"
                  "Expected weight: ${food.weight}g",
                ),
                const SizedBox(height: 8),
                if (food.notes != null)
                  Text(
                    "${food.notes}",
                    style: const TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget img() {
    return SizedBox(
      height: 64 - 8,
      width: 64 - 8,
      child: Center(
        child: Stack(
          fit: StackFit.expand,
          children: [image(food)],
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
