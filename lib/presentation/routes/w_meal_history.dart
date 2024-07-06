import 'package:sugar_tracker/presentation/widgets/meal/w_meal_card.dart';
import 'package:sugar_tracker/data/riverpod.dart/u_provider_meal.dart';
import 'package:sugar_tracker/data/models/m_meal.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

class MealHistoryWidget extends ConsumerStatefulWidget {
  const MealHistoryWidget({super.key});
  @override
  ConsumerState<MealHistoryWidget> createState() => _MealHistoryWidgetState();
}

class _MealHistoryWidgetState extends ConsumerState<MealHistoryWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    List<Meal> meals = ref.watch(MealManager.provider).toList();
    meals = meals.where((element) => element.sugarLevel.datetime != null).toList();
    meals.sort((a, b) => a.sugarLevel.datetime!.compareTo(b.sugarLevel.datetime!));
    meals = meals.reversed.toList();
    return Scrollbar(
      controller: _scrollController,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3.0),
        child: ListView(
          controller: _scrollController,
          children: meals.map((meal) => MealCard(meal: meal)).toList(),
        ),
      ),
    );
  }
}
