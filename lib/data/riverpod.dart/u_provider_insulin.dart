import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sugar_tracker/data/api/u_api_insulin.dart';
import 'package:sugar_tracker/data/models/m_insulin.dart';

class InsulinModelState extends StateNotifier<Set<Insulin>> {
  InsulinModelState() : super(const {}) {
    load();
  }

  Future<void> load() async => setInsulins((await InsulinAPI.selectAll()).toSet());

  List<Insulin> getInsulins() => state.toList();

  Insulin getInsulin(int id) {
    return state.firstWhere((t) {
      return t.id == id;
    }, orElse: () => Insulin());
  }

  Future<Insulin> addInsulin(Insulin insulin) async {
    int id = await InsulinAPI.insert(insulin);
    insulin = insulin.copyWith(id: id);
    state = {...state, insulin};
    return insulin;
  }

  Future<void> removeInsulin(Insulin insulin) async {
    if (state.where((element) => element.id == insulin.id).isEmpty) return;
    state = state.where((element) => element != insulin).toSet();
    await InsulinAPI.delete(insulin);
  }

  void setInsulins(Set<Insulin> insulins) => state = insulins;

  Future<void> updateInsulin(Insulin insulin) async {
    if (state.where((element) => element.id == insulin.id).isEmpty) return;
    state = state.map((m) => m.id == insulin.id ? insulin : m).toSet();
    await InsulinAPI.update(insulin);
  }
}

class InsulinManager {
  static final provider = StateNotifierProvider<InsulinModelState, Set<Insulin>>((ref) {
    return InsulinModelState();
  });
}
