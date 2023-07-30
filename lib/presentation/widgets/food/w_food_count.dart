import 'package:flutter/material.dart';
import 'package:sugar_tracker/data/models/m_food.dart';

class FoodCountWidget extends StatelessWidget {
  final Food food;
  const FoodCountWidget({super.key, required this.food});

  @override
  Widget build(BuildContext context) {
    return imageWithCounter(food);
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
      food.picture ?? "assets/images/foods/unknown.png",
      color: food.picture == null ? Colors.greenAccent : null,
      errorBuilder: imageNotFound,
    );
  }

  Widget imageNotFound(BuildContext context, Object error, StackTrace? stackTrace) {
    return Image.asset(
      "assets/images/foods/unknown.png",
      color: Colors.redAccent,
      height: 48,
      width: 48,
    );
  }
}
