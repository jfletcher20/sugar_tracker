import 'package:flutter/material.dart';
import 'package:sugar_tracker/data/api/u_api_meal.dart';
import 'package:sugar_tracker/data/api/u_api_sugar.dart';
import 'package:sugar_tracker/data/models/m_insulin.dart';
import 'package:sugar_tracker/data/models/m_meal.dart';
import 'package:sugar_tracker/data/models/m_sugar.dart';

class InsulinDataWidget extends StatefulWidget {
  final Insulin insulin;
  const InsulinDataWidget({super.key, required this.insulin});

  @override
  State<InsulinDataWidget> createState() => _InsulinDataWidgetState();
}

class _InsulinDataWidgetState extends State<InsulinDataWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        title(context),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_units(), _sugarLevel(), _carbs()],
          ),
        ),
      ],
    );
  }

  Widget _units() {
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

  Widget _sugarLevel() {
    return SizedBox(
      width: 60,
      child: Center(
        child: FutureBuilder(
          future: SugarAPI.selectAll(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<Sugar> sugarLevels = snapshot.data as List<Sugar>;
              Sugar sugar = sugarLevels.firstWhere(
                (element) => element.datetime == widget.insulin.datetime,
                orElse: () => Sugar(),
              );
              String sugarLevel = sugar.id != -1 ? sugar.level.toString() : "";
              sugar.level == 0 ? sugarLevel = "" : null;
              return Text(sugarLevel);
            } else {
              return const Text("");
            }
          },
        ),
      ),
    );
  }

  Widget _carbs() {
    return SizedBox(
      width: 60,
      child: Center(
        child: FutureBuilder(
          future: MealAPI.selectByInsulinId(widget.insulin),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              Meal meal = snapshot.data as Meal;
              String carbs = meal.id != -1 ? "${meal.carbs.round()}g" : "";
              return FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  carbs,
                  style: TextStyle(
                    color: meal.id == -1 ? Colors.white : mealCategoryColor(meal.category),
                  ),
                ),
              );
            } else {
              return const Text("");
            }
          },
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
      colors: [Colors.black, insulinCategoryColor(widget.insulin.category)],
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
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: insulinCategoryColor(
              widget.insulin.category,
            ),
          ),
    );
  }
}
