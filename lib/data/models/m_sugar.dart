/* 
      String sugarTable = "CREATE TABLE sugar("
          "id INTEGER PRIMARY KEY AUTOINCREMENT,"
          "sugar REAL,"
          "date TEXT,"
          "notes TEXT,"
          ")"; */

class Sugar {
  int id = -1;
  double level = 0;
  DateTime? datetime;
  String notes = "";

  static List<String> get columns => ["id", "sugar", "date", "notes"];

  Sugar({this.id = -1, this.level = 0, this.datetime, this.notes = ""});

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
    DateTime local = datetime ?? DateTime.now();
    if (local.day == DateTime.now().day) {
      return "Today";
    } else if (local.day == DateTime.now().subtract(const Duration(days: 1)).day) {
      return "Yesterday";
    } /* else if in the past 7 days return the weekday name like Sunday, Monday, Tuesday...*/ else {
      // check that local day is within the past 7 days
      if (local.isAfter(DateTime.now().subtract(const Duration(days: 7)))) {
        switch (local.weekday) {
          case 1:
            return "Monday";
          case 2:
            return "Tuesday";
          case 3:
            return "Wednesday";
          case 4:
            return "Thursday";
          case 5:
            return "Friday";
          case 6:
            return "Saturday";
          case 7:
            return "Sunday";
          default:
            return "${local.day}.${local.month}.${local.year}";
        }
      } else {
        return "${local.day}.${local.month}.${local.year}";
      }
    }
  }

  Sugar.fromMap(Map<String, dynamic> map) {
    id = map["id"];
    level = map["sugar"];
    datetime = DateTime.parse(map["date"]);
    notes = map["notes"];
  }

  String get info {
    return "$level at $time on $date";
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id == -1 ? null : id,
      "sugar": level,
      "date": datetime?.toIso8601String(),
      "notes": notes,
    };
  }

  @override
  String toString() {
    return "$level";
  }
}
