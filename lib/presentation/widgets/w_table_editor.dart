import 'package:flutter/material.dart';
import 'package:sugar_tracker/data/api/u_db.dart';

class TableEditorWidget extends StatefulWidget {
  const TableEditorWidget({super.key});

  @override
  State<TableEditorWidget> createState() => _TableEditorWidgetState();
}

class _TableEditorWidgetState extends State<TableEditorWidget> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        await dialog();
        if (context.mounted) setState(() {});
      },
      icon: const Icon(Icons.table_chart),
    );
  }

  TextEditingController tableNameController = TextEditingController();
  Future<dynamic> dialog() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text("Table editor"),
          _debugButton(),
        ]),
        content: TextField(
          controller: tableNameController,
          decoration: const InputDecoration(hintText: "Table Name"),
        ),
        actions: [
          _getAll(),
          _setAll(),
          _deleteAll(),
        ],
      ),
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
        if (context.mounted) Navigator.pop(context);
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
              if (context.mounted) Navigator.pop(context);
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
      onChanged: (value) => setState(() => onlyNullValues = value),
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
    print(tableNames);
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
