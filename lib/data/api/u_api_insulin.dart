// api for inserting, updating, deleting, and selecting data from insulin table in db
import 'package:sugar_tracker/data/api/u_db.dart';
import 'package:sugar_tracker/data/models/m_insulin.dart';

class InsulinAPI {
  static Future<int> insert(Insulin insulin) async {
    return await DB.insert("insulin", insulin.toMap());
  }

  static Future<int> update(Insulin insulin) async {
    return await DB.update("insulin", insulin.toMap());
  }

  static Future<int> delete(Insulin insulin) async {
    return await DB.delete("insulin", insulin.id);
  }

  static Future<List<Insulin>> selectAll() async {
    List<Map<String, dynamic>> results = await DB.select("insulin");
    return results.map((map) => Insulin.fromMap(map)).toList();
  }

  static Future<Insulin?> selectById(int id) async {
    List<Map<String, dynamic>> results =
        await DB.db.query("insulin", where: "id = ?", whereArgs: [id]);
    if (results.isNotEmpty) {
      return Insulin.fromMap(results.first);
    }
    return null;
  }

  static Future<Insulin?> selectByDate(DateTime date) async {
    List<Map<String, dynamic>> results =
        await DB.db.query("insulin", where: "date = ?", whereArgs: [date.toString()]);
    if (results.isNotEmpty) return Insulin.fromMap(results.first);
    return null;
  }

  static Future<String> export() async {
    List<Map<String, dynamic>> results = await DB.select("insulin");
    String output = "";
    for (Map<String, dynamic> map in results) {
      output +=
          "INSERT INTO insulin VALUES(${map["id"]}, '${map["name"]}', '${map["date"]}', ${map["units"]}, '${map["insulin_category"]}', '${map["notes"]}');\n";
    }
    return output;
  }
}
