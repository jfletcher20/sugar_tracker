import 'package:sugar_tracker/presentation/widgets/food_category/w_dgv_food_category.dart';
import 'package:sugar_tracker/presentation/widgets/food/w_food_card.dart';
import 'package:sugar_tracker/data/riverpod.dart/u_provider_food.dart';
import 'package:sugar_tracker/data/models/m_food_category.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sugar_tracker/data/models/m_food.dart';

import 'package:flutter/material.dart';

class FoodListWidget extends ConsumerStatefulWidget {
  final bool withCarbCalc;
  const FoodListWidget({super.key, this.withCarbCalc = true});

  static FoodListWidgetState? of(BuildContext context) =>
      context.findAncestorStateOfType<FoodListWidgetState>();

  @override
  ConsumerState<FoodListWidget> createState() => FoodListWidgetState();
}

class FoodListWidgetState extends ConsumerState<FoodListWidget> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final GlobalKey<FoodCategoryGridViewState> foodCategoryKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    ref.listen(FoodManager.provider.notifier, (_, __) => setState(() {}));
    return Stack(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              const SizedBox(height: 48 + 12),
              SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: ref
                      .watch(FoodManager.provider.notifier)
                      .getFilteredFoods(fc)
                      .map((foodItem) => foodCard(context, foodItem))
                      .toList(),
                ),
              )
            ],
          ),
        ),
        _foodCategoryFilter(),
      ],
    );
  }

  List<FoodCategory> get fc {
    FoodCategoryGridViewState? foodCategoryGridViewState = foodCategoryKey.currentState;
    return foodCategoryGridViewState?.allSelected ?? [];
  }

  Widget _foodCategoryFilter() {
    return Card(
      color: Colors.black.withValues(alpha: 0.8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: FoodCategoryGridView(
          key: foodCategoryKey,
          multiSelect: true,
          crossAxisCount: 8,
          crossAxisSpacing: 0,
          mainAxisSpacing: 0,
          onSelect: (category) {
            setState(() {});
            return null;
          },
        ),
      ),
    );
  }

  Widget foodCard(BuildContext context, Food food) {
    return FractionallySizedBox(
      widthFactor: 1,
      child: FoodCard(
        food: food.copyWith(amount: widget.withCarbCalc ? food.amount : 0),
        modifiable: false,
        showAmount: false,
        columns: const {0},
        showAdditionalOptions: true,
        onCreate: refresh,
        onDelete: refresh,
      ),
    );
  }

  void refresh(_) => setState(() {});
}
