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
  String notes = "";

  static List<String> get columns => ["id", "sugar", "date", "notes"];

  Sugar({this.id = -1, this.sugar = 0, this.datetime, this.notes = ""});

  String get time {
    String hour = datetime!.hour.toString();
    String minute = datetime!.minute.toString();
    if (hour.length == 1) {
      hour = "0$hour";
    }
    if (minute.length == 1) {
      minute = "0$minute";
    }
    return "$hour:$minute";
  }

  String get date {
    String day = datetime!.day.toString();
    String month = datetime!.month.toString();
    String year = datetime!.year.toString();
    return "$day.$month.$year";
  }

  Sugar.fromMap(Map<String, dynamic> map) {
    id = map["id"];
    sugar = map["sugar"];
    datetime = DateTime.parse(map["date"]);
    notes = map["notes"];
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id == -1 ? null : id,
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
