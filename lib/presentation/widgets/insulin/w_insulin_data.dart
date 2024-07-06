// ignore_for_file: curly_braces_in_flow_control_structures
import 'package:sugar_tracker/data/riverpod.dart/u_provider_sugar.dart';
import 'package:sugar_tracker/data/riverpod.dart/u_provider_meal.dart';
import 'package:sugar_tracker/data/models/m_insulin.dart';
import 'package:sugar_tracker/data/models/m_sugar.dart';
import 'package:sugar_tracker/data/models/m_meal.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

class InsulinDataWidget extends ConsumerStatefulWidget {
  final Insulin insulin;
  const InsulinDataWidget({super.key, required this.insulin});

  @override
  ConsumerState<InsulinDataWidget> createState() => _InsulinDataWidgetState();
}

class _InsulinDataWidgetState extends ConsumerState<InsulinDataWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        title(context),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_units, _sugarLevel, _carbs],
          ),
        ),
      ],
    );
  }

  Widget get _units {
    return SizedBox(
      width: 30,
      child: Center(
        child: Text(
          widget.insulin.units.toString(),
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  Widget get _sugarLevel {
    Sugar sugar =
        ref.read(SugarManager.provider.notifier).getSugarByDatetime(widget.insulin.datetime!);
    String sugarLevel = sugar.id != -1 ? sugar.level.toString() : "";
    sugar.level == 0 ? sugarLevel = "" : null;
    bool cond = sugar.notes.toLowerCase().contains("libre");
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

    return SizedBox(
      width: 60,
      child: Center(
        child: InkWell(
          onTap: sugar.notes == "" ? null : () => showNotesDialog("Sugar level notes", sugar.notes),
          child: Text(
            sugarLevel,
            style: TextStyle(
              fontSize: 18,
              decoration: sugar.notes == "" ? null : TextDecoration.underline,
              decorationColor: cond ? Colors.redAccent[400]! : null,
              decorationThickness: cond ? 2 : 1,
              decorationStyle: cond ? TextDecorationStyle.wavy : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget get _carbs {
    Meal meal = ref.read(MealManager.provider.notifier).getMealByInsulinId(widget.insulin);
    return SizedBox(
      width: 60,
      child: Center(
        child: Text(
          meal.carbsDisplay,
          style: TextStyle(
            color: meal.id == -1 ? Colors.white : meal.category.color,
          ),
        ),
      ),
    );
  }

  Widget title(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      width: 180,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(bottomRight: Radius.circular(32)),
        gradient: _gradient(context),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: titleText(context),
        ),
      ),
    );
  }

  LinearGradient _gradient(BuildContext context) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Colors.black, widget.insulin.category.color],
    );
  }

  RichText titleText(BuildContext context) {
    // return time and category
    return RichText(
      text: TextSpan(
        children: [
          time(context),
          const TextSpan(text: " "),
          date(context),
        ],
      ),
    );
  }

  TextSpan date(BuildContext context) {
    return TextSpan(
      text: widget.insulin.date,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
    );
  }

  TextSpan time(BuildContext context) {
    return TextSpan(
      text: widget.insulin.time,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(color: widget.insulin.category.color),
    );
  }
}
