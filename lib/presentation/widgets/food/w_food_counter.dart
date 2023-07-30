import 'package:flutter/material.dart';
import 'package:sugar_tracker/data/models/m_food.dart';
import 'package:sugar_tracker/presentation/widgets/food/w_food_card.dart';

class FoodCounterWidget extends StatefulWidget {
  final Food food;
  const FoodCounterWidget({super.key, required this.food});

  @override
  State<FoodCounterWidget> createState() => _FoodCounterWidgetState();
}

class _FoodCounterWidgetState extends State<FoodCounterWidget> {
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
              FoodCard(
                food: widget.food,
                columns: const {2, 0},
              ),
              SizedBox(
                width: 60,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    button(
                      Icons.arrow_upward,
                      Colors.blue,
                      () => setState(() => widget.food.amount++),
                    ),
                    const SizedBox(height: 16),
                    button(
                      Icons.arrow_downward,
                      Colors.blue,
                      () => setState(() => widget.food.amount--),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ElevatedButton button(IconData icon, Color color, Function() onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: const CircleBorder(),
        fixedSize: const Size(20, 20),
      ),
      onPressed: onPressed,
      child: Icon(icon, color: Colors.white),
    );
  }
}
