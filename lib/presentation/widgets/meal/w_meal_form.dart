// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:sugar_tracker/data/api/u_api_food.dart';
import 'package:sugar_tracker/data/api/u_api_insulin.dart';
import 'package:sugar_tracker/data/api/u_api_meal.dart';
import 'package:sugar_tracker/data/api/u_api_sugar.dart';
import 'package:sugar_tracker/data/models/m_food.dart';
import 'package:sugar_tracker/data/models/m_insulin.dart';
import 'package:sugar_tracker/data/preferences.dart';
import 'package:sugar_tracker/data/riverpod.dart/u_provider_meal.dart';
import 'package:sugar_tracker/presentation/widgets/food/w_food_selector.dart';
import 'package:sugar_tracker/presentation/widgets/w_datetime_selector.dart';
import 'package:sugar_tracker/presentation/widgets/food/w_dgv_foods.dart';
import 'package:sugar_tracker/data/models/m_meal.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MealFormWidget extends ConsumerStatefulWidget {
  final Meal meal;
  final bool useAsTemplate;
  const MealFormWidget({super.key, required this.meal, this.useAsTemplate = false});
  @override
  ConsumerState<MealFormWidget> createState() => _MealFormWidgetState();
}

class _MealFormWidgetState extends ConsumerState<MealFormWidget> {
  late final TextEditingController _sugarLevelController;
  late final TextEditingController _insulinController;
  late final TextEditingController _notesController;
  late Meal meal;

  GlobalKey<DateTimeSelectorWidgetState> dateTimeSelectorKey = GlobalKey();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    meal = widget.meal;
    _sugarLevelController = TextEditingController(
        text: meal.sugarLevel.level != 0 ? meal.sugarLevel.level.toString() : "");
    _insulinController =
        TextEditingController(text: meal.insulin.units > 0 ? meal.insulin.units.toString() : "");
    _notesController = TextEditingController(text: meal.notes);
    if (widget.useAsTemplate) {
      meal.sugarLevel.id = -1;
      meal.insulin.id = -1;
      meal.id = -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              title(),
              DateTimeSelectorWidget(
                key: dateTimeSelectorKey,
                initialDateTime: meal.sugarLevel.datetime,
              ),
              const SizedBox(height: 24),
              FutureBuilder(
                future: loadLatestMealCategory(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    meal.category = snapshot.data as MealCategory;
                    return _mealCategoryDropdown(snapshot.data as MealCategory);
                  }
                  return DropdownButtonFormField(
                    items: [dropdownMenuItem(MealCategory.other)],
                    onChanged: (value) => setState(() => meal.category = value),
                  );
                },
              ),
              const SizedBox(height: 24),
              _sugarLevelInput(),
              _insulinInput(),
              _notesInput(),
              const SizedBox(height: 16),
              Card(
                child: FoodListView(
                  foods: meal.food.where((food) => food.amount > 0).toList(),
                  crossAxisCount: 3,
                  showCounter: true,
                ),
              ),
              _foodSelectionMenuButton(),
              const SizedBox(height: 8),
              _submitMealButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget title() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        "Meal creation",
        style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  DropdownMenuItem dropdownMenuItem(MealCategory category) {
    return DropdownMenuItem(
      value: category,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(mealCategoryIcon(category), color: mealCategoryColor(category)),
          const SizedBox(width: 16),
          Text(
            category.name.substring(0, 1).toUpperCase() + category.name.substring(1),
            style: TextStyle(color: mealCategoryColor(category)),
          ),
        ],
      ),
    );
  }

  Future<MealCategory> loadLatestMealCategory() async {
    return !widget.useAsTemplate && meal.id == -1
        ? await ref.read(MealManager.provider.notifier).determineCategory()
        : meal.category;
  }

  final GlobalKey<FormFieldState> _mealCategoryDropdownKey = GlobalKey();
  DropdownButtonFormField _mealCategoryDropdown(MealCategory category) {
    return DropdownButtonFormField(
      key: _mealCategoryDropdownKey,
      items: [
        dropdownMenuItem(MealCategory.breakfast),
        dropdownMenuItem(MealCategory.lunch),
        dropdownMenuItem(MealCategory.dinner),
        dropdownMenuItem(MealCategory.snack),
        dropdownMenuItem(MealCategory.other),
      ],
      onChanged: (value) => setState(() => meal.category = value),
      value: meal.category,
    );
  }

  ElevatedButton _foodSelectionMenuButton() {
    return ElevatedButton(
      onPressed: () async {
        List<Food> foods = await FoodAPI.selectAll();
        for (int i = 0; i < foods.length; i++) {
          if (!meal.food.any((element) => element.id == foods[i].id)) {
            meal.food.add(foods[i]);
            meal.food.last.amount = 0;
          }
        }
        // meal.category = _mealCategoryDropdownKey.currentState!.value as MealCategory;
        meal.food = await showModalBottomSheet(
          // ignore: use_build_context_synchronously
          context: context,
          shape: _modalDecoration,
          showDragHandle: false,
          builder: (context) => Container(
            margin: const EdgeInsets.only(top: 32),
            child: Card(child: FoodSelectorWidget(meal: meal)),
          ),
        );
        meal.category;
        setState(() {});
      },
      child: Text(
        "Food"
        " (${meal.food.fold(0.0, (previousValue, element) => previousValue + (element.amount * (element.carbs / 100))).round()}g carbs)",
      ),
    );
  }

  ElevatedButton _submitMealButton() {
    return ElevatedButton(
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          if (!_prepareFood()) return;
          _prepareDateTime();
          _prepareCategory();
          await _saveData();
          Future.delayed(const Duration(milliseconds: 100), () {
            if (context.mounted) Navigator.pop(context, meal);
          });
        }
      },
      child: const Text("Submit"),
    );
  }

  bool _prepareFood() {
    meal.food = meal.food.where((food) => food.amount > 0).toList();
    if (meal.food.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please select at least one food item."),
      ));
      return false;
    }
    return true;
  }

  void _prepareDateTime() {
    meal.sugarLevel.datetime = meal.insulin.datetime = dateTimeSelectorKey.currentState!.datetime;
  }

  void _prepareCategory() {
    meal.category = _mealCategoryDropdownKey.currentState!.value as MealCategory;
    meal.insulin.category = InsulinCategory.bolus;
  }

  Future<void> _saveData() async {
    meal.sugarLevel.id = await _saveSugarLevel();
    meal.insulin.name == "Unknown" ? meal.insulin.name = "Fiasp" : null;
    meal.insulin.id = await _saveInsulin();
    meal.id = await _saveMeal();
    return;
  }

  Future<int> _saveSugarLevel() async {
    int sugarId = meal.sugarLevel.id;
    if (widget.useAsTemplate || sugarId == -1) {
      sugarId = await SugarAPI.insert(meal.sugarLevel);
    } else {
      await SugarAPI.update(meal.sugarLevel);
    }
    return sugarId;
  }

  Future<int> _saveInsulin() async {
    int insulinId = meal.insulin.id;
    if (widget.useAsTemplate || insulinId == -1) {
      try {
        insulinId = await InsulinAPI.insert(meal.insulin);
      } catch (e) {
        await InsulinAPI.update(meal.insulin);
      }
    } else {
      await InsulinAPI.update(meal.insulin);
    }
    return insulinId;
  }

  Future<int> _saveMeal() async {
    int mealId = meal.id;
    if (widget.useAsTemplate || mealId == -1) {
      mealId = await MealAPI.insert(meal);
    } else {
      await MealAPI.update(meal);
    }
    return mealId;
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
          autofocus: true,
          controller: _sugarLevelController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            LengthLimitingTextInputFormatter(4),
            TextInputFormatter.withFunction((oldValue, newValue) {
              if (newValue.text.contains(",")) {
                return TextEditingValue(
                  text: newValue.text.replaceAll(",", "."),
                  selection: newValue.selection,
                );
              }
              return newValue;
            }),
            TextInputFormatter.withFunction((oldValue, newValue) {
              if (newValue.text.split(".").length > 2) {
                return oldValue;
              }
              return newValue;
            }),
            TextInputFormatter.withFunction((oldValue, newValue) {
              if (newValue.text.contains(".")) {
                if (newValue.text.split(".")[0].length > 2) {
                  return oldValue;
                }
              } else {
                if (newValue.text.length > 2) {
                  return oldValue;
                }
              }
              return newValue;
            }),
          ],
          validator: (value) => value == null || value.isEmpty ? "Please enter a value" : null,
          onChanged: (value) {
            meal.sugarLevel.level = double.tryParse(value) ?? 0;
            setState(() {});
          },
          onSaved: (value) => meal.sugarLevel.level = double.tryParse(value ?? "0") ?? 0,
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

  int get recommendedInsulin {
    double divider = Profile.dividers[meal.category.index];
    double carbs = meal.food.fold(
      0.0,
      (previousValue, element) => previousValue + (element.amount * (element.carbs / 100)),
    );
    int totalUnits = (carbs / divider).round();
    return totalUnits;
  }

  int get recommendedCorrection {
    int correctionLimit = (Profile.weight * 0.1).floor();
    int lowerBorder = 8;
    int correction = 0;
    if (meal.sugarLevel.level > lowerBorder) {
      correction = ((meal.sugarLevel.level - lowerBorder) / 2).round();
      correction > correctionLimit ? correction = correctionLimit : null;
    }
    return correction;
  }

  Widget _insulinInput() {
    String recommended = "Insulin units ($recommendedInsulin";
    if (recommendedCorrection > 0) {
      recommended += " + $recommendedCorrection for correction";
    } else {
      recommended += " advised";
    }
    return Stack(
      children: [
        TextFormField(
          decoration: InputDecoration(labelText: "$recommended)"),
          controller: _insulinController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(2),
          ],
          onChanged: (value) => meal.insulin.units = int.tryParse(value) ?? 0,
          onSaved: (value) => meal.insulin.units = int.tryParse(value ?? "0") ?? 0,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
            child: IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () async {
                String insulinName = meal.insulin.name;
                if (insulinName == "Unknown") {
                  List<Insulin> insulins = await InsulinAPI.selectAll();
                  if (insulins.isNotEmpty) {
                    insulins.sort((a, b) => a.datetime!.compareTo(b.datetime!));
                    insulinName = insulins.last.name;
                  }
                }
                showInsulinEditor(insulinName);
              },
            ),
          ),
        )
      ],
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
          sugarLevelNotesController.text = meal.sugarLevel.notes;
          return true;
        },
        child: ListTile(subtitle: subtitle),
      ),
    );
  }

  Future showInsulinEditor(String insulinName) {
    final TextEditingController insulinNameController = TextEditingController(text: insulinName);
    final TextEditingController insulinNotesController =
        TextEditingController(text: meal.insulin.notes);
    Widget subtitle;
    subtitle = Column(
      children: [
        TextFormField(
          controller: insulinNameController,
          decoration: const InputDecoration(labelText: "Insulin name"),
          keyboardType: TextInputType.multiline,
          maxLines: 3,
          minLines: 1,
        ),
        TextFormField(
          controller: insulinNotesController,
          decoration: const InputDecoration(labelText: "Insulin notes"),
          keyboardType: TextInputType.multiline,
          maxLines: 3,
          minLines: 1,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            if (insulinNotesController.text != meal.insulin.notes ||
                insulinNameController.text != meal.insulin.name) {
              meal.insulin.notes = insulinNotesController.text;
              meal.insulin.name = insulinNameController.text;
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
          insulinNameController.text = meal.insulin.name;
          insulinNotesController.text = meal.insulin.notes;
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
