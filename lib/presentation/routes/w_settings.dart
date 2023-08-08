import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sugar_tracker/data/models/m_meal.dart';
import 'package:sugar_tracker/data/preferences.dart';
import 'package:sugar_tracker/presentation/widgets/w_table_editor.dart';

class SettingsWidget extends StatefulWidget {
  const SettingsWidget({super.key});

  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  bool dateAsDayOfWeek = true;
  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    var bgColor = Theme.of(context).scaffoldBackgroundColor;
    var background = SettingsThemeData(settingsListBackground: bgColor);
    dateAsDayOfWeek = Profile.dateAsDayOfWeek;
    DateTime now = DateTime.now();
    DateTime yesterday = now.subtract(const Duration(days: 1));
    DateTime dayBeforeYesterday = now.subtract(const Duration(days: 2));
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SettingsList(
        darkTheme: background,
        shrinkWrap: true,
        sections: [
          SettingsSection(
            title: settingsSectionTitle("Data", textTheme),
            tiles: [
              SettingsTile.switchTile(
                title: const Text("Date format"),
                description: Text(
                  dateAsDayOfWeek
                      ? "Today, Yesterday, ${dayName(dayBeforeYesterday.weekday)}"
                      : "${now.day}.${now.month}.${now.year}, ${yesterday.day}.${yesterday.month}.${yesterday.year}",
                ),
                leading:
                    Icon(dateAsDayOfWeek ? Icons.calendar_month : Icons.calendar_month_outlined),
                onToggle: (value) {
                  Profile.dateAsDayOfWeek = !dateAsDayOfWeek;
                  setState(() => dateAsDayOfWeek = !dateAsDayOfWeek);
                },
                initialValue: !dateAsDayOfWeek,
                activeSwitchColor: Colors.red,
              ),
              _profileTile(),
              SettingsTile(
                title: const Text("Table editor"),
                leading: const Icon(Icons.table_chart),
                description: const Text(
                  "Advanced settings. Do not touch if you don't know what you're doing, you could delete all the data in the app accidentally.",
                ),
                onPressed: (context) => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const TableEditorWidget(),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  String dayName(int weekday) {
    switch (weekday) {
      case 1:
        return "Monday";
      case 2:
        return "Tuesday";
      case 3:
        return "Wednesday";
      case 4:
        return "Thursday";
      case 5:
        return "Friday";
      case 6:
        return "Saturday";
      case 7:
        return "Sunday";
    }
    return "";
  }

  RichText settingsSectionTitle(String title, TextTheme textTheme) {
    return RichText(text: TextSpan(text: title, style: textTheme.titleLarge));
  }

  SettingsTile _profileTile() {
    return SettingsTile(
      title: const Text("Profile"),
      leading: const Icon(Icons.person),
      onPressed: (context) async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        double storedWeight = prefs.getDouble("weight") ?? 60;
        TextEditingController weight = TextEditingController(
          text: storedWeight > 0
              ? storedWeight == storedWeight.round()
                  ? storedWeight.toInt().toString()
                  : storedWeight.toString()
              : "",
        );
        List<double> storedDividers = prefs
                .getStringList("dividers")
                ?.map(
                  (e) => double.parse(e),
                )
                .toList() ??
            [10, 10, 10, 10, 10];
        List<TextEditingController> dividers = List.from(
          storedDividers.map(
            (e) => TextEditingController(
              text: e > 0
                  ? e == e.round()
                      ? e.toInt().toString()
                      : e.toString()
                  : "",
            ),
          ),
        );
        await profileDialog(weight, dividers);
      },
    );
  }

  Future<dynamic> profileDialog(
    TextEditingController weight,
    List<TextEditingController> dividers,
  ) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Profile"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: weight,
                // add label at end saying "kg" for kilograms, and hint text should be "Weight"
                decoration: const InputDecoration(
                  labelText: "Weight",
                  suffixText: "kg",
                  suffixStyle: TextStyle(color: Colors.white),
                ),
                inputFormatters: limitDecimals,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              for (int i = 0; i < dividers.length; i++)
                TextField(
                  controller: dividers[i],
                  decoration: InputDecoration(
                    labelText: MealCategory.values[i].name.substring(0, 1).toUpperCase() +
                        MealCategory.values[i].name.substring(1),
                    hintText: "Divider for ${MealCategory.values[i].name}",
                    labelStyle: TextStyle(color: mealCategoryColor(MealCategory.values[i])),
                  ),
                  // ensure input is a number of at least 1
                  inputFormatters: limitDecimals,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              bool showWarning = false;
              List<String> offenders = [];
              for (TextEditingController divider in dividers) {
                if (divider.text == "" || double.parse(divider.text) < 1) {
                  divider.text = "1";
                  offenders.add(MealCategory.values[dividers.indexOf(divider)].name);
                  showWarning = true;
                }
              }
              if (showWarning) {
                String warning = "Dividers must be at least 1";
                String mealCategories = offenders.join(", ");
                String plural = offenders.length > 1 ? "s" : "";
                String warningText = "$warning (set divider$plural for $mealCategories to 1)";
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(warningText),
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
              await Profile.setWeight(double.parse(weight.text == "" ? "60" : weight.text));
              await Profile.setDividers(
                dividers.map((e) => e.text.toString()).toList() as List<String>,
              );
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  List<TextInputFormatter> get limitDecimals {
    return <TextInputFormatter>[
      LengthLimitingTextInputFormatter(5),
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
          if (newValue.text.split(".")[0].length > 3) {
            return oldValue;
          } else if (newValue.text.split(".")[1].length > 1) {
            return oldValue;
          }
        } else {
          if (newValue.text.length > 3) {
            return oldValue;
          }
        }
        return newValue;
      }),
    ];
  }
}
