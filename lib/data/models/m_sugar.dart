/* 
      String sugarTable = "CREATE TABLE sugar("
          "id INTEGER PRIMARY KEY AUTOINCREMENT,"
          "sugar REAL,"
          "date TEXT,"
          "notes TEXT,"
          ")"; */

class Sugar {
  int? id;
  double? sugar;
  DateTime? date;
  String? notes;

  static List<String> get columns => ["id", "sugar", "date", "notes"];

  Sugar({this.id, this.sugar, this.date, this.notes});

  Sugar.fromMap(Map<String, dynamic> map) {
    id = map["id"];
    sugar = map["sugar"];
    date = DateTime.parse(map["date"]);
    notes = map["notes"];
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "sugar": sugar,
      "date": date?.toIso8601String(),
      "notes": notes,
    };
  }

  @override
  String toString() {
    return "$sugar";
  }
}
