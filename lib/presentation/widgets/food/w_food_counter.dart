import 'package:flutter/material.dart';
import 'package:sugar_tracker/data/models/m_food.dart';
import 'package:sugar_tracker/presentation/widgets/food/w_food_card.dart';

class FoodCounterWidget extends StatelessWidget {
  final Food food;
  final bool modifiable;
  final void Function(dynamic)? onCreate, onDelete;

  const FoodCounterWidget({
    super.key,
    required this.food,
    this.modifiable = false,
    this.onCreate,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          FoodCard(
            food: food,
            columns: const {2, 0, 1},
            modifiable: modifiable,
            showAdditionalOptions: true,
            onCreate: onCreate,
            onDelete: onDelete,
          ),
        ],
      ),
    );
  }

  ElevatedButton button(IconData icon, Color color, Function() onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: const CircleBorder(),
        fixedSize: const Size(20, 20),
        minimumSize: const Size(48, 48),
      ),
      onPressed: onPressed,
      child: Icon(icon, color: Colors.white),
    );
  }
}
