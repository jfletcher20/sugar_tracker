import 'package:sugar_tracker/presentation/widgets/w_datetime_selector.dart';
import 'package:sugar_tracker/data/api/u_api_food_category.dart';
import 'package:sugar_tracker/data/models/m_food_category.dart';
import 'package:sugar_tracker/data/api/u_api_food.dart';
import 'package:sugar_tracker/data/models/m_food.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
              _notesInput(),
              const SizedBox(height: 16),
              FutureBuilder(
                future: FoodCategoryAPI.selectAll(),
                builder: (context, snapshot) {
                  List<FoodCategory> foodCategories = List.empty(growable: true);
                  if (snapshot.hasData) {
                    foodCategories = snapshot.data as List<FoodCategory>;
                    food.category = foodCategories.first;
                  }
                  return _categoryGrid(foodCategories);
                },
              ),
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

  GridView _categorySelection(List<FoodCategory> categories) {
    return GridView(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      children: categories.map((e) => _categoryCard(e)).toList(),
    );
  }

  final double imgSize = 64;
  Card _categoryCard(FoodCategory category) {
    return Card(
      color: food.category == category ? Colors.red.withOpacity(0.5) : null,
      child: InkWell(
        onTap: () {
          print("tapped");
          food.category = category;
          setState(() {});
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              category.picture ?? "assets/images/food/unknown.png",
              width: imgSize,
              height: imgSize,
              errorBuilder: imageNotFound,
            ),
            // label(category),
          ],
        ),
      ),
    );
  }

  Widget label(FoodCategory category) {
    return Positioned(
      bottom: 0,
      child: SizedBox(
        width: imgSize + 16,
        child: FittedBox(
          fit: BoxFit.fitWidth,
          child: Text(
            category.name.substring(0, 1).toUpperCase() + category.name.substring(1),
            // add drop shadow
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              shadows: [
                const Shadow(
                  color: Colors.black,
                  offset: Offset(1, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget imageNotFound(BuildContext context, Object error, StackTrace? stackTrace) {
    return Image.asset(
      "assets/images/food/unknown.png",
      color: Colors.redAccent,
      height: imgSize,
      width: imgSize,
    );
  }

  ElevatedButton _submitMealButton() {
    return ElevatedButton(
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          await _saveData();
          Future.delayed(const Duration(milliseconds: 100), () {
            if (context.mounted) Navigator.pop(context, food);
          });
        }
      },
      child: const Text("Submit"),
    );
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
