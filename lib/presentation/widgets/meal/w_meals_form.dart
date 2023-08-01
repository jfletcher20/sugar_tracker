import 'package:sugar_tracker/presentation/widgets/food/w_food_selector.dart';
import 'package:sugar_tracker/presentation/widgets/w_datetime_selector.dart';
import 'package:sugar_tracker/presentation/widgets/food/w_dgv_foods.dart';
import 'package:sugar_tracker/data/models/m_meal.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MealFormWidget extends StatefulWidget {
  final Meal meal;
  const MealFormWidget({super.key, required this.meal});
  @override
  State<MealFormWidget> createState() => _MealFormWidgetState();
}

class _MealFormWidgetState extends State<MealFormWidget> {
  // text controllers for each text field
  late final TextEditingController _sugarLevelController;
  late final TextEditingController _insulinController;
  late final TextEditingController _notesController;
  late Meal meal;

  GlobalKey<DateTimeSelectorWidgetState> dateTimeSelectorKey = GlobalKey();
  // form key
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    meal = widget.meal;
    _sugarLevelController = TextEditingController(
        text: meal.sugarLevel.sugar != 0 ? meal.sugarLevel.sugar.toString() : "");
    _insulinController =
        TextEditingController(text: meal.insulin > 0 ? meal.insulin.toString() : "");
    _notesController = TextEditingController(text: meal.notes);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                "Meal creation",
                style:
                    Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            // centered text inkwell widget which updates according to current time automatically, but if the value is set to something else it stops changing
            const DateTimeSelectorWidget(),
            _mealCategoryDropdown(),
            _sugarLevelInput(),
            _insulinInput(),
            _notesInput(),
            const SizedBox(height: 16),
            _foodGrid(),
            _foodSelectionMenuButton(),
            const SizedBox(height: 8),
            _submitMealButton(),
          ],
        ),
      ),
    );
  }

  Card _foodGrid() {
    return Card(
      child: FoodsGridView(
        foods: meal.food.where((food) => food.amount > 0).toList(),
        crossAxisCount: 3,
        showCounter: true,
      ),
    );
  }

  DropdownMenuItem dropdownMenuItem(MealCategory category, IconData icon) {
    return DropdownMenuItem(
      value: category,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: mealCategoryColor(category)),
          const SizedBox(width: 16),
          Text(
            category.name.substring(0, 1).toUpperCase() + category.name.substring(1),
            style: TextStyle(color: mealCategoryColor(category)),
          ),
        ],
      ),
    );
  }

  DropdownButtonFormField _mealCategoryDropdown() {
    meal.category ??= MealCategory.other;
    return DropdownButtonFormField(
      items: [
        dropdownMenuItem(MealCategory.breakfast, Icons.free_breakfast_rounded),
        dropdownMenuItem(MealCategory.lunch, Icons.lunch_dining_rounded),
        dropdownMenuItem(MealCategory.dinner, Icons.dinner_dining_rounded),
        dropdownMenuItem(MealCategory.snack, Icons.fastfood_rounded),
        dropdownMenuItem(MealCategory.other, Icons.cake_rounded),
      ],
      onChanged: (value) => meal.category = value as MealCategory,
      value: meal.category,
    );
  }

  ElevatedButton _foodSelectionMenuButton() {
    return ElevatedButton(
      onPressed: () async {
        meal.food = await showModalBottomSheet(
          context: context,
          shape: _modalDecoration,
          showDragHandle: true,
          builder: (context) => Card(child: FoodSelectorWidget(meal: meal)),
        );
        setState(() {});
      },
      child: Text("Select food" " (${meal.food.where((e) => e.amount > 0).length})"),
    );
  }

  ElevatedButton _submitMealButton() {
    return ElevatedButton(
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          meal.food = meal.food.where((food) => food.amount > 0).toList();
          if (meal.food.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Please select at least one food item.")));
            return;
          }
          // int sugarId = await SugarAPI.insert(meal.sugarLevel);
          // meal.sugarLevel.id = sugarId;
          // await MealAPI.insert(meal);
        }
      },
      child: const Text("Submit"),
    );
  }

  TextFormField _notesInput() {
    return TextFormField(
      decoration: const InputDecoration(labelText: "Notes"),
      controller: _notesController,
      maxLines: 3,
      onChanged: (value) {
        meal.notes = value;
      },
    );
  }

  Widget _sugarLevelInput() {
    return Stack(
      children: [
        TextFormField(
          decoration: const InputDecoration(labelText: "Sugar level"),
          controller: _sugarLevelController,
          keyboardType: TextInputType.number,
          inputFormatters: [LengthLimitingTextInputFormatter(4)],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Please enter a value";
            }
            return null;
          },
          onChanged: (value) => meal.sugarLevel.sugar = double.tryParse(value) ?? 0,
          onSaved: (value) => meal.sugarLevel.sugar = double.tryParse(value ?? "0") ?? 0,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
            child: IconButton(
              icon: const Icon(Icons.notes),
              onPressed: () => showSugarLevelNotesEditor(),
            ),
          ),
        )
      ],
    );
  }

  TextFormField _insulinInput() {
    return TextFormField(
      decoration: const InputDecoration(labelText: "Insulin units"),
      controller: _insulinController,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(2)
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter a value";
        }
        return null;
      },
      onChanged: (value) => meal.insulin = int.tryParse(value) ?? 0,
      onSaved: (value) => meal.insulin = int.tryParse(value ?? "0") ?? 0,
    );
  }

  Future showSugarLevelNotesEditor() {
    final TextEditingController sugarLevelNotesController =
        TextEditingController(text: meal.sugarLevel.notes);
    Widget subtitle;
    subtitle = Column(
      children: [
        TextFormField(
          controller: sugarLevelNotesController,
          decoration: const InputDecoration(labelText: "Sugar level notes"),
          keyboardType: TextInputType.multiline,
          maxLines: 3,
          minLines: 1,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            if (sugarLevelNotesController.text != meal.sugarLevel.notes) {
              meal.sugarLevel.notes = sugarLevelNotesController.text;
              Navigator.pop(context, meal);
            } else {
              Navigator.pop(context);
            }
          },
          child: const Text("Save"),
        ),
      ],
    );
    return showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: _modalDecoration,
      builder: (context) => WillPopScope(
        onWillPop: () async {
          sugarLevelNotesController.text = meal.sugarLevel.notes ?? "";
          return true;
        },
        child: ListTile(subtitle: subtitle),
      ),
    );
  }

  final RoundedRectangleBorder _modalDecoration = const RoundedRectangleBorder(
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(32),
      topRight: Radius.circular(32),
    ),
  );
}
