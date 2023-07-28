/* 
      String sugarTable = "CREATE TABLE sugar("
          "id INTEGER PRIMARY KEY AUTOINCREMENT,"
          "sugar REAL,"
          "insulin REAL,"
          "date TEXT,"
          "notes TEXT,"
          ")"; */

class Sugar {
  int? id;
  double? sugar;
  double? insulin;
  DateTime? date;
  String? notes;

  static List<String> get columns => ["id", "sugar", "insulin", "date", "notes"];

  Sugar({this.id, this.sugar, this.insulin, this.date, this.notes});

  Sugar.fromMap(Map<String, dynamic> map) {
    id = map["id"];
    sugar = map["sugar"];
    insulin = map["insulin"];
    date = DateTime.parse(map["date"]);
    notes = map["notes"];
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "sugar": sugar,
      "insulin": insulin,
      "date": date?.toIso8601String(),
      "notes": notes,
    };
  }

  @override
  String toString() {
    return "Sugar(id: $id, sugar: $sugar, insulin: $insulin, date: $date, notes: $notes)";
  }
}
