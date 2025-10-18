import 'package:shared_preferences/shared_preferences.dart';
import 'package:sugar_tracker/data/pref_constants.dart';

class Profile {
  static bool dateAsDayOfWeek = true;
  static double weight = 60;
  static List<String> _dividers = ["10", "10", "10", "10", "10"];
  static List<double> get dividers => _dividers.map((e) => double.parse(e)).toList();
  static set dividers(List<double> newDividers) =>
      _dividers = newDividers.map((e) => e.toString()).toList();
  static Future<double> get futureWeight async {
    double storedWeight =
        (await SharedPreferences.getInstance()).getDouble(PrefConstants.weight) ?? weight;
    weight = storedWeight;
    return storedWeight;
  }

  static Future<void> setWeight(double newWeight) async {
    weight = newWeight;
    await (await SharedPreferences.getInstance()).setDouble(PrefConstants.weight, newWeight);
  }

  static Future<List<String>> get futureDividers async {
    List<String>? storedDividers =
        (await SharedPreferences.getInstance()).getStringList(PrefConstants.dividers);
    storedDividers ??= _dividers;
    // check that all dividers are at least 1
    for (int i = 0; i < storedDividers.length; i++) {
      if (double.parse(storedDividers[i]) < 1) {
        storedDividers[i] = "1";
      }
    }
    _dividers = storedDividers;
    return storedDividers;
  }

  static Future<void> setDividers(List<String> newDividers) async {
    _dividers = newDividers;
    await (await SharedPreferences.getInstance())
        .setStringList(PrefConstants.dividers, newDividers);
  }

  // set and get date format
  static Future<bool> get futureDateAsDayOfWeek async {
    bool storedDateAsDayOfWeek =
        (await SharedPreferences.getInstance()).getBool(PrefConstants.dateAsDayOfWeek) ??
            dateAsDayOfWeek;
    dateAsDayOfWeek = storedDateAsDayOfWeek;
    return storedDateAsDayOfWeek;
  }

  static Future<void> setDateAsDayOfWeek(bool newDateAsDayOfWeek) async {
    dateAsDayOfWeek = newDateAsDayOfWeek;
    await (await SharedPreferences.getInstance()).setBool("dateAsDayOfWeek", newDateAsDayOfWeek);
  }
}
