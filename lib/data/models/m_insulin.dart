// insulin model has id, name, datetime, type (0=bolus, 1=basal), and notes
/// Bolus is fast-acting, basal is slow-acting insulin.
enum InsulinCategory {
  /// Bolus is fast-acting insulin.
  bolus,

  /// Basal is slow-acting insulin.
  basal
}

class Insulin {
  int id = -1;
  String name = "Unknown";
  DateTime? datetime;
  int units = 0;
  InsulinCategory insulinCategory = InsulinCategory.bolus;
  String notes = "";

  Insulin({
    this.id = -1,
    this.name = "Unknown",
    this.datetime,
    this.units = 0,
    this.insulinCategory = InsulinCategory.bolus,
    this.notes = "",
  });

  Insulin.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    name = map['name'];
    datetime = DateTime.parse(map['date']);
    units = map['units'];
    insulinCategory = InsulinCategory.values[map['insulin_category'] ?? 0];
    notes = map['notes'];
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id == -1 ? null : id;
    data['name'] = name;
    data['date'] = datetime.toString();
    data['units'] = units;
    data['insulin_category'] = insulinCategory.index;
    data['notes'] = notes;
    return data;
  }

  @override
  String toString() {
    return "$units";
  }
}
