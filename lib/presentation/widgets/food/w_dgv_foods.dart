import 'package:sugar_tracker/data/models/m_food.dart';
import 'package:sugar_tracker/presentation/widgets/meal/d_meals_details.dart';
import 'package:flutter/material.dart';

class FoodsGridView extends StatelessWidget {
  final List<Food> foods;
  const FoodsGridView({super.key, required this.foods});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      color: Colors.white.withOpacity(0.3),
      child: SizedBox(
        width: 64 + 8,
        height: 64 + 8,
        child: GridView(
          scrollDirection: Axis.horizontal,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
          ),
          children: foods.map((food) {
            return InkWell(
              onTap: () => DetailsDialogs.mealDetails(context, foods),
              child: Card(
                child: Column(children: [img(food)]),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget img(Food food) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.redAccent),
        color: Colors.white,
      ),
      padding: const EdgeInsets.all(4),
      child: SizedBox(
        height: 48 + 4,
        width: 48 + 4,
        child: Center(
          child: Stack(
            fit: StackFit.expand,
            children: [
              image(food),
              label(food),
            ],
          ),
        ),
      ),
    );
  }

  Widget imageNotFound(BuildContext context, Object error, StackTrace? stackTrace) {
    return Image.asset(
      "assets/images/food/unknown.png",
      color: Colors.redAccent,
      height: 32,
      width: 32,
    );
  }

  Widget label(Food food) {
    String index = (foods.indexOf(food) + 1).toString();
    if (foods.length > 1) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: Text("$index/${foods.length}"),
      );
    } else {
      return Container();
    }
  }

  Image image(Food food) {
    return Image.asset(
      height: 32,
      width: 32,
      food.picture ?? "assets/images/food/unknown.png",
      color: food.picture == null ? Colors.greenAccent : null,
      errorBuilder: imageNotFound,
    );
  }
}
