import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sugar_tracker/data/api/u_api_sugar.dart';
import 'package:sugar_tracker/data/models/m_sugar.dart';

class SugarModelState extends StateNotifier<Set<Sugar>> {
  SugarModelState() : super(const {}) {
    load();
  }

  Future<void> load() async => setSugars((await SugarAPI.selectAll()).toSet());

  Sugar getSugar(int id) {
    return state.firstWhere((t) {
      return t.id == id;
    }, orElse: () => Sugar());
  }

  Future<Sugar> addSugar(Sugar sugar) async {
    int id = await SugarAPI.insert(sugar);
    sugar = sugar.copyWith(id: id);
    state = {...state, sugar};
    return sugar;
  }

  Future<void> removeSugar(Sugar sugar) async {
    if (state.where((element) => element.id == sugar.id).isEmpty) return;
    state = state.where((element) => element != sugar).toSet();
    await SugarAPI.delete(sugar);
  }

  void setSugars(Set<Sugar> sugars) => state = sugars;

  Future<void> updateSugar(Sugar sugar) async {
    if (state.where((element) => element.id == sugar.id).isEmpty) return;
    state = state.map((m) => m.id == sugar.id ? sugar : m).toSet();
    await SugarAPI.update(sugar);
  }
}

class SugarManager {
  static final provider = StateNotifierProvider<SugarModelState, Set<Sugar>>((ref) {
    return SugarModelState();
  });
}