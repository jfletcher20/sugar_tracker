// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:sugar_tracker/data/api/u_api_food_category.dart';
import 'package:sugar_tracker/data/models/m_food_category.dart';
import 'package:sugar_tracker/presentation/widgets/food_category/w_food_category_selector.dart';

class FoodCategoryGridView extends StatefulWidget {
  final List<FoodCategory>? foodCategories;
  final FoodCategory? initialCategory;
  final bool multiSelect;
  final Color? color;
  final int crossAxisCount;
  final double imgSize, mainAxisSpacing, crossAxisSpacing;
  final Function(FoodCategory)? onSelect;
  const FoodCategoryGridView({
    super.key,
    this.crossAxisCount = 4,
    this.imgSize = 64,
    this.color,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
    this.multiSelect = false,
    this.initialCategory,
    this.foodCategories,
    this.onSelect,
  });

  @override
  State<FoodCategoryGridView> createState() => FoodCategoryGridViewState();
}

class FoodCategoryGridViewState extends State<FoodCategoryGridView> {
  List<FoodCategorySelectorWidget> _categoryCards = List.empty(growable: true);
  List<FoodCategory> foodCategories = [];

  @override
  void initState() {
    super.initState();
    initCategories();
  }

  void initCategories() {
    foodCategories.isEmpty ? foodCategories = widget.foodCategories ?? [] : null;
    if (_categoryCards.isEmpty)
      _categoryCards = foodCategories.map((e) => _categoryCard(e)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getFoodCategories(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          foodCategories = snapshot.data as List<FoodCategory>;
          initCategories();
        }
        return gridView;
      },
    );
  }

  FoodCategory get selected {
    for (var element in _categoryCards) {
      var k = (element.key as GlobalKey<FoodCategorySelectorWidgetState>);
      if (k.currentState!.selected) return element.foodCategory;
    }
    return _categoryCards.first.foodCategory;
  }

  List<FoodCategory> get allSelected {
    List<FoodCategory> selected = [];
    for (var element in _categoryCards) {
      var k = (element.key as GlobalKey<FoodCategorySelectorWidgetState>);
      if (k.currentState!.selected) selected.add(element.foodCategory);
    }
    return selected;
  }

  Future<List<FoodCategory>> getFoodCategories() async {
    return widget.foodCategories ?? await FoodCategoryAPI.selectAll();
  }

  Widget get gridView {
    List<Widget> children = _categoryCards;
    if (children.isEmpty) {
      children = <Widget>[
        Container(
          color: widget.color,
          height: widget.imgSize - 16,
          child: const Center(child: Text("No categories found.")),
        ),
      ];
    }
    if (children.length == 1) {
      return children.first;
    } else {
      return GridView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: widget.crossAxisCount,
          mainAxisSpacing: widget.mainAxisSpacing,
          crossAxisSpacing: widget.crossAxisSpacing,
        ),
        children: children,
      );
    }
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
        widget.onSelect?.call(category);
        if (widget.multiSelect) return;
        setState(() {
          for (var element in _categoryCards) {
            var k = (element.key as GlobalKey<FoodCategorySelectorWidgetState>);
            if (element.foodCategory != category) k.currentState!.setSelected(false);
          }
        });
      },
    );
  }
}
