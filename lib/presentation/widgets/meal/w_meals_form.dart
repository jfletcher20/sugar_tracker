import 'package:sugar_tracker/data/models/m_meal.dart';

import 'package:flutter/material.dart';
import 'package:sugar_tracker/presentation/widgets/food/w_food_selector.dart';

class MealFormWidget extends StatefulWidget {
  final Meal meal;
  const MealFormWidget({super.key, required this.meal});
  @override
  State<MealFormWidget> createState() => _MealFormWidgetState();
}

class _MealFormWidgetState extends State<MealFormWidget> {
  // text controllers for each text field
  late final TextEditingController _insulinController;
  late final TextEditingController _notesController;
  late Meal meal;

  @override
  void initState() {
    super.initState();
    meal = widget.meal;
    _insulinController =
        TextEditingController(text: meal.insulin > 0 ? meal.insulin.toString() : "");
    _notesController = TextEditingController(text: meal.notes);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        child: Column(
          children: [
            TextFormField(
              controller: _insulinController,
              decoration: const InputDecoration(labelText: "Units of insulin"),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter insulin";
                }
                return null;
              },
            ),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: "Notes"),
              keyboardType: TextInputType.multiline,
              maxLines: 3,
            ),
            // category needs to be dropdown menu of MealCategory values
            // date needs to be a date picker with automatic current date
            // time needs to be a time picker with automatic current time
            // food needs to be the food selector widget
            DropdownButtonFormField(
              items: [
                dropdownMenuItem(MealCategory.breakfast, Icons.free_breakfast_rounded),
                dropdownMenuItem(MealCategory.lunch, Icons.lunch_dining_rounded),
                dropdownMenuItem(MealCategory.dinner, Icons.dinner_dining_rounded),
                dropdownMenuItem(MealCategory.snack, Icons.fastfood_rounded),
                dropdownMenuItem(MealCategory.other, Icons.cake_rounded),
              ],
              onChanged: (value) {},
              value: MealCategory.other,
            ),
            SizedBox(height: 128 + 64, child: const FoodSelectorWidget()),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (Form.of(context)!.validate()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Processing Data")),
                  );
                }
              },
              child: const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }

  DropdownMenuItem dropdownMenuItem(MealCategory category, IconData icon) {
    return DropdownMenuItem(
      value: category,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon),
          const SizedBox(width: 16),
          Text(category.name.substring(0, 1).toUpperCase() + category.name.substring(1)),
        ],
      ),
    );
  }
}
