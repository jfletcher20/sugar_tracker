// insulin model has id, name, datetime, type (0=bolus, 1=basal), and notes
import 'package:flutter/material.dart';

/// Bolus is fast-acting, basal is slow-acting insulin.
enum InsulinCategory {
  /// Bolus is fast-acting insulin.
  bolus,

  /// Basal is slow-acting insulin.
  basal
}

Color insulinCategoryColor(InsulinCategory category) {
  return InsulinCategory.values.indexOf(category) == 0 ? Colors.orange : Colors.lightGreen[400]!;
}

class Insulin {
  int id = -1;
  String name = "Unknown";
  DateTime? datetime;
  int units = 0;
  InsulinCategory category = InsulinCategory.bolus;
  String notes = "";

  String get date {
    DateTime date = datetime ?? DateTime.now();
    return "${date.day}.${date.month}.'${date.year.toString().substring(2)}";
  }

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

  @override
  String toString() {
    return "$units of $name";
  }
}
