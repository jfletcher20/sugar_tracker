import 'package:sugar_tracker/data/models/m_food.dart';
import 'package:flutter/material.dart';

import '../../presentation/widgets/food/w_food_card.dart';

class DetailsDialogs {
  static void mealDetails(BuildContext context, List<Food> foods) async {
    await showModalBottomSheet(
      showDragHandle: true,
      context: context,
      builder: (context) => ListView(
        children: [
          for (int i = 0; i < foods.length; i++) FoodCard(food: foods[i]),
        ],
      ),
    );
  }

  static void foodDetails(BuildContext context, Food food) async {
    await showModalBottomSheet(
      showDragHandle: true,
      context: context,
      builder: (context) => ListView(
        children: [
          Stack(
            alignment: Alignment.centerRight,
            children: [
              SizedBox(width: MediaQuery.of(context).size.width, child: FoodCard(food: food)),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.greenAccent),
                  ),
                  onPressed: () {},
                  child: const Icon(Icons.create, size: 32),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
