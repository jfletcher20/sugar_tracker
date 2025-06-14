// ignore_for_file: avoid_print
import 'package:sugar_tracker/data/constants.dart';
import 'package:sugar_tracker/data/models/m_food.dart';
import 'package:sugar_tracker/data/models/m_food_category.dart';
import 'package:sugar_tracker/data/models/m_insulin.dart';
import 'package:sugar_tracker/data/models/m_meal.dart';
import 'package:sugar_tracker/data/models/m_sugar.dart';
import 'package:sugar_tracker/presentation/routes/w_food_list.dart';
import 'package:sugar_tracker/presentation/routes/w_insulin_history.dart';
import 'package:sugar_tracker/presentation/routes/w_meal_history.dart';
import 'package:sugar_tracker/presentation/routes/w_settings.dart';
import 'package:sugar_tracker/presentation/routes/w_sugar_history.dart';
import 'package:sugar_tracker/presentation/widgets/food/w_food_form.dart';
import 'package:sugar_tracker/presentation/widgets/insulin/w_insulin_form.dart';
import 'package:sugar_tracker/presentation/widgets/meal/w_meal_form.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this, initialIndex: 2);
  }

  Widget wrap(Widget widget) => Scrollbar(child: widget);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Sugar Tracker", style: TextStyle(fontFamily: "Boucherie")),
          actions: [
            _createMeasurementEntryButton(),
            _createMealButton(),
            _createFoodItemButton(),
          ]),
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _tabController,
        children: <Widget>[
          wrap(const SugarHistoryWidget()),
          wrap(const InsulinHistoryWidget()),
          wrap(const MealHistoryWidget()),
          wrap(const FoodListWidget(withCarbCalc: false)),
          wrap(const SettingsWidget()),
        ],
      ),
      bottomNavigationBar: _bottomNavigation(),
    );
  }

  IconButton _createMealButton() {
    return IconButton(
      onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: const Text("Create an entry")),
              body: MealFormWidget(
                meal: Meal(sugarLevel: Sugar(), insulin: Insulin(), food: <Food>[]),
              ),
            ),
          ),
        );
      },
      icon: const Icon(Icons.fastfood_outlined),
    );
  }

  IconButton _createMeasurementEntryButton() {
    return IconButton(
      onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: const Text("Create an entry")),
              body: const InsulinFormWidget(),
            ),
          ),
        );
      },
      icon: const Icon(IconConstants.sugar),
    );
  }

  IconButton _createFoodItemButton() {
    return IconButton(
      onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: const Text("Create a food item")),
              body: FoodFormWidget(food: Food(foodCategory: FoodCategory(name: "Unknown"))),
            ),
          ),
        );
        if (mounted) setState(() {});
      },
      icon: const Icon(Icons.food_bank_outlined),
    );
  }

  Widget _bottomNavigation() {
    return BottomNavigationBar(
      landscapeLayout: BottomNavigationBarLandscapeLayout.spread,
      type: BottomNavigationBarType.shifting,
      currentIndex: _tabController.index,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(IconConstants.sugar),
          label: "Sugars",
          backgroundColor: Colors.black,
        ),
        BottomNavigationBarItem(
          icon: Icon(IconConstants.insulin),
          label: "Insulin",
          backgroundColor: Colors.black,
        ),
        BottomNavigationBarItem(
          icon: Icon(IconConstants.meal),
          label: "Meals",
          backgroundColor: Colors.black,
        ),
        BottomNavigationBarItem(
          icon: Icon(IconConstants.food),
          label: "Foods",
          backgroundColor: Colors.black,
        ),
        BottomNavigationBarItem(
          icon: Icon(IconConstants.settings),
          label: "Settings",
          backgroundColor: Colors.black,
        ),
      ],
      onTap: (index) => setState(() => _tabController.animateTo(index)),
    );
  }
}
