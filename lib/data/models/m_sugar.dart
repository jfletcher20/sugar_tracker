import 'package:sugar_tracker/presentation/mixins/mx_date_parser.dart';

class Sugar with DateParserMixin {
  int id = -1;
  double level = 0;
  DateTime? datetime;
  String notes = "";

  static List<String> get columns => ["id", "sugar", "date", "notes"];

  Sugar({this.id = -1, this.level = 0, this.datetime, this.notes = ""});

  Sugar copyWith({int? id, double? level, DateTime? datetime, String? notes}) {
    return Sugar(
      id: id ?? this.id,
      level: level ?? this.level,
      datetime: datetime ?? this.datetime,
      notes: notes ?? this.notes,
    );
  }

  String get time {
    String hour = datetime!.hour.toString();
    String minute = datetime!.minute.toString();
    if (hour.length == 1) hour = "0$hour";
    if (minute.length == 1) minute = "0$minute";
    return "$hour:$minute";
  }

  String get date => parseDate(datetime ?? DateTime.now());

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
