// insulin model has id, name, datetime, type (0=bolus, 1=basal), and notes
// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:sugar_tracker/data/preferences.dart';

enum InsulinCategory {
  bolus,
  basal;

  Color get color => this == InsulinCategory.bolus ? Colors.deepOrange : Colors.lightGreen;
  IconData get icon => this == InsulinCategory.bolus ? Icons.fast_forward : Icons.slow_motion_video;
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
    if (!Profile.dateAsDayOfWeek) return "${local.day}.${local.month}.${local.year}";
    if (local.day == DateTime.now().day &&
        local.month == DateTime.now().month &&
        local.year == DateTime.now().year)
      return "Today";
    else if (local.day == DateTime.now().subtract(const Duration(days: 1)).day &&
        local.month == DateTime.now().subtract(const Duration(days: 1)).month &&
        local.year == DateTime.now().subtract(const Duration(days: 1)).year)
      return "Yesterday";
    /* else if in the past 7 days return the weekday name like Sunday, Monday, Tuesday...*/ else {
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
