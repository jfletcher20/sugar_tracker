// ignore_for_file: curly_braces_in_flow_control_structures
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sugar_tracker/data/constants.dart';
import 'package:sugar_tracker/presentation/widgets/food/w_food_selector.dart';
import 'package:sugar_tracker/presentation/widgets/w_datetime_selector.dart';
import 'package:sugar_tracker/data/riverpod.dart/u_provider_insulin.dart';
import 'package:sugar_tracker/presentation/widgets/food/w_dgv_foods.dart';
import 'package:sugar_tracker/data/riverpod.dart/u_provider_sugar.dart';
import 'package:sugar_tracker/data/riverpod.dart/u_provider_food.dart';
import 'package:sugar_tracker/data/riverpod.dart/u_provider_meal.dart';
import 'package:sugar_tracker/data/models/m_insulin.dart';
import 'package:sugar_tracker/data/models/m_food.dart';
import 'package:sugar_tracker/data/models/m_meal.dart';
import 'package:sugar_tracker/data/preferences.dart';

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

  DateTimeSelectorWidget get _dateTimeSelector {
    return DateTimeSelectorWidget(
      key: dateTimeSelectorKey,
      initialDateTime: meal.sugarLevel.datetime,
    );
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
              title,
              _dateTimeSelector,
              const SizedBox(height: 24),
              SizedBox(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(flex: 12, child: FittedBox(child: _mealCategoryChoice)),
                      const Spacer(),
                      Expanded(flex: 8, child: _sugarLevelInput),
                    ]),
              ),
              const SizedBox(height: 24),
              _insulinInput,
              const SizedBox(height: 16),
              _foodListView,
              _foodSelectionMenuButton,
              const SizedBox(height: 8),
              _submitMealButton,
            ],
          ),
        ),
      ),
    );
  }

  Widget get title {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        "Meal creation",
        style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  GlobalKey<MealCategorySelectionState> mealCategoryKey = GlobalKey();
  Widget get _mealCategoryChoice => MealCategorySelection(key: mealCategoryKey, category: _latest);

  MealCategory get _latest {
    if (!widget.useAsTemplate && meal.id == -1)
      return ref.read(MealManager.provider.notifier).determineCategory();
    return meal.category;
  }

  Widget get _mealNotesButton {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        child: IconButton(icon: const Icon(Icons.notes), onPressed: () => showMealNotesEditor()),
      ),
    );
  }

  Widget get _foodListView {
    return Stack(
      alignment: Alignment.center,
      children: [
        Card(
          child: FoodListView(
            foods: meal.food.where((food) => food.amount > 0).toList(),
            crossAxisCount: 3,
            showCounter: true,
          ),
        ),
        _mealNotesButton,
      ],
    );
  }

  ElevatedButton get _foodSelectionMenuButton {
    return ElevatedButton.icon(
      icon: const Icon(FontAwesomeIcons.utensils),
      label: Text(
        "Add food"
        " (${meal.food.fold(0.0, (previousValue, element) => previousValue + (element.amount * (element.carbs / 100))).round()}g carbs)",
      ),
      onPressed: () async {
        Set<Food> foods = ref.watch(FoodManager.provider);
        for (int i = 0; i < foods.length; i++) {
          if (!meal.food.any((element) => element.id == foods.elementAt(i).id)) {
            meal.food.add(foods.elementAt(i));
            meal.food.last.amount = 0;
          }
        }
        List<Food>? chosenFoodItems = await showModalBottomSheet<List<Food>?>(
          context: context,
          shape: _modalDecoration,
          showDragHandle: false,
          builder: (context) => StatefulBuilder(builder: (context, setState) {
            return Container(
              margin: const EdgeInsets.only(top: 32),
              child: Card(child: FoodSelectorWidget(meal: meal)),
            );
          }),
        );
        if (chosenFoodItems != null) meal.food = chosenFoodItems;
        setState(() {});
      },
    );
  }

  ElevatedButton get _submitMealButton {
    return ElevatedButton(
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          if (!_prepareFood()) return;
          _prepareDateTime();
          _prepareCategory();
          await _saveData();
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) Navigator.pop(context, meal);
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
    meal.category = mealCategoryKey.currentState!.selectedCategory;
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
    if (widget.useAsTemplate || sugarId == -1)
      sugarId = await ref.read(SugarManager.provider.notifier).addSugar(meal.sugarLevel);
    else
      await ref.read(SugarManager.provider.notifier).updateSugar(meal.sugarLevel);
    return sugarId;
  }

  Future<int> _saveInsulin() async {
    int insulinId = meal.insulin.id;
    if (widget.useAsTemplate || insulinId == -1) {
      try {
        insulinId = await ref.read(InsulinManager.provider.notifier).addInsulin(meal.insulin);
      } catch (e) {
        await ref.read(InsulinManager.provider.notifier).updateInsulin(meal.insulin);
      }
    } else
      await ref.read(InsulinManager.provider.notifier).updateInsulin(meal.insulin);
    return insulinId;
  }

  Future<int> _saveMeal() async {
    int mealId = meal.id;
    if (widget.useAsTemplate || mealId == -1)
      mealId = await ref.read(MealManager.provider.notifier).addMeal(meal);
    else
      await ref.read(MealManager.provider.notifier).updateMeal(meal);
    return mealId;
  }

  Widget get _sugarLevelInput {
    return TextFormField(
      decoration: InputDecoration(
        labelText: "Sugar level",
        suffixIcon: IconButton(
          icon: Icon(IconConstants.sugar.outlined),
          onPressed: () => showSugarLevelNotesEditor(),
        ),
      ),
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
      validator: (value) => value == null || value.isEmpty || double.tryParse(value) == 0.0
          ? "Please enter a value"
          : null,
      onChanged: (value) {
        meal.sugarLevel.level = double.tryParse(value) ?? 0;
        setState(() {});
      },
      onSaved: (value) => meal.sugarLevel.level = double.tryParse(value ?? "0") ?? 0,
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

  Widget get _insulinInput {
    String recommended = "Insulin units ($recommendedInsulin";
    if (recommendedCorrection > 0) {
      recommended += " + $recommendedCorrection for correction";
    } else {
      recommended += " advised";
    }
    return TextFormField(
      decoration: InputDecoration(
        labelText: "$recommended)",
        suffixIcon: IconButton(
          icon: const Icon(Icons.edit_outlined),
          onPressed: () async {
            String insulinName = meal.insulin.name;
            if (insulinName == "Unknown") {
              List<Insulin> insulins = ref.watch(InsulinManager.provider).toList();
              if (insulins.isNotEmpty) {
                insulins.sort((a, b) => a.datetime!.compareTo(b.datetime!));
                insulinName = insulins.last.name;
              }
            }
            showInsulinEditor(insulinName);
          },
        ),
      ),
      controller: _insulinController,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(2),
      ],
      onChanged: (value) => meal.insulin.units = int.tryParse(value) ?? 0,
      onSaved: (value) => meal.insulin.units = int.tryParse(value ?? "0") ?? 0,
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

  Future showMealNotesEditor() {
    Widget subtitle;
    subtitle = Column(
      children: [
        TextFormField(
          controller: _notesController,
          decoration: const InputDecoration(labelText: "Meal notes"),
          keyboardType: TextInputType.multiline,
          maxLines: 5,
          minLines: 1,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            if (_notesController.text != meal.sugarLevel.notes) {
              meal.notes = _notesController.text;
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
          _notesController.text = meal.notes ?? "";
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

class MealCategorySelection extends StatefulWidget {
  final MealCategory category;
  const MealCategorySelection({super.key, required this.category});

  @override
  State<MealCategorySelection> createState() => MealCategorySelectionState();
}

class MealCategorySelectionState extends State<MealCategorySelection> {
  late MealCategory selectedCategory;

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.category;
  }

  Color getColor(MealCategory category) {
    return category == selectedCategory ? category.color : Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text("Category",
            textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium!),
        Wrap(
          children: MealCategory.values.map((category) {
            return IconButton(
              // icon: Icon(category.icon, color: getColor(category)),
              splashRadius: 4,
              icon: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.transparent),
                ),
                child: Icon(category.icon, color: getColor(category)),
              ),
              iconSize: 32,
              onPressed: () => setState(() => selectedCategory = category),
              isSelected: selectedCategory == category,
              selectedIcon: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: category.color),
                ),
                child: Icon(category.icon, color: category.color),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
