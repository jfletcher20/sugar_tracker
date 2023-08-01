import 'package:flutter/material.dart';
import 'package:sugar_tracker/data/models/m_food.dart';
import 'package:sugar_tracker/presentation/widgets/food/w_food_card.dart';

class FoodCounterWidget extends StatefulWidget {
  final Food food;
  final bool modifiable;
  const FoodCounterWidget({super.key, required this.food, this.modifiable = false});

  @override
  State<FoodCounterWidget> createState() => _FoodCounterWidgetState();
}

class _FoodCounterWidgetState extends State<FoodCounterWidget> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          FoodCard(food: widget.food, columns: const {2, 0, 1}, modifiable: widget.modifiable),
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
