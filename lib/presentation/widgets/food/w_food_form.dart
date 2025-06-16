// ignore_for_file: curly_braces_in_flow_control_structures
import 'package:sugar_tracker/presentation/widgets/food_category/w_dgv_food_category.dart';
import 'package:sugar_tracker/data/riverpod.dart/u_provider_food_category.dart';
import 'package:sugar_tracker/presentation/widgets/w_datetime_selector.dart';
import 'package:sugar_tracker/data/riverpod.dart/u_provider_food.dart';
import 'package:sugar_tracker/presentation/widgets/w_imagepicker.dart';
import 'package:sugar_tracker/data/models/m_food_category.dart';
import 'package:sugar_tracker/data/models/m_food.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FoodFormWidget extends ConsumerStatefulWidget {
  final Food food;
  final bool useAsTemplate;
  const FoodFormWidget({super.key, required this.food, this.useAsTemplate = false});
  @override
  ConsumerState<FoodFormWidget> createState() => _FoodFormWidgetState();
}

class _FoodFormWidgetState extends ConsumerState<FoodFormWidget> {
  // text controllers for each text field
  late final TextEditingController _nameController;
  late final TextEditingController _carbsController;
  late final TextEditingController _weightController;
  late final TextEditingController _notesController;
  late Food food;

  GlobalKey<DateTimeSelectorWidgetState> dateTimeSelectorKey = GlobalKey();
  // form key
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    food = widget.food;
    _carbsController = TextEditingController(text: food.carbs > 0 ? food.carbs.toString() : "");
    _nameController = TextEditingController(text: food.name != "Unknown" ? food.name : "");
    _weightController =
        TextEditingController(text: food.weight > 0 ? food.weight.round().toString() : "");
    _notesController = TextEditingController(text: food.notes);
    if (widget.useAsTemplate) {
      food.id = -1;
    }
  }

  GlobalKey<ImagePickerWidgetState> imagePickerKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    title,
                    ImagePickerWidget(key: imagePickerKey, path: food.picture, imgSize: 128),
                    const SizedBox(height: 16),
                    SizedBox(child: _nameInput),
                    const SizedBox(height: 6),
                    _carbsInput,
                    const SizedBox(height: 6),
                    _weightInput,
                    const SizedBox(height: 6),
                    _notesInput,
                    const SizedBox(height: 16),
                    _categories,
                    const SizedBox(height: 8),
                    _submitMealButton,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget get _categories {
    List<FoodCategory> foodCategories =
        ref.read(FoodCategoryManager.provider.notifier).getFoodCategories();
    if (!widget.useAsTemplate && food.id == -1)
      food.foodCategory = foodCategories.first;
    else
      food.foodCategory = widget.food.foodCategory;
    return _categoryGrid(foodCategories);
  }

  Widget get title {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        "Food creation",
        style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Card _categoryGrid(List<FoodCategory> categories) {
    return Card(
      child: categories.isNotEmpty
          ? _categorySelection(categories)
          : const Center(child: Text("No categories found")),
    );
  }

  final GlobalKey<FoodCategoryGridViewState> _categoryGridKey = GlobalKey();
  Widget _categorySelection(List<FoodCategory> categories) {
    return FoodCategoryGridView(
      key: _categoryGridKey,
      foodCategories: categories,
      initialCategory: food.foodCategory,
      cancelDeselect: true,
    );
  }

  ElevatedButton get _submitMealButton {
    return ElevatedButton(
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          print(widget.useAsTemplate);
          _prepareFoodCategory();
          await _prepareImage();
          await _saveData();
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) Navigator.pop(context, food);
          });
        }
      },
      child: const Text("Submit"),
    );
  }

  Future<void> _prepareImage() async {
    ImagePickerWidgetState imagePicker = imagePickerKey.currentState!;
    food.picture = imagePicker.image?.path ?? "";
    return;
  }

  void _prepareFoodCategory() => food.foodCategory = _categoryGridKey.currentState!.selected;
  Future<void> _saveData() async => food.id = await _saveFood();

  Future<int> _saveFood() async {
    int foodId = food.id;
    if (widget.useAsTemplate || foodId == -1)
      foodId = await ref.read(FoodManager.provider.notifier).addFood(food);
    else
      await ref.read(FoodManager.provider.notifier).updateFood(food);
    return foodId;
  }

  TextFormField get _nameInput {
    return TextFormField(
      decoration:
          const InputDecoration(labelText: "Food name", suffixIcon: Icon(Icons.sell_outlined)),
      autofocus: true,
      controller: _nameController,
      keyboardType: TextInputType.name,
      validator: (value) => value == null || value.isEmpty ? "Please enter a value" : null,
      onChanged: (value) => food.name = value,
      onSaved: (value) => food.name = value ?? "Unknown",
    );
  }

  TextFormField get _carbsInput {
    return TextFormField(
      decoration:
          const InputDecoration(labelText: "Carbs per 100g", suffixIcon: Icon(Icons.percent)),
      controller: _carbsController,
      keyboardType: TextInputType.number,
      inputFormatters: limitDecimals,
      onChanged: (value) => food.carbs = double.tryParse(value) ?? 0,
      onSaved: (value) => food.carbs = double.tryParse(value ?? "0") ?? 0,
    );
  }

  TextFormField get _weightInput {
    return TextFormField(
      decoration:
          const InputDecoration(labelText: "Expected weight", suffixIcon: Icon(Icons.scale)),
      controller: _weightController,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(6),
      ],
      onChanged: (value) => food.weight = double.tryParse(value) ?? 0,
      onSaved: (value) => food.weight = double.tryParse(value ?? "0") ?? 0,
    );
  }

  List<TextInputFormatter> get limitDecimals {
    return <TextInputFormatter>[
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
    ];
  }

  TextFormField get _notesInput {
    return TextFormField(
      decoration: const InputDecoration(labelText: "Notes", suffixIcon: Icon(Icons.comment)),
      controller: _notesController,
      minLines: 1,
      maxLines: 3,
      onChanged: (value) => food.notes = value,
    );
  }
}
