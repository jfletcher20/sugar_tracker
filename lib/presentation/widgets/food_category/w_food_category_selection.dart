// ignore_for_file: curly_braces_in_flow_control_structures
import 'package:sugar_tracker/presentation/widgets/food_category/w_food_category_selector.dart';
import 'package:sugar_tracker/data/riverpod.dart/u_provider_food_category.dart';
import 'package:sugar_tracker/data/models/m_food_category.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

class FoodCategorySelection extends ConsumerStatefulWidget {
  final List<FoodCategory>? foodCategories;
  final FoodCategory? initialCategory;
  final Color? color;
  final Function(FoodCategory)? onSelect;
  final double imgSize;
  final int? maxPerRow;
  const FoodCategorySelection({
    super.key,
    this.imgSize = 64,
    this.color,
    this.initialCategory,
    this.foodCategories,
    this.onSelect,
    this.maxPerRow,
  });

  @override
  ConsumerState<FoodCategorySelection> createState() => FoodCategorySelectionState();
}

class FoodCategorySelectionState extends ConsumerState<FoodCategorySelection> {
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
    return SizedBox(
      width: widget.imgSize * 3,
      child: FutureBuilder(
        future: getFoodCategories(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            foodCategories = snapshot.data as List<FoodCategory>;
            initCategories();
          }
          return gridView;
        },
      ),
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
    return widget.foodCategories ?? ref.watch(FoodCategoryManager.provider).toList();
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
      return Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.center,
        runAlignment: WrapAlignment.center,
        // runSpacing: 20,
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
        setState(() {
          for (var element in _categoryCards) {
            var k = (element.key as GlobalKey<FoodCategorySelectorWidgetState>);
            if (element.foodCategory != category) k.currentState!.setSelected(false);
          }
          selected = !selected;
        });
      },
    );
  }
}
