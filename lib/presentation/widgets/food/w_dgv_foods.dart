import 'dart:io';

import 'package:sugar_tracker/data/models/m_food.dart';
import 'package:sugar_tracker/data/dialogs/u_details_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:sugar_tracker/presentation/widgets/food/w_food_count.dart';

class FoodListView extends StatelessWidget {
  final List<Food> foods;
  final int crossAxisCount;
  final Axis scrollDirection;
  final bool showCounter;
  const FoodListView({
    super.key,
    required this.foods,
    this.crossAxisCount = 1,
    this.scrollDirection = Axis.vertical,
    this.showCounter = false,
  });

  final double _maxWidth = 300;

  @override
  Widget build(BuildContext context) {
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      child: SizedBox(
        width: 64 + 8,
        height: 64 + 8,
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
          onTap: () => DetailsDialogs.mealDetails(context, foods),
          child: !showCounter
              ? Card(child: Column(children: [img(food)]))
              : FoodCountWidget(food: food, autoSize: true),
        );
      }).toList(),
    );
  }

  Widget img(Food food) {
    double size = 48 + 4;
    if (crossAxisCount > 1) {
      size = (_maxWidth / crossAxisCount).floorToDouble();
    }
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.redAccent),
      ),
      height: size,
      width: size,
      child: Center(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.redAccent),
              ),
              child: image(food),
            ),
            label(food),
          ],
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
        child: Text(
          "$index/${foods.length}",
          style: /* drop shadow */ const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            shadows: [
              Shadow(
                color: Colors.black,
                offset: Offset(1, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  Image image(Food food) {
    return food.picture.contains("asset")
        ? Image.asset(
            height: 32,
            width: 32,
            food.picture,
            color: food.picture == "" ? Colors.greenAccent : null,
            errorBuilder: imageNotFound,
          )
        : Image.file(
            File(food.picture),
            height: 32,
            width: 32,
            color: food.picture == "" ? Colors.greenAccent : null,
            errorBuilder: imageNotFound,
          );
  }
}
