import 'package:sugar_tracker/presentation/widgets/food_category/w_dgv_food_category.dart';
import 'package:sugar_tracker/presentation/widgets/w_datetime_selector.dart';
import 'package:sugar_tracker/data/api/u_api_food_category.dart';
import 'package:sugar_tracker/data/models/m_food_category.dart';
import 'package:sugar_tracker/data/api/u_api_food.dart';
import 'package:sugar_tracker/data/models/m_food.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sugar_tracker/presentation/widgets/w_imagepicker.dart';

class FoodFormWidget extends StatefulWidget {
  final Food food;
  final bool useAsTemplate;
  const FoodFormWidget({super.key, required this.food, this.useAsTemplate = false});
  @override
  State<FoodFormWidget> createState() => _FoodFormWidgetState();
}

class _FoodFormWidgetState extends State<FoodFormWidget> {
  // text controllers for each text field
  late final TextEditingController _nameController;
  late final TextEditingController _carbsController;
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
    _nameController = TextEditingController(text: food.name ?? "");
    _notesController = TextEditingController(text: food.notes);
    if (widget.useAsTemplate) {
      food.id = -1;
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
              _nameInput(),
              _carbsInput(),
              Row(
                children: [
                  ImagePickerWidget(path: food.picture, imgSize: 128),
                  _notesInput(),
                ],
              ),
              const SizedBox(height: 16),
              _categories(),
              const SizedBox(height: 8),
              _submitMealButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categories() {
    return FutureBuilder(
      future: FoodCategoryAPI.selectAll(),
      builder: (context, snapshot) {
        List<FoodCategory> foodCategories = List.empty(growable: true);
        if (snapshot.hasData) {
          foodCategories = snapshot.data as List<FoodCategory>;
          if (!widget.useAsTemplate && food.id == -1) {
            food.foodCategory = foodCategories.first;
          } else {
            food.foodCategory = widget.food.foodCategory;
          }
        }
        return _categoryGrid(foodCategories);
      },
    );
  }

  Widget title() {
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
    );
  }

  final double imgSize = 64;

  ElevatedButton _submitMealButton() {
    return ElevatedButton(
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          _prepareFoodCategory();
          await _saveData();
          Future.delayed(const Duration(milliseconds: 100), () {
            if (context.mounted) Navigator.pop(context, food);
          });
        }
      },
      child: const Text("Submit"),
    );
  }

  void _prepareFoodCategory() {
    food.foodCategory = _categoryGridKey.currentState!.selected;
  }

  Future<void> _saveData() async {
    food.id = await _saveFood();
    return;
  }

  Future<int> _saveFood() async {
    int foodId = food.id;
    if (widget.useAsTemplate || foodId == -1) {
      foodId = await FoodAPI.insert(food);
    } else {
      await FoodAPI.update(food);
    }
    return foodId;
  }

  TextFormField _nameInput() {
    return TextFormField(
      decoration: const InputDecoration(labelText: "Food name"),
      autofocus: true,
      controller: _nameController,
      keyboardType: TextInputType.name,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter a value";
        }
        return null;
      },
      onChanged: (value) => food.name = value,
      onSaved: (value) => food.name = value,
    );
  }

  TextFormField _carbsInput() {
    return TextFormField(
      decoration: const InputDecoration(labelText: "Carbs per 100g"),
      controller: _carbsController,
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
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter a value";
        }
        return null;
      },
      onChanged: (value) => food.carbs = double.tryParse(value) ?? 0,
      onSaved: (value) => food.carbs = double.tryParse(value ?? "0") ?? 0,
    );
  }

  TextFormField _notesInput() {
    return TextFormField(
      decoration: const InputDecoration(labelText: "Notes"),
      controller: _notesController,
      maxLines: 3,
      onChanged: (value) {
        food.notes = value;
      },
    );
  }
}
