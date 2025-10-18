import 'package:sugar_tracker/presentation/mixins/mx_date_parser.dart';
import 'package:sugar_tracker/data/models/enums/e_insulin_category.dart';

class Insulin with DateParserMixin {
  int id = -1;
  String name = "Unknown";
  DateTime? datetime;
  int units = 0;
  InsulinCategory category = InsulinCategory.bolus;
  String notes = "";

  String get date => parseDate(datetime ?? DateTime.now());

  String get time {
    DateTime date = datetime ?? DateTime.now();
    String minute = date.minute.toString();
    if (minute.length == 1) {
      minute = "0$minute";
    }
    String hour = date.hour.toString();
    if (hour.length == 1) {
      hour = "0$hour";
    }
    return "$hour:$minute";
  }

  Insulin({
    this.id = -1,
    this.name = "Unknown",
    this.datetime,
    this.units = 0,
    this.category = InsulinCategory.bolus,
    this.notes = "",
  });

  Insulin copyWith({
    int? id,
    String? name,
    DateTime? datetime,
    int? units,
    InsulinCategory? category,
    String? notes,
  }) {
    return Insulin(
      id: id ?? this.id,
      name: name ?? this.name,
      datetime: datetime ?? this.datetime,
      units: units ?? this.units,
      category: category ?? this.category,
      notes: notes ?? this.notes,
    );
  }

  Insulin.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    name = map['name'];
    datetime = DateTime.parse(map['date']);
    units = map['units'];
    category = InsulinCategory.values[map['insulin_category'] ?? 0];
    notes = map['notes'];
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id == -1 ? null : id;
    data['name'] = name;
    data['date'] = datetime.toString();
    data['units'] = units;
    data['insulin_category'] = category.index;
    data['notes'] = notes;
    return data;
  }

  String get info {
    String output = "$units units of $name (${category.name}) taken at $time, $date";
    output += notes.isNotEmpty ? "\n$notes" : "";
    return output;
  }

  String get unitsDisplay {
    if (id == -1) return "";
    if (units == 0) return "";
    return units.toString();
  }

  @override
  String toString() => "$units of $name";
}
