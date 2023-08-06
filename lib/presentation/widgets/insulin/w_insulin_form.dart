import 'package:sugar_tracker/data/api/u_api_insulin.dart';
import 'package:sugar_tracker/data/api/u_api_meal.dart';
import 'package:sugar_tracker/data/api/u_api_sugar.dart';
import 'package:sugar_tracker/data/models/m_insulin.dart';
import 'package:sugar_tracker/data/models/m_meal.dart';
import 'package:sugar_tracker/data/models/m_sugar.dart';
import 'package:sugar_tracker/data/preferences.dart';
import 'package:sugar_tracker/presentation/widgets/w_datetime_selector.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InsulinFormWidget extends StatefulWidget {
  final Insulin? insulin;
  final Sugar? sugar;
  final bool useAsTemplate;

  const InsulinFormWidget({super.key, this.insulin, this.sugar, this.useAsTemplate = false});

  @override
  State<InsulinFormWidget> createState() => _InsulinFormWidgetState();

  // ignore: library_private_types_in_public_api
  static _InsulinFormWidgetState _of(BuildContext context) {
    return context.findAncestorStateOfType<_InsulinFormWidgetState>()!;
  }
}

class _InsulinFormWidgetState extends State<InsulinFormWidget> {
  // text controllers for each text field
  late final TextEditingController _sugarLevelController;
  late final TextEditingController _insulinController;
  late Insulin insulin;
  late Sugar sugarLevel;

  GlobalKey<DateTimeSelectorWidgetState> dateTimeSelectorKey = GlobalKey();
  // form key
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    insulin = widget.insulin ?? Insulin();
    sugarLevel = widget.sugar ?? Sugar();
    initSugarLevel();
    _insulinController =
        TextEditingController(text: insulin.units > 0 ? insulin.units.toString() : "");
    _sugarLevelController = TextEditingController();
    if (widget.useAsTemplate) {
      sugarLevel.id = -1;
      insulin.id = -1;
    }
  }

  void initSugarLevel() async {
    List<Sugar> sugarLevels = await SugarAPI.selectAll();
    if (sugarLevels.isNotEmpty) {
      try {
        sugarLevel = sugarLevels.firstWhere((s) => s.datetime == insulin.datetime);
      } catch (e) {
        sugarLevel = Sugar(notes: "");
      }
    } else {
      sugarLevel = Sugar(notes: "");
    }
    String startingValue = sugarLevel.level > 0 ? sugarLevel.level.toString() : "";
    _sugarLevelController.text = startingValue;
    setState(() {});
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
              DateTimeSelectorWidget(key: dateTimeSelectorKey, initialDateTime: insulin.datetime),
              const SizedBox(height: 24),
              FutureBuilder(
                future: loadInsulinData(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return _insulinCategorySwitchTile(insulin.category);
                  }
                  return _insulinCategorySwitchTile(insulin.category);
                },
              ),
              const SizedBox(height: 24),
              _sugarLevelInput(),
              const SizedBox(height: 24),
              _insulinInput(),
              const SizedBox(height: 24),
              _submitInsulinButton(),
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
        "Insulin entry",
        style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Future<InsulinCategory> loadInsulinData() async {
    if (insulin.id != -1 || widget.useAsTemplate) {
      return insulin.category;
    }
    List<Insulin> insulinData = await InsulinAPI.selectAll();
    InsulinCategory result = InsulinCategory.bolus;
    // if datetimeselectorkey's time is between 9:55pm and 10:35pm, set category to basal
    if ((dateTimeSelectorKey.currentState!.datetime.hour >= 21 &&
            dateTimeSelectorKey.currentState!.datetime.minute >= 55) &&
        (dateTimeSelectorKey.currentState!.datetime.hour <= 22 &&
            dateTimeSelectorKey.currentState!.datetime.minute <= 15)) {
      result = InsulinCategory.basal;
      insulin.category = result;
      insulin.name = insulinData.firstWhere((i) => i.category == result).name;
      return result;
    }
    if (insulinData.isEmpty) {
      return result;
    }
    insulinData.sort((a, b) => a.date.compareTo(b.date));
    insulinData = insulinData.reversed.toList();
    insulin.name = insulinData.firstWhere((element) => element.category == result).name;
    return result;
  }

  final GlobalKey<_InsulinCategorySelectorState> _insulinCategorySelectorKey = GlobalKey();
  _InsulinCategorySelector _insulinCategorySwitchTile(InsulinCategory category) {
    return _InsulinCategorySelector(key: _insulinCategorySelectorKey, category: category);
  }

  ElevatedButton _submitInsulinButton() {
    return ElevatedButton(
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          _prepareDateTime();
          _prepareInsulinCategory();
          await _saveData();
          Future.delayed(const Duration(milliseconds: 100), () {
            if (context.mounted) Navigator.pop(context, insulin);
          });
        }
      },
      child: const Text("Submit"),
    );
  }

  void _prepareDateTime() {
    insulin.datetime = sugarLevel.datetime = dateTimeSelectorKey.currentState!.datetime;
  }

  void _prepareInsulinCategory() {
    insulin.category = _insulinCategorySelectorKey.currentState!.category;
  }

  Future<void> _saveData() async {
    sugarLevel.id = await _saveSugarLevel();
    insulin.id = await _saveInsulin();
    return;
  }

  Future<int> _saveSugarLevel() async {
    if (sugarLevel.level > 0) {
      int sugarId = sugarLevel.id;
      if (widget.useAsTemplate || sugarId == -1) {
        sugarLevel.id = -1;
        sugarId = await SugarAPI.insert(sugarLevel);
      } else {
        await SugarAPI.update(sugarLevel);
      }
      return sugarId;
    } else {
      if (sugarLevel.id != -1) {
        //show confirmation dialog asking if they want to delete sugar level
        bool? delete = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Delete sugar level?"),
            content: const Text("Sugar level is 0, do you want to delete it?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("No"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Delete"),
              ),
            ],
          ),
        );
        if (delete != null && delete) {
          // ignore: use_build_context_synchronously
          bool? confirmed = await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Are you sure?"),
              content: const Text("This action cannot be undone."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("No"),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text("Delete"),
                ),
              ],
            ),
          );
          if (confirmed != null && confirmed) {
            // check if sugar level is in a meal
            Meal meal = await MealAPI.selectBySugarId(sugarLevel);
            if (meal.id != -1) {
              // show dialog saying couldn't delete
              if (context.mounted) {
                await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Cannot delete sugar level"),
                    content: const Text("Sugar level is in a meal, cannot delete it"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Ok"),
                      ),
                    ],
                  ),
                );
              }
            } else {
              await SugarAPI.delete(sugarLevel);
            }
          }
        }
      }
    }
    return -1;
  }

  Future<int> _saveInsulin() async {
    int insulinId = insulin.id;
    if (widget.useAsTemplate || insulinId == -1) {
      try {
        insulinId = await InsulinAPI.insert(insulin);
      } catch (e) {
        await InsulinAPI.update(insulin);
      }
    } else {
      await InsulinAPI.update(insulin);
    }
    return insulinId;
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
          onChanged: (value) {
            sugarLevel.level = double.tryParse(value) ?? 0;
            setState(() {});
          },
          onSaved: (value) => sugarLevel.level = double.tryParse(value ?? "0") ?? 0,
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

  int get recommendedCorrection {
    int correctionLimit = (Profile.weight * 0.1).floor();
    int lowerBorder = 8;
    int correction = 0;
    if (sugarLevel.level > lowerBorder) {
      correction = ((sugarLevel.level - lowerBorder) / 2).round();
      correction > correctionLimit ? correction = correctionLimit : null;
    }
    return correction;
  }

  Widget _insulinInput() {
    String recommended = "Insulin units";
    if (recommendedCorrection > 0) {
      recommended += " ($recommendedCorrection advised)";
    }
    return Stack(
      children: [
        TextFormField(
          decoration: InputDecoration(labelText: recommended),
          controller: _insulinController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(2),
          ],
          onChanged: (value) => insulin.units = int.tryParse(value) ?? 0,
          onSaved: (value) => insulin.units = int.tryParse(value ?? "0") ?? 0,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
            child: IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () async {
                showInsulinEditor();
              },
            ),
          ),
        )
      ],
    );
  }

  Future showSugarLevelNotesEditor() {
    final TextEditingController sugarLevelNotesController =
        TextEditingController(text: sugarLevel.notes);
    Widget subtitle;
    subtitle = Column(
      children: [
        TextFormField(
          controller: sugarLevelNotesController,
          decoration: const InputDecoration(labelText: "Sugar level notes"),
          keyboardType: TextInputType.multiline,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            if (sugarLevelNotesController.text != sugarLevel.notes) {
              sugarLevel.notes = sugarLevelNotesController.text;
              Navigator.pop(context, sugarLevel);
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
          sugarLevelNotesController.text = sugarLevel.notes;
          return true;
        },
        child: ListTile(subtitle: subtitle),
      ),
    );
  }

  Future showInsulinEditor() {
    final TextEditingController insulinNameController = TextEditingController(
      text: _insulinCategorySelectorKey.currentState!.category == InsulinCategory.bolus
          ? "Fiasp"
          : "Tresiba",
    );
    final TextEditingController insulinNotesController = TextEditingController(text: insulin.notes);
    Widget subtitle;
    subtitle = Column(
      children: [
        _insulinNameInput(insulinNameController),
        const SizedBox(height: 24),
        _insulinNotesInput(insulinNotesController),
        const SizedBox(height: 24),
        _saveButton(insulinNameController, insulinNotesController),
      ],
    );
    return showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: _modalDecoration,
      builder: (context) => WillPopScope(
        onWillPop: () async {
          insulinNameController.text = insulin.name;
          insulinNotesController.text = insulin.notes;
          return true;
        },
        child: ListTile(subtitle: subtitle),
      ),
    );
  }

  ElevatedButton _saveButton(
    TextEditingController insulinNameController,
    TextEditingController insulinNotesController,
  ) {
    return ElevatedButton(
      onPressed: () {
        if (insulinNotesController.text != insulin.notes ||
            insulinNameController.text != insulin.name) {
          insulin.notes = insulinNotesController.text;
          insulin.name = insulinNameController.text;
          Navigator.pop(context, insulin);
        } else {
          Navigator.pop(context);
        }
      },
      child: const Text("Save"),
    );
  }

  TextFormField _insulinNameInput(TextEditingController insulinNameController) {
    return TextFormField(
      controller: insulinNameController,
      decoration: const InputDecoration(labelText: "Insulin name"),
      keyboardType: TextInputType.multiline,
    );
  }

  TextFormField _insulinNotesInput(TextEditingController insulinNotesController) {
    return TextFormField(
      controller: insulinNotesController,
      decoration: const InputDecoration(labelText: "Insulin notes"),
      keyboardType: TextInputType.multiline,
      maxLines: 3,
      minLines: 1,
    );
  }

  final RoundedRectangleBorder _modalDecoration = const RoundedRectangleBorder(
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(32),
      topRight: Radius.circular(32),
    ),
  );
}

class _InsulinCategorySelector extends StatefulWidget {
  final InsulinCategory category;
  const _InsulinCategorySelector({super.key, this.category = InsulinCategory.bolus});

  @override
  State<_InsulinCategorySelector> createState() => _InsulinCategorySelectorState();
}

class _InsulinCategorySelectorState extends State<_InsulinCategorySelector> {
  InsulinCategory category = InsulinCategory.bolus;

  @override
  void initState() {
    super.initState();
    category = widget.category;
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      onChanged: (value) {
        value ? category = InsulinCategory.basal : category = InsulinCategory.bolus;
        setState(() {});
      },
      value: category == InsulinCategory.basal,
      activeColor: insulinCategoryColor(category),
      inactiveThumbColor: insulinCategoryColor(category),
      tileColor: Colors.redAccent.withOpacity(0.35),
      title: FutureBuilder(
        future: () async {
          List<Insulin> insulinData = await InsulinAPI.selectAll();
          if (insulinData.isEmpty) {
            return ("Bolus", "Basal");
          }
          insulinData.sort((a, b) => a.date.compareTo(b.date));
          String bolus = insulinData.firstWhere((i) => i.category == InsulinCategory.bolus).name;
          String basal = insulinData.firstWhere((i) => i.category == InsulinCategory.basal).name;
          return (bolus, basal);
        }(),
        initialData: ("Bolus", "Basal"),
        builder: (context, snapshot) {
          (String bolus, String basal) data = ("Bolus", "Basal");
          if (snapshot.hasData) {
            data = snapshot.data as (String, String);
            return Text(
              category.index == 0 ? data.$1 : data.$2,
              style: Theme.of(context).textTheme.titleLarge,
            );
          }
          return Text(
            category.index == 0 ? data.$1 : data.$2,
            style: Theme.of(context).textTheme.titleLarge,
          );
        },
      ),
    );
  }
}
