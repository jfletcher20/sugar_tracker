/* 
      String sugarTable = "CREATE TABLE sugar("
          "id INTEGER PRIMARY KEY AUTOINCREMENT,"
          "sugar REAL,"
          "date TEXT,"
          "notes TEXT,"
          ")"; */

class Sugar {
  int id = -1;
  double sugar = 0;
  DateTime? datetime;
  String? notes;

  static List<String> get columns => ["id", "sugar", "date", "notes"];

  Sugar({this.id = -1, this.sugar = 0, this.datetime, this.notes});

  Sugar.fromMap(Map<String, dynamic> map) {
    id = map["id"];
    sugar = map["sugar"];
    datetime = DateTime.parse(map["date"]);
    notes = map["notes"];
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "sugar": sugar,
      "date": datetime?.toIso8601String(),
      "notes": notes,
    };
  }

  @override
  String toString() {
    return "$sugar";
  }
}
