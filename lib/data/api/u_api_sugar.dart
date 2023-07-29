// api for inserting, updating, deleting, and selecting data from sugar table in db

import 'package:sugar_tracker/data/api/u_db.dart';
import 'package:sugar_tracker/data/models/m_sugar.dart';

class SugarAPI {
  // insert sugar entry into db
  static Future<int> insert(Sugar sugar) async {
    return await DB.db.insert("sugar", sugar.toMap());
  }

  // update sugar entry in db
  static Future<int> update(Sugar sugar) async {
    return await DB.db.update("sugar", sugar.toMap(), where: "id = ?", whereArgs: [sugar.id]);
  }

  // delete sugar entry from db
  static Future<int> delete(Sugar sugar) async {
    return await DB.delete("sugar", sugar.id ?? -1);
  }

  // select all sugar entries from db
  static Future<List<Sugar>> selectAll() async {
    List<Map<String, dynamic>> results = await DB.select("sugar");
    return results.map((map) => Sugar.fromMap(map)).toList();
  }

  // select sugar entry from db by id
  static Future<Sugar?> selectById(int id) async {
    List<Map<String, dynamic>> results =
        await DB.db.query("sugar", where: "id = ?", whereArgs: [id]);
    if (results.isNotEmpty) {
      return Sugar.fromMap(results.first);
    }
    return null;
  }
}
