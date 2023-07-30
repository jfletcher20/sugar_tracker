import 'package:flutter/material.dart';
import 'package:sugar_tracker/data/models/m_meal.dart';

class MealDataWidget extends StatelessWidget {
  final Meal meal;
  const MealDataWidget({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        title(context),
        data(context),
      ],
    );
  }

  Text title(BuildContext context) {
    return Text(
      meal.notes.toString().toUpperCase(),
      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Row data(BuildContext context) {
    return Row(
      children: [
        wrapper(context, sugarAndInsulin()),
        const SizedBox(width: 16),
        wrapper(context, carbsAndDate()),
      ],
    );
  }

  RichText wrapper(BuildContext context, List<TextSpan> children) {
    TextStyle? s = Theme.of(context).textTheme.titleMedium?.copyWith(height: 1.25);
    return RichText(text: TextSpan(style: s, children: children));
  }

  List<TextSpan> sugarAndInsulin() {
    return [
      const TextSpan(text: "Sugar level: "),
      TextSpan(text: meal.sugar.toString()),
      const TextSpan(text: "\n"),
      const TextSpan(text: "Insulin taken: "),
      TextSpan(text: meal.insulin.toString()),
    ];
  }

  List<TextSpan> carbsAndDate() {
    return [
      const TextSpan(text: "Carbs: "),
      TextSpan(text: meal.carbs.round().toString()),
      const TextSpan(text: "\n"),
      TextSpan(text: meal.date),
    ];
  }
}
