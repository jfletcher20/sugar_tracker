import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sugar_tracker/presentation/widgets/meal/w_meals_data.dart';
import 'package:sugar_tracker/presentation/widgets/food/w_dgv_foods.dart';
import 'package:sugar_tracker/data/api/u_api_meal.dart';
import 'package:sugar_tracker/data/models/m_meal.dart';

import 'package:flutter/material.dart';
import 'package:sugar_tracker/presentation/widgets/meal/w_meals_form.dart';

class MealHistoryWidget extends StatefulWidget {
  const MealHistoryWidget({super.key});

  @override
  State<MealHistoryWidget> createState() => _MealHistoryWidgetState();
}

class _MealHistoryWidgetState extends State<MealHistoryWidget> {
  @override
  Widget build(BuildContext context) {
    Size maxSize = MediaQuery.of(context).size;
    return FutureBuilder(
      builder: (builder, snapshot) {
        if (snapshot.hasData) {
          List<Meal> meals = snapshot.data as List<Meal>;
          meals.sort((a, b) => a.sugarLevel.datetime!.compareTo(b.sugarLevel.datetime!));
          meals = meals.reversed.toList();
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                for (int i = 0; i < meals.length; i++) mealCard(context, meals[i]),
              ],
            ),
          );
        } else {
          return SizedBox(
            height: maxSize.height,
            width: maxSize.width,
            child: const Center(child: CircularProgressIndicator()),
          );
        }
      },
      future: MealAPI.selectAll(),
    );
  }

  Card mealCard(BuildContext context, Meal meal) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      borderOnForeground: true,
      child: Stack(
        children: [
          category(meal),
          Row(children: [
            FoodsGridView(foods: meal.food, scrollDirection: Axis.horizontal),
            MealDataWidget(meal: meal),
          ]),
        ],
      ),
    );
  }

  Widget category(Meal meal) {
    return Positioned(
      right: 0,
      child: InkWell(
        child: categoryStrip(meal.category),
        onTap: () async {
          bool? result = await showModalBottomSheet(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
            ),
            showDragHandle: true,
            context: context,
            builder: (context) => SizedBox(
              height: 64 + 16,
              child: GridView(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  childAspectRatio: 2,
                ),
                children: [
                  _useAsTemplate(context, meal),
                  _edit(context, meal),
                  _delete(context, meal),
                  _share(context, meal),
                  _copy(context, meal),
                  IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          );
          if (result != null && result) {
            setState(() {});
          }
        },
      ),
    );
  }

  IconButton _delete(BuildContext context, Meal meal) {
    return IconButton(
      icon: const Icon(Icons.delete),
      onPressed: () async {
        // await MealAPI.delete(meal);
        // show confirmation dialog
        bool? result = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Delete meal?"),
            content: const Text("This action cannot be undone."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Delete"),
              ),
            ],
          ),
        );
        if (result != null && result) {
          await MealAPI.delete(meal);
          if (context.mounted) setState(() {});
        }
        if (context.mounted) Navigator.pop(context, true);
      },
    );
  }

  IconButton _share(BuildContext context, Meal meal) {
    return IconButton(
      icon: const Icon(Icons.share),
      onPressed: () {
        Share.share(meal.toString());
        Navigator.pop(context);
      },
    );
  }

  IconButton _copy(BuildContext context, Meal meal) {
    return IconButton(
      icon: const Icon(Icons.copy),
      onPressed: () {
        Clipboard.setData(ClipboardData(text: meal.toString()));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Meal copied to clipboard"),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      },
    );
  }

  IconButton _useAsTemplate(BuildContext context, Meal meal) {
    return IconButton(
      icon: const Icon(Icons.food_bank),
      onPressed: () async {
        Meal? result = await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: const Text("Meal from template")),
              body: MealFormWidget(meal: meal, useAsTemplate: true),
            ),
          ),
        );
        if (result != null) {
          setState(() {});
        }
      },
    );
  }

  IconButton _edit(BuildContext context, Meal meal) {
    return IconButton(
      icon: const Icon(Icons.edit),
      onPressed: () async {
        Meal? result = await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: const Text("Edit Meal")),
              body: MealFormWidget(meal: meal),
            ),
          ),
        );
        if (result != null) {
          setState(() {
            meal = result;
          });
        }
      },
    );
  }

  Widget categoryStrip(MealCategory category) {
    return Container(
      width: 8,
      height: 60,
      decoration: BoxDecoration(
        color: mealCategoryColor(category),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(16),
          bottomLeft: Radius.circular(16),
        ),
      ),
    );
  }
}
