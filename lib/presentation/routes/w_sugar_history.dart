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
          data.sort((a, b) => a.datetime!.compareTo(b.datetime!));
          data = data.reversed.toList();
          var columns = Sugar.columns.map((e) => DataColumn(label: Text(e))).toList();
          columns = columns.getRange(1, 4).toList();
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: DataTable(
                  columns: columns,
                  rows: data
                      .map((e) => DataRow(
                            cells: [
                              // DataCell(Text(e.id.toString())),
                              DataCell(Text(e.sugar.toString())),
                              DataCell(Text("${e.time} ${e.date}")),
                              DataCell(Text(e.notes.toString())),
                            ],
                          ))
                      .toList()),
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      }),
    );
  }
}
