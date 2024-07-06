import 'package:sugar_tracker/data/api/u_api_food.dart';
import 'package:sugar_tracker/data/api/u_api_food_category.dart';
import 'package:sugar_tracker/data/api/u_api_insulin.dart';
import 'package:sugar_tracker/data/api/u_api_meal.dart';
import 'package:sugar_tracker/data/api/u_api_sugar.dart';
import 'package:sugar_tracker/data/api/u_db.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TableEditorWidget extends StatefulWidget {
  const TableEditorWidget({super.key});

  @override
  State<TableEditorWidget> createState() => _TableEditorWidgetState();
}

class _TableEditorWidgetState extends State<TableEditorWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text("Table editor")), body: alert());
  }

  TextEditingController tableNameController = TextEditingController();
  Future<dynamic> dialog() {
    return showDialog(context: context, builder: (context) => alert());
  }

  Widget alert() {
    return AlertDialog(
      title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text("Table editor"),
        _query(),
        _debugButton(),
      ]),
      content: TextField(
        controller: tableNameController,
        decoration: const InputDecoration(hintText: "Table Name"),
      ),
      actions: [
        _export(),
        _getAll(),
        _setAll(),
        _delete(),
      ],
    );
  }

  IconButton _debugButton() {
    return IconButton(
      onPressed: () {
        debug(tableNameController);
        setState(() {});
      },
      icon: const Icon(Icons.code),
    );
  }

  IconButton _query() {
    return IconButton(
      onPressed: () async {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Execute query?"),
            content: SingleChildScrollView(child: Text(tableNameController.text)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  await DB.db.execute(tableNameController.text);
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text("Execute"),
              ),
            ],
          ),
        );
        if (context.mounted) setState(() {});
      },
      icon: const Icon(Icons.abc),
    );
  }

  TextButton _delete() {
    return TextButton(
      onPressed: () async => await _deleteDialog(),
      child: const Text("Delete"),
    );
  }

  Future _deleteDialog() {
    // show dialog with controller for id to delete
    TextEditingController idController = TextEditingController();
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete"),
        content: TextField(
          controller: idController,
          decoration: const InputDecoration(hintText: "ID"),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          _deleteAll(),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              // show confirmation dialog
              await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Confirm deletion"),
                  content: Text("Delete ${tableNameController.text} with id ${idController.text}?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () async {
                        // delete from table where id = idController.text
                        await DB.delete(
                            tableNameController.text.toLowerCase(), int.parse(idController.text));
                        if (context.mounted) Navigator.pop(context);
                      },
                      child: const Text("Delete"),
                    ),
                  ],
                ),
              );
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  TextButton _export() {
    return TextButton(
      onPressed: () async {
        String exported = "";
        switch (tableNameController.text) {
          case "food":
            exported = await FoodAPI.export();
            break;
          case "meal":
            exported = await MealAPI.export();
            break;
          case "sugar":
            exported = await SugarAPI.export();
            break;
          case "food_category":
            exported = await FoodCategoryAPI.export();
            break;
          case "insulin":
            exported = await InsulinAPI.export();
            break;
        }
        // show dialog with text in singlechildscrollview
        _exportDialog(exported);
      },
      child: const Text("Export"),
    );
  }

  Future<dynamic> _exportDialog(String exported) {
    List<String> text = exported.split("\n");
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Exported data (x${text.length - 1})"),
        content: SingleChildScrollView(
          child: Card(
            child: Column(
              children: [
                ...text
                    .map(
                      (e) => InkWell(
                          child: Text(e), onTap: () => Clipboard.setData(ClipboardData(text: e))),
                    )
                    .toList(),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_all),
            onPressed: () => Clipboard.setData(ClipboardData(text: exported)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  TextButton _getAll() {
    return TextButton(
      onPressed: () async {
        List val = await DB.select(tableNameController.text.toLowerCase());
        String output = "";
        output = val.map((e) => e.toString()).toList().join("\n\n");
        _getAllDialog(output);
      },
      child: const Text("Get"),
    );
  }

  Future<dynamic> _getAllDialog(String output) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Table Data"),
        content: SingleChildScrollView(child: Text(output)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  TextButton _setAll() {
    return TextButton(
      onPressed: () async {
        await _setAllDialog();
      },
      child: const Text("Set"),
    );
  }

  Future<dynamic> _setAllDialog() {
    TextEditingController columnController = TextEditingController();
    TextEditingController valueController = TextEditingController();
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Set column value"),
        content: SizedBox(
          height: 130,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: columnController,
                  decoration: const InputDecoration(hintText: "Column Name"),
                ),
                TextField(
                  controller: valueController,
                  decoration: const InputDecoration(hintText: "Value"),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
          TextButton(
            onPressed: () async {
              await _confirmSetAllDialog(columnController.text, valueController.text);
            },
            child: const Text("Set"),
          ),
        ],
      ),
    );
  }

  bool onlyNullValues = true;
  Future<dynamic> _confirmSetAllDialog(String column, String value) {
    SwitchListTile switchListTile = SwitchListTile(
      title: const Text("Only null values"),
      value: onlyNullValues,
      onChanged: (value) => onlyNullValues = value,
    );
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Set all values of column $column to $value?"),
        content: switchListTile,
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              // update all values for that column in the table
              // if onlyNullValues is true, only update where column value is null
              await DB.db.update(tableNameController.text.toLowerCase(), {column: value},
                  where: onlyNullValues ? "$column IS NULL" : null);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }

  TextButton _deleteAll() {
    return TextButton(
      onPressed: () async {
        await _confirmDeletionDialog();
        // ignore: use_build_context_synchronously
        if (context.mounted) Navigator.pop(context);
      },
      child: const Text("Clear"),
    );
  }

  Future<dynamic> _confirmDeletionDialog() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete all data from table ${tableNameController.text}?"),
        content: const Text("This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              await DB.db.delete(tableNameController.text.toLowerCase());
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  void debug(TextEditingController tableNameController) async {
    List tables = await DB.db.query('sqlite_master', columns: ['type', 'name']);
    tables = tables.getRange(1, tables.length).toList();
    String tableNames = "";
    for (var table in tables) {
      tableNames += table["name"] + "\n";
    }
    _tableNamesDialog(tableNames);
  }

  Future<dynamic> _tableNamesDialog(String tableNames) {
    return showDialog(
      context: context,
      builder: (context) {
        return ListView(
          children: tableNames
              .split("\n")
              .map((e) => TextButton(
                  onPressed: () {
                    tableNameController.text = e;
                    Navigator.pop(context);
                  },
                  child: Text(e)))
              .toList(),
        );
      },
    );
  }
}
