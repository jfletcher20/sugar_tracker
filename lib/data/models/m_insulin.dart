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
  return InsulinCategory.values.indexOf(category) == 0 ? Colors.deepOrange : Colors.lightGreen;
}

IconData insulinCategoryIcon(InsulinCategory category) {
  return InsulinCategory.values.indexOf(category) == 0
      ? Icons.fast_forward
      : Icons.slow_motion_video;
}

class Insulin {
  int id = -1;
  String name = "Unknown";
  DateTime? datetime;
  int units = 0;
  InsulinCategory category = InsulinCategory.bolus;
  String notes = "";

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
