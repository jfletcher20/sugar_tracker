import 'package:sugar_tracker/data/api/u_api_sugar.dart';
import 'package:sugar_tracker/data/models/m_sugar.dart';
import 'package:flutter/material.dart';

class SugarHistoryWidget extends StatefulWidget {
  const SugarHistoryWidget({super.key});

  @override
  State<SugarHistoryWidget> createState() => _SugarHistoryWidgetState();
}

class _SugarHistoryWidgetState extends State<SugarHistoryWidget> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: SugarAPI.selectAll(),
      builder: ((context, snapshot) {
        if (snapshot.hasData) {
          List<Sugar> data = snapshot.data as List<Sugar>;
          return DataTable(
              columns: Sugar.columns.map((e) => DataColumn(label: Text(e))).toList(),
              rows: data
                  .map((e) => DataRow(
                        cells: [
                          DataCell(Text(e.id.toString())),
                          DataCell(Text(e.sugar.toString())),
                          DataCell(Text(e.insulin.toString())),
                          DataCell(Text(e.date.toString())),
                          DataCell(Text(e.notes.toString())),
                        ],
                      ))
                  .toList());
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      }),
    );
  }
}
