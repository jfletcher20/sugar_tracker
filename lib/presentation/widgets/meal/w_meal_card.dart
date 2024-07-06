import 'package:sugar_tracker/data/riverpod.dart/u_provider_insulin.dart';
import 'package:sugar_tracker/presentation/widgets/meal/w_meal_form.dart';
import 'package:sugar_tracker/presentation/widgets/meal/w_meal_data.dart';
import 'package:sugar_tracker/presentation/widgets/food/w_dgv_foods.dart';
import 'package:sugar_tracker/data/riverpod.dart/u_provider_sugar.dart';
import 'package:sugar_tracker/data/riverpod.dart/u_provider_meal.dart';
import 'package:sugar_tracker/data/models/m_meal.dart';
import 'package:sugar_tracker/data/constants.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class MealCard extends StatelessWidget {
  final Meal meal;
  const MealCard({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      borderOnForeground: true,
      child: Stack(
        children: [
          Consumer(builder: (context, ref, child) => category(meal, ref, context)),
          Row(children: [
            FoodListView(foods: meal.food, crossAxisCount: 1),
            MealDataWidget(meal: meal),
          ]),
        ],
      ),
    );
  }

  Icon _icon(IconData icon) {
    return Icon(
      meal.category.icon,
      color: Colors.white,
      shadows: const [Shadow(color: Colors.black, offset: Offset(1, 1), blurRadius: 2)],
      size: 32,
    );
  }

  final ShapeBorder _shape = const RoundedRectangleBorder(
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(32),
      topRight: Radius.circular(32),
    ),
  );

  final SliverGridDelegate _gridDelegate = const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 6,
    childAspectRatio: 2,
  );

  Widget category(Meal meal, WidgetRef ref, BuildContext context) {
    return Positioned(
      right: 0,
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          categoryStrip(meal.category),
          Container(
            margin: const EdgeInsets.all(8.0),
            child: Center(
              child: IconButton(
                icon: _icon(meal.category.icon),
                onPressed: () async {
                  await showModalBottomSheet(
                    shape: _shape,
                    showDragHandle: true,
                    context: context,
                    builder: (context) => SizedBox(
                      height: 64 + 16,
                      child: GridView(
                        gridDelegate: _gridDelegate,
                        children: [
                          _useAsTemplate(context, meal),
                          _edit(context, meal),
                          _delete(context, meal, ref),
                          _share(context, meal),
                          _copy(context, meal),
                          _exportToCsv(context, meal),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconButton _delete(BuildContext context, Meal meal, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.delete),
      onPressed: () async {
        await showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
          ),
          showDragHandle: true,
          builder: (context) => Column(
            children: [
              _optionTile(
                label: "Everything",
                icon: Icons.delete_forever,
                onTap: () async {
                  await ref.read(InsulinManager.provider.notifier).removeInsulin(meal.insulin);
                  await ref.read(SugarManager.provider.notifier).removeSugar(meal.sugarLevel);
                  await ref.read(MealManager.provider.notifier).removeMeal(meal);
                  if (context.mounted) Navigator.pop(context);
                },
              ),
              _optionTile(
                label: "Meal and sugar",
                icon: IconConstants.sugar,
                onTap: () async {
                  await ref.read(SugarManager.provider.notifier).removeSugar(meal.sugarLevel);
                  await ref.read(MealManager.provider.notifier).removeMeal(meal);
                  if (context.mounted) Navigator.pop(context);
                },
              ),
              _optionTile(
                label: "Meal and insulin",
                icon: Icons.edit_outlined,
                onTap: () async {
                  await ref.read(InsulinManager.provider.notifier).removeInsulin(meal.insulin);
                  await ref.read(MealManager.provider.notifier).removeMeal(meal);
                  if (context.mounted) Navigator.pop(context);
                },
              ),
              _optionTile(
                label: "Only meal",
                icon: Icons.fastfood,
                onTap: () async {
                  await ref.read(MealManager.provider.notifier).removeMeal(meal);
                  if (context.mounted) Navigator.pop(context);
                },
              ),
              _optionTile(
                label: "Cancel",
                icon: Icons.cancel,
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
        if (context.mounted) Navigator.pop(context, true);
      },
    );
  }

  ListTile _optionTile({required IconData icon, required String label, void Function()? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }

  IconButton _exportToCsv(BuildContext context, Meal meal) {
    return IconButton(
      icon: const Icon(Icons.download),
      onPressed: () {
        // export to csv to location user specifies (show file dialog)
        // showSavePanel(
        //   suggestedFileName: "meal.csv",
        //   allowedFileTypes: const [FileTypeFilterGroup.csv()],
        //   confirmButtonText: "Export",
        //   initialDirectory: "C:\\Users\\${Platform.environment["USERNAME"]}\\Documents",
        // ).then((value) {
        //   if (value != null) {
        //     String path = value.path;
        //     if (!path.endsWith(".csv")) {
        //       path += ".csv";
        //     }
        //     MealAPI.exportToCsv(meal, path);
        //   }
        // });
        Navigator.pop(context);
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
      icon: const Icon(Icons.plus_one),
      onPressed: () async {
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: const Text("Meal from template")),
              body: MealFormWidget(meal: meal, useAsTemplate: true),
            ),
          ),
        );
      },
    );
  }

  IconButton _edit(BuildContext context, Meal meal) {
    return IconButton(
      icon: const Icon(Icons.edit),
      onPressed: () async {
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: const Text("Edit Meal")),
              body: MealFormWidget(meal: meal),
            ),
          ),
        );
      },
    );
  }

  Widget categoryStrip(MealCategory category) {
    return Container(
      width: 32,
      height: 64 + 16,
      decoration: BoxDecoration(
        gradient: _gradient(category.color),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
    );
  }

  Gradient _gradient(Color color) {
    return LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [color, color.withOpacity(0.5)],
    );
  }
}
