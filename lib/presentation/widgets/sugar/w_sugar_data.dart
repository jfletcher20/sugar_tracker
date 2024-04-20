import 'package:flutter/material.dart';
import 'package:sugar_tracker/data/api/u_api_insulin.dart';
import 'package:sugar_tracker/data/api/u_api_meal.dart';
import 'package:sugar_tracker/data/models/m_insulin.dart';
import 'package:sugar_tracker/data/models/m_meal.dart';
import 'package:sugar_tracker/data/models/m_sugar.dart';

class SugarDataWidget extends StatefulWidget {
  final Sugar sugar;
  const SugarDataWidget({super.key, required this.sugar});

  @override
  State<SugarDataWidget> createState() => _SugarDataWidgetState();
}

class _SugarDataWidgetState extends State<SugarDataWidget> {
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
    return SizedBox(
      width: 30,
      child: Center(
        child: FutureBuilder(
          future: InsulinAPI.selectByDate(widget.sugar.datetime!),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              Insulin insulin = snapshot.data as Insulin;
              String units = insulin.id != -1 ? insulin.units.toString() : "";
              insulin.units == 0 ? units = "" : null;
              return Text(units);
            } else
              return const Text("");
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
          future: MealAPI.selectBySugarId(widget.sugar),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              Meal meal = snapshot.data as Meal;
              String carbs = meal.id != -1 ? "${meal.carbs.round()}g" : "";
              return Text(
                carbs,
                style: TextStyle(
                  color: meal.id == -1 ? Colors.white : mealCategoryColor(meal.category),
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
    return FutureBuilder(
      future: () async {
        List<Insulin> insulins = await InsulinAPI.selectAll();
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
