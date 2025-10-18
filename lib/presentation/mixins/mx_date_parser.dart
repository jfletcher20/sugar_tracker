import 'package:sugar_tracker/data/profile.dart';

mixin DateParserMixin {
  String? weekdayName(int weekday) {
    return switch (weekday) {
      1 => "Monday",
      2 => "Tuesday",
      3 => "Wednesday",
      4 => "Thursday",
      5 => "Friday",
      6 => "Saturday",
      7 => "Sunday",
      _ => null,
    };
  }

  String parseDate(DateTime date) {
    if (!Profile.dateAsDayOfWeek) return "${date.day}.${date.month}.${date.year}";
    if (date.day == DateTime.now().day &&
        date.month == DateTime.now().month &&
        date.year == DateTime.now().year)
      return "Today";
    else if (date.day == DateTime.now().subtract(const Duration(days: 1)).day &&
        date.month == DateTime.now().subtract(const Duration(days: 1)).month &&
        date.year == DateTime.now().subtract(const Duration(days: 1)).year)
      return "Yesterday";
    /* else if in the past 7 days return the weekday name like Sunday, Monday, Tuesday...*/ else {
      // check that local day is within the past 7 days
      if (date.isAfter(DateTime.now().subtract(const Duration(days: 7)))) {
        return weekdayName(date.weekday) ?? "${date.day}.${date.month}.${date.year}";
      } else {
        return "${date.day}.${date.month}.${date.year}";
      }
    }
  }
}
