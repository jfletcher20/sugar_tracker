import 'dart:io';

import 'package:sugar_tracker/data/models/m_food.dart';
import 'package:sugar_tracker/data/dialogs/u_details_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:sugar_tracker/presentation/widgets/food/w_bouncing_carousel.dart';
import 'package:sugar_tracker/presentation/widgets/food/w_food_count.dart';

class FoodListView extends StatelessWidget {
  final List<Food> foods;
  final int crossAxisCount;
  final Axis scrollDirection;
  final bool showCounter, dynamicScale, carousel;
  final double borderRadius;
  const FoodListView({
    super.key,
    required this.foods,
    this.crossAxisCount = 1,
    this.scrollDirection = Axis.vertical,
    this.showCounter = false,
    this.dynamicScale = false,
    this.borderRadius = 16.0,
    this.carousel = false,
  });

  double get _maxWidth => !dynamicScale ? 300 : double.maxFinite;

  @override
  Widget build(BuildContext context) {
    if (carousel) return BouncingCarousel(foods);
    if (foods.isEmpty) {
      return SizedBox(
        width: _maxWidth,
        height: (_maxWidth / crossAxisCount).floorToDouble(),
        child: const Center(child: Text("No foods selected")),
      );
    }
    if (crossAxisCount <= 1) {
      return wrapper(child: grid(context));
    } else {
      return SizedBox(
        width: _maxWidth,
        height: (_maxWidth / crossAxisCount).floorToDouble(),
        child: grid(context),
      );
    }
  }

  Card wrapper({required Widget child}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
      child: SizedBox(
        width: 40,
        height: 40,
        child: child,
      ),
    );
  }

  GridView grid(BuildContext context) {
    return GridView(
      scrollDirection: scrollDirection,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      children: foods.map((food) {
        return InkWell(
          onTap: () => DetailsDialogs.mealDetails(context, foods, withHandle: !showCounter),
          child: !showCounter
              ? FoodCountWidget(food: food, autoSize: true, modifiable: false, showAmount: false)
              : FoodCountWidget(food: food, autoSize: true),
        );
      }).toList(),
    );
  }

  Widget unknownPicture(BuildContext context, Object error, StackTrace? stackTrace) {
    return Image.asset(
      "assets/images/food/unknown.png",
      color: Colors.redAccent,
    );
  }

  Widget label(Food food) {
    String index = (foods.indexOf(food) + 1).toString();
    if (foods.length > 1) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: Text(
          "$index/${foods.length}",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  Image image(Food food) {
    final picture = food.picture;
    final color = food.picture == "" ? Colors.greenAccent : null;
    if (food.picture.contains("asset"))
      return Image.asset(picture, fit: BoxFit.fill, color: color, errorBuilder: unknownPicture);
    return Image.file(File(picture), fit: BoxFit.fill, color: color, errorBuilder: unknownPicture);
  }
}
