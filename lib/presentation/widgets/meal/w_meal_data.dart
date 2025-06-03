import 'package:sugar_tracker/presentation/widgets/meal/w_icon_info.dart';
import 'package:sugar_tracker/data/riverpod.dart/u_provider_meal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sugar_tracker/data/models/m_meal.dart';

import 'package:flutter/material.dart';

class MealDataWidget extends StatelessWidget {
  final Meal meal;
  const MealDataWidget({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(children: [title(context), Positioned(right: 0, top: -14, child: notes(context))]),
        data(context),
      ],
    );
  }

  IconButton notes(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.notes,
          color: (meal.notes?.isEmpty ?? true) ? Colors.white.withOpacity(0.5) : null),
      onPressed: () {
        String category = MealCategory.values[meal.category.index].name;
        String appBarTitle = "Notes for $category at ${meal.time}, ${meal.date}";
        Widget subtitle;
        TextEditingController notesController = TextEditingController(text: meal.notes);
        subtitle = Column(
          children: [
            const SizedBox(height: 24),
            TextFormField(
              controller: notesController,
              decoration: const InputDecoration(labelText: "Notes"),
              keyboardType: TextInputType.multiline,
              maxLines: 5,
              minLines: 1,
            ),
            const SizedBox(height: 24),
            Consumer(
              builder: (context, ref, child) {
                return ElevatedButton(
                  onPressed: () {
                    if (notesController.text != meal.notes) {
                      meal.notes = notesController.text;
                      ref.read(MealManager.provider.notifier).updateMeal(meal);
                      Navigator.pop(context, meal);
                    }
                  },
                  child: const Text("Save"),
                );
              },
            ),
          ],
        );
        showModalBottomSheet(
          context: context,
          showDragHandle: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
          ),
          builder: (context) => ListTile(
            title: Text(appBarTitle,
                style:
                    Theme.of(context).textTheme.titleLarge?.copyWith(color: meal.category.color)),
            subtitle: subtitle,
          ),
        );
      },
    );
  }

  Widget title(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      width: 230,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(bottomRight: Radius.circular(32)),
        gradient: _gradient(context),
      ),
      child: titleText(context),
    );
  }

  LinearGradient _gradient(BuildContext context) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Colors.black, meal.category.color],
    );
  }

  RichText titleText(BuildContext context) {
    // return time and category
    return RichText(
      text: TextSpan(
        children: [
          time(context),
          const TextSpan(text: " "),
          category(context),
        ],
      ),
    );
  }

  TextSpan time(BuildContext context) {
    return TextSpan(
      text: meal.time,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(color: meal.category.color),
    );
  }

  TextSpan category(BuildContext context) {
    return TextSpan(
      text: MealCategory.values[meal.category.index].name.toUpperCase(),
      style: Theme.of(context)
          .textTheme
          .titleLarge
          ?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
    );
  }

  Widget data(BuildContext context) {
    return Row(
      // alignment: WrapAlignment.end,
      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [sugar, insulin, carbs, date, const SizedBox(width: 48)],
    );
  }

  RichText wrapper(BuildContext context, List<InlineSpan> children) {
    TextStyle? s = Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.25);
    return RichText(text: TextSpan(style: s, children: children));
  }

  Widget get sugar {
    return IconWithInfo(
      info: meal.sugarLevel.toString(),
      icon: Icons.water_drop,
      iconColor: Colors.redAccent,
      width: 48 + 12,
    );
  }

  Widget get insulin {
    return IconWithInfo(
      info: "${meal.insulin.units == 0 ? "–" : meal.insulin.units}",
      icon: Icons.edit_outlined,
      iconColor: meal.insulin.category.color,
      width: 32 + 16,
    );
  }

  Widget get carbs {
    return IconWithInfo(
      info: "${meal.carbs.round()}g",
      icon: Icons.cookie,
      iconColor: meal.category.color,
      width: 48 + 24,
    );
  }

  Widget get date {
    // return IconWithInfo(
    //   info: meal.date.abbreviated,
    //   icon: Icons.calendar_month,
    // );
    return Text(meal.date);
  }
}

// extension on String {
//   get abbreviated {
//     // if the date contains 2 ".", // then it is in the format "dd.MM.yyyy"; it will be abbreviated to "dd.MM.'yy"
//     if (contains(".")) {
//       List<String> parts = this.split(".");
//       if (parts.length == 3) {
//         return "${parts[0]}.${parts[1]}.'${parts[2].substring(2)}";
//       }
//     } else
//       return this; // if it does not contain 2 ".", return the original string
//   }
// }
