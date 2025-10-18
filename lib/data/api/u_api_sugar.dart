import 'package:sugar_tracker/data/models/m_sugar.dart';
import 'package:sugar_tracker/data/api/u_db.dart';

class SugarAPI {
  static Future<int> insert(Sugar sugar) async => await DB.insert("sugar", sugar.toMap());
  static Future<int> update(Sugar sugar) async {
    return await DB.db.update("sugar", sugar.toMap(), where: "id = ?", whereArgs: [sugar.id]);
  }

  static Future<int> delete(Sugar sugar) async => await DB.delete("sugar", sugar.id);
  static Future<List<Sugar>> selectAll() async {
    List<Map<String, dynamic>> results = await DB.select("sugar");
    return results.map((map) => Sugar.fromMap(map)).toList();
  }

  static Future<Sugar?> selectById(int id) async {
    List<Map<String, dynamic>> results =
        await DB.db.query("sugar", where: "id = ?", whereArgs: [id]);
    if (results.isNotEmpty) return Sugar.fromMap(results.first);
    return null;
  }

  static Future<Sugar?> selectByDate(DateTime date) async {
    List<Map<String, dynamic>> results =
        await DB.db.query("sugar", where: "date = ?", whereArgs: [date.toIso8601String()]);
    if (results.isNotEmpty) return Sugar.fromMap(results.first);
    return null;
  }

  static Future<String> export() async {
    List<Map<String, dynamic>> results = await DB.select("sugar");
    String output = "";
    for (Map<String, dynamic> map in results) {
      output +=
          "INSERT INTO sugar VALUES(${map["id"]}, ${map["sugar"]}, '${map["date"]}', '${map["notes"]}');\n";
    }
    return output;
  }
}
