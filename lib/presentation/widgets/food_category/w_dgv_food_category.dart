import 'package:flutter/material.dart';
import 'package:sugar_tracker/data/models/m_food_category.dart';
import 'package:sugar_tracker/presentation/widgets/food_category/w_food_category.dart';

class FoodCategoryGridView extends StatefulWidget {
  final List<FoodCategory> foodCategories;
  final FoodCategory? initialCategory;
  final int crossAxisCount;
  final double imgSize;
  const FoodCategoryGridView({
    super.key,
    required this.foodCategories,
    this.crossAxisCount = 4,
    this.imgSize = 64,
    this.initialCategory,
  });

  @override
  State<FoodCategoryGridView> createState() => FoodCategoryGridViewState();
}

class FoodCategoryGridViewState extends State<FoodCategoryGridView> {
  List<FoodCategorySelectorWidget> _categoryCards = List.empty(growable: true);

  FoodCategory get selected {
    for (var element in _categoryCards) {
      var k = (element.key as GlobalKey<FoodCategorySelectorWidgetState>);
      if (k.currentState!.selected) {
        return element.foodCategory;
      }
    }
    return FoodCategory(name: "Unknown");
  }

  @override
  Widget build(BuildContext context) {
    if (_categoryCards.isEmpty) {
      _categoryCards = widget.foodCategories.map((e) => _categoryCard(e)).toList();
    }
    return GridView(
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.crossAxisCount,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      children: _categoryCards,
    );
  }

  FoodCategorySelectorWidget _categoryCard(FoodCategory category) {
    bool selected = category.id == widget.initialCategory?.id;
    return FoodCategorySelectorWidget(
      key: GlobalKey<FoodCategorySelectorWidgetState>(),
      foodCategory: category,
      imgSize: widget.imgSize,
      selectable: true,
      initializeSelected: selected,
      onTap: () {
        setState(() {
          for (var element in _categoryCards) {
            var k = (element.key as GlobalKey<FoodCategorySelectorWidgetState>);
            if (element.foodCategory != category) {
              k.currentState!.setSelected(false);
            }
          }
        });
      },
    );
  }
}
