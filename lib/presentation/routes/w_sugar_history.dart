// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sugar_tracker/data/constants.dart';
import 'package:sugar_tracker/data/models/enums/e_insulin_category.dart';
import 'package:sugar_tracker/data/models/enums/e_meal_category.dart';
import 'package:sugar_tracker/data/riverpod.dart/u_provider_insulin.dart';
import 'package:sugar_tracker/data/riverpod.dart/u_provider_meal.dart';
import 'package:sugar_tracker/data/riverpod.dart/u_provider_sugar.dart';
import 'package:sugar_tracker/presentation/widgets/insulin/w_insulin_form.dart';
import 'package:sugar_tracker/presentation/widgets/sugar/w_sugar_data.dart';
import 'package:sugar_tracker/data/models/m_insulin.dart';
import 'package:sugar_tracker/data/models/m_sugar.dart';
import 'package:sugar_tracker/data/models/m_meal.dart';

import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class SugarHistoryWidget extends ConsumerStatefulWidget {
  const SugarHistoryWidget({super.key});

  @override
  ConsumerState<SugarHistoryWidget> createState() => _SugarHistoryWidgetState();
}

class _SugarHistoryWidgetState extends ConsumerState<SugarHistoryWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    ref.watch(MealManager.provider); // to watch for changes to the meal list
    ref.watch(InsulinManager.provider); // to watch for changes to the insulin list
    List<Sugar> sugar = ref.watch(SugarManager.provider).toList();
    sugar.sort((a, b) => a.datetime!.compareTo(b.datetime!));
    sugar = sugar.reversed.toList();
    return Scrollbar(
      controller: _scrollController,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3.0),
        child: ListView(
          children: sugar.map((sugar) => SugarLevelCard(sugar: sugar)).toList(),
        ),
      ),
    );
  }
}

class SugarLevelCard extends StatelessWidget {
  final Sugar sugar;
  const SugarLevelCard({super.key, required this.sugar});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          borderOnForeground: true,
          child: Stack(
            children: [
              SugarDataWidget(sugar: sugar),
              Positioned(right: 0, child: category(sugar, ref, context)),
            ],
          ),
        );
      },
    );
  }

  Card sugarCard(BuildContext context, Sugar sugar, WidgetRef ref) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      borderOnForeground: true,
      child: Stack(children: [category(sugar, ref, context), SugarDataWidget(sugar: sugar)]),
    );
  }

  Widget category(Sugar sugar, WidgetRef ref, BuildContext context) {
    return InkWell(
      child: categoryStrip(sugar, ref),
      onTap: () async {
        await showModalBottomSheet(
          shape: _modalDecoration,
          showDragHandle: true,
          context: context,
          builder: (context) => SizedBox(
            height: 64 + 16,
            child: GridView(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                childAspectRatio: 2,
              ),
              children: [
                _useAsTemplate(context, sugar),
                _edit(context, sugar),
                _delete(context, sugar, ref),
                _share(context, sugar),
                _copy(context, sugar),
                _exportToCsv(context, sugar),
              ],
            ),
          ),
        );
      },
    );
  }

  IconButton _delete(BuildContext context, Sugar sugar, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.delete),
      onPressed: () async {
        bool? result = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Delete entry \"${sugar.toString()}\"?"),
            content: const Text("This action cannot be undone."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Delete"),
              ),
            ],
          ),
        );
        if (result != null && result) {
          // await MealAPI.delete(insulin);
          Meal meal = ref.watch(MealManager.provider.notifier).getMealBySugarId(sugar);
          if (meal.id != -1) {
            // ignore: use_build_context_synchronously
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Cannot delete sugar entry because it is contained in a meal"),
                duration: Duration(seconds: 2),
              ),
            );
          } else
            await ref.read(SugarManager.provider.notifier).removeSugar(sugar);
        }
        if (context.mounted) Navigator.pop(context, true);
      },
    );
  }

  IconButton _exportToCsv(BuildContext context, Sugar sugar) {
    return IconButton(
      icon: const Icon(Icons.download),
      onPressed: () {
        // export to csv to location user specifies (show file dialog)
        // showSavePanel(
        //   suggestedFileName: "meal.csv",
        //   allowedFileTypes: const [FileTypeFilterGroup.csv()],
        //   confirmButtonText: "Export",
        //   initialDirectory: "C:\\Users\\${Platform.environment["USERNAME"]}\\Documents",
        // ).then((value) {
        //   if (value != null) {
        //     String path = value.path;
        //     if (!path.endsWith(".csv")) {
        //       path += ".csv";
        //     }
        //     MealAPI.exportToCsv(meal, path);
        //   }
        // });
        Navigator.pop(context);
      },
    );
  }

  IconButton _share(BuildContext context, Sugar sugar) {
    return IconButton(
      icon: const Icon(Icons.share),
      onPressed: () {
        Share.share(sugar.info);
        Navigator.pop(context);
      },
    );
  }

  IconButton _copy(BuildContext context, Sugar sugar) {
    return IconButton(
      icon: const Icon(Icons.copy),
      onPressed: () {
        Clipboard.setData(ClipboardData(text: sugar.info));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Sugar level entry copied to clipboard"),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      },
    );
  }

  IconButton _useAsTemplate(BuildContext context, Sugar sugar) {
    return IconButton(
      icon: const Icon(Icons.plus_one),
      onPressed: () async {
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: const Text("Entry from template")),
              body: InsulinFormWidget(sugar: sugar, useAsTemplate: true),
            ),
          ),
        );
      },
    );
  }

  IconButton _edit(BuildContext context, Sugar sugar) {
    return IconButton(
      icon: const Icon(Icons.edit),
      onPressed: () async {
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: const Text("Edit Insulin Entry")),
              body: InsulinFormWidget(sugar: sugar),
            ),
          ),
        );
      },
    );
  }

  Widget categoryStrip(Sugar sugar, WidgetRef ref) {
    Meal meal = ref.read(MealManager.provider.notifier).getMealBySugarId(sugar);
    dynamic val = meal.id == -1 ? null : meal.category;
    if (val == null) {
      Set<Insulin> insulins = ref.watch(InsulinManager.provider);
      Insulin insulin =
          insulins.firstWhere((e) => e.datetime == sugar.datetime, orElse: () => Insulin());
      val = insulin.id == -1 ? null : insulin.category;
    }
    return Container(
      width: 48,
      height: 32,
      decoration: BoxDecoration(
        gradient: _gradient(val?.color ?? Colors.transparent),
        borderRadius: _categoryBorder,
      ),
      child: val == null ? Icon(IconConstants.sugar.regular) : Icon(val.icon),
    );
  }

  LinearGradient _gradient(Color color) {
    return LinearGradient(
      begin: Alignment.centerRight,
      end: Alignment.bottomLeft,
      colors: [color.withValues(alpha: 0.5), color],
    );
  }

  Color categoryColor(dynamic category) {
    if (category is InsulinCategory || category is MealCategory) return category.color;
    return Colors.redAccent[400]!;
  }

  BorderRadius get _categoryBorder {
    return const BorderRadius.only(
      topRight: Radius.circular(8),
      bottomLeft: Radius.circular(32),
      bottomRight: Radius.circular(8),
    );
  }

  RoundedRectangleBorder get _modalDecoration {
    return const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(32),
        topRight: Radius.circular(32),
      ),
    );
  }
}
