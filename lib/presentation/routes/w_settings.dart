import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sugar_tracker/data/api/u_db.dart';
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
    return SettingsList(
      darkTheme: background,
      physics: const ScrollPhysics(),
      shrinkWrap: true,
      sections: [
        SettingsSection(
          title: settingsSectionTitle("Settings and data management", textTheme),
          tiles: [
            SettingsTile.switchTile(
              title: const Text("Date format"),
              description: Text(
                dateAsDayOfWeek
                    ? "Today, Yesterday, ${dayName(dayBeforeYesterday.weekday)}"
                    : "${now.day}.${now.month}.${now.year}, ${yesterday.day}.${yesterday.month}.${yesterday.year}",
              ),
              leading: Icon(dateAsDayOfWeek ? Icons.calendar_month : Icons.calendar_month_outlined),
              onToggle: (value) {
                Profile.dateAsDayOfWeek = !dateAsDayOfWeek;
                Profile.setDateAsDayOfWeek(Profile.dateAsDayOfWeek);
                setState(() => dateAsDayOfWeek = !dateAsDayOfWeek);
              },
              initialValue: !dateAsDayOfWeek,
              activeSwitchColor: Colors.red,
            ),
            _profileTile(),
            _backupTile(),
            _loadBackupTile(),
            SettingsTile(
              title: const Text("Table editor"),
              leading: const Icon(Icons.table_chart),
              description: const Text(
                "Advanced querying tool for development. Exercise extreme caution.",
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
      description: const Text(
          "Correction = (sugar_level - 9) / 1.5 with max units of up to 10% of your body weight. "
          "Insulin = carbs / divider"),
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
              await Profile.setDividers(dividers.map((e) => e.text.toString()).toList());
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  SettingsTile _backupTile() {
    return SettingsTile(
      title: const Text("Create backup"),
      description: const Text("Save a backup to transfer your data"),
      leading: const Icon(Icons.download),
      onPressed: (context) async {
        await openFileExplorer();
      },
    );
  }

  SettingsTile _loadBackupTile() {
    return SettingsTile(
      title: const Text("Load backup"),
      description: const Text("Load a backup to restore your data"),
      leading: const Icon(Icons.upload),
      onPressed: (context) async {
        await loadBackupDialog().then((value) async {
          if (value is bool && value) {
            DB.db.isOpen ? await DB.db.close() : null;
            await DB.open();
            if (context.mounted) setState(() {});
          }
        });
      },
    );
  }

  Future<void> openFileExplorer() async {
    // Open the file picker to select a location to save the backup
    String databases = await getDatabasesPath();
    String dbName = DB.dbName; // Replace with your database name
    String databasePath = "$databases/$dbName";
    File databaseFile = File(databasePath);

    // save databaseFile to filepicker's new path
    Directory? externalDir = await getExternalStorageDirectory();

    if (externalDir == null) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Error saving backup: couldn't find external directory."
          "Check permissions and try again.",
        ),
      ));
      return;
    }

    String? result;

    try {
      result = await FilePicker.platform.saveFile();
    } catch (e) {
      if (!await FlutterFileDialog.isPickDirectorySupported()) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error saving backup: not supported for this platform.')),
        );
        return;
      } else {
        String? savePath = await FlutterFileDialog.saveFile(
          params: SaveFileDialogParams(sourceFilePath: databasePath),
        );
        String message = savePath == null
            ? "Didn't save backup."
            : "Backup for saved as ${savePath.split("/").last}.";
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
        return;
      }
    }

    if (result == null) {
      return;
    }

    try {
      await databaseFile.copy(result);
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Backup saved to $databasePath')),
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving backup: $e')),
      );
    }
  }

  Future<dynamic> loadBackupDialog() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Load backup"),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("This will overwrite all of your stored sugar tracking data."),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async => Navigator.pop(context, await loadFile()),
            child: const Text("Yes"),
          ),
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("No")),
        ],
      ),
    );
  }

  Future<bool> loadFile() async {
    // get the path of the database file
    File databaseFile = File("${(await getDatabasesPath()).toString()}/${DB.dbName}");
    // get the file that the user chose
    return FilePicker.platform.pickFiles().catchError((e) async {
      if (!(await FlutterFileDialog.isPickDirectorySupported())) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error loading backup: not supported for this platform.')),
        );
        return null;
      } else {
        // copy the file to the database path
        try {
          XFile((await FlutterFileDialog.pickFile()).toString()).saveTo(databaseFile.path);
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Backup loaded.')),
          );
          return null;
        } catch (e) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading backup: $e')),
          );
          return null;
        }
      }
    }).then((value) async {
      if (value == null) {
        return false;
      }
      File file = File(value.files.single.path!);
      try {
        await file.copy(databaseFile.path);
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup loaded.')),
        );
        return true;
      } catch (e) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading backup: $e')),
        );
        return false;
      }
    });
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
