import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sugar_tracker/data/models/m_insulin.dart';
import 'package:sugar_tracker/data/models/m_sugar.dart';
import 'package:sugar_tracker/data/models/m_meal.dart';

import 'package:flutter/material.dart';
import 'package:sugar_tracker/data/riverpod.dart/u_provider_insulin.dart';
import 'package:sugar_tracker/data/riverpod.dart/u_provider_meal.dart';

class SugarDataWidget extends ConsumerStatefulWidget {
  final Sugar sugar;
  const SugarDataWidget({super.key, required this.sugar});

  @override
  ConsumerState<SugarDataWidget> createState() => _SugarDataWidgetState();
}

class _SugarDataWidgetState extends ConsumerState<SugarDataWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        title(context),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_sugarLevel(), _insulin(), _carbs()],
          ),
        ),
      ],
    );
  }

  Widget _sugarLevel() {
    bool cond = widget.sugar.notes.toLowerCase().contains("libre");
    return SizedBox(
      width: 60,
      child: Center(
        child: InkWell(
          onTap: widget.sugar.notes == ""
              ? null
              : () => showNotesDialog("Sugar level notes", widget.sugar.notes),
          child: Text(
            widget.sugar.level.toString(),
            style: TextStyle(
              fontSize: 18,
              decoration: widget.sugar.notes == "" ? null : TextDecoration.underline,
              decorationColor: cond ? Colors.redAccent[400]! : null,
              decorationThickness: cond ? 2 : 1,
              decorationStyle: cond ? TextDecorationStyle.wavy : null,
            ),
          ),
        ),
      ),
    );
  }

  void showNotesDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Widget _insulin() {
    Insulin insulin =
        ref.read(InsulinManager.provider.notifier).getInsulinByDatetime(widget.sugar.datetime!);
    return SizedBox(width: 30, child: Center(child: Text(insulin.unitsDisplay)));
  }

  Widget _carbs() {
    Meal meal = ref.read(MealManager.provider.notifier).getMealBySugarId(widget.sugar);
    return SizedBox(
      width: 60,
      child: Center(
        child: Text(
          meal.carbsDisplay,
          style: TextStyle(
            color: meal.id == -1 ? Colors.white : mealCategoryColor(meal.category),
          ),
        ),
      ),
    );
  }

  Widget title(BuildContext context) {
    return FutureBuilder(
      future: () async {
        Set<Insulin> insulins = ref.read(InsulinManager.provider);
        Insulin insulin = insulins.firstWhere(
          (element) => element.datetime == widget.sugar.datetime,
          orElse: () => Insulin(),
        );
        return insulin.id == -1 ? null : insulin.category;
      }(),
      builder: (context, snapshot) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          width: 180,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(bottomRight: Radius.circular(32)),
            gradient: _gradient(snapshot.data),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: titleText(context, snapshot.data),
            ),
          ),
        );
      },
      initialData: null,
    );
  }

  LinearGradient _gradient(InsulinCategory? category) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.black,
        category != null ? insulinCategoryColor(category) : Colors.redAccent[400]!
      ],
    );
  }

  RichText titleText(BuildContext context, InsulinCategory? category) {
    // return time and category
    return RichText(
      text: TextSpan(
        children: [
          time(context, category),
          const TextSpan(text: "  "),
          date(context),
        ],
      ),
    );
  }

  TextSpan date(BuildContext context) {
    return TextSpan(
      text: widget.sugar.date,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
    );
  }

  TextSpan time(BuildContext context, InsulinCategory? category) {
    return TextSpan(
      text: widget.sugar.time,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: _gradient(category).colors.last,
          ),
    );
  }
}
