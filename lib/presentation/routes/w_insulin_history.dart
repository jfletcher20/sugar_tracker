import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sugar_tracker/data/api/u_api_insulin.dart';
import 'package:sugar_tracker/data/api/u_api_meal.dart';
import 'package:sugar_tracker/data/models/m_insulin.dart';
import 'package:sugar_tracker/data/models/m_meal.dart';
import 'package:sugar_tracker/data/models/m_sugar.dart';
import 'package:sugar_tracker/presentation/mixins/mx_paging.dart';
import 'package:sugar_tracker/presentation/widgets/insulin/w_insulin_data.dart';

import 'package:flutter/material.dart';
import 'package:sugar_tracker/presentation/widgets/insulin/w_insulin_form.dart';

class InsulinHistoryWidget extends StatefulWidget {
  const InsulinHistoryWidget({super.key});

  @override
  State<InsulinHistoryWidget> createState() => _InsulinHistoryWidgetState();
}

class _InsulinHistoryWidgetState extends State<InsulinHistoryWidget> with Paging {
  @override
  Widget build(BuildContext context) {
    Size maxSize = MediaQuery.of(context).size;
    return FutureBuilder(
      builder: (builder, snapshot) {
        if (snapshot.hasData) {
          List<Insulin> insulin = snapshot.data as List<Insulin>;
          insulin.sort((a, b) => a.datetime!.compareTo(b.datetime!));
          insulin = insulin.reversed.toList();
          return scrollable(
            Column(children: paging(insulin, (context, insulin) => insulinCard(context, insulin))),
          );
        } else {
          return SizedBox(
            height: maxSize.height,
            width: maxSize.width,
            child: const Center(child: CircularProgressIndicator()),
          );
        }
      },
      future: InsulinAPI.selectAll(),
    );
  }

  Card insulinCard(BuildContext context, Insulin insulin) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      borderOnForeground: true,
      child: Stack(
        children: [
          category(insulin),
          InsulinDataWidget(insulin: insulin),
        ],
      ),
    );
  }

  Widget category(Insulin insulin) {
    return Positioned(
      right: 0,
      child: InkWell(
        child: categoryStrip(insulin),
        onTap: () async {
          bool? result = await showModalBottomSheet(
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
                  _useAsTemplate(context, insulin),
                  _edit(context, insulin),
                  _delete(context, insulin),
                  _share(context, insulin),
                  _copy(context, insulin),
                  _exportToCsv(context, insulin),
                ],
              ),
            ),
          );
          if (result != null && result) {
            setState(() {});
          }
        },
      ),
    );
  }

  IconButton _delete(BuildContext context, Insulin insulin) {
    return IconButton(
      icon: const Icon(Icons.delete),
      onPressed: () async {
        bool? result = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Delete entry \"${insulin.toString()}\"?"),
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
          Meal meal = await MealAPI.selectByInsulinId(insulin);
          if (meal.id != -1) {
            // ignore: use_build_context_synchronously
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Cannot delete insulin entry because it is contained in a meal"),
                duration: Duration(seconds: 2),
              ),
            );
          } else {
            await InsulinAPI.delete(insulin);
          }
          if (context.mounted) setState(() {});
        }
        if (context.mounted) Navigator.pop(context, true);
      },
    );
  }

  IconButton _exportToCsv(BuildContext context, Insulin insulin) {
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

  IconButton _share(BuildContext context, Insulin insulin) {
    return IconButton(
      icon: const Icon(Icons.share),
      onPressed: () {
        Share.share(insulin.info);
        Navigator.pop(context);
      },
    );
  }

  IconButton _copy(BuildContext context, Insulin insulin) {
    return IconButton(
      icon: const Icon(Icons.copy),
      onPressed: () {
        Clipboard.setData(ClipboardData(text: insulin.info));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Insulin entry copied to clipboard"),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      },
    );
  }

  IconButton _useAsTemplate(BuildContext context, Insulin insulin) {
    return IconButton(
      icon: const Icon(Icons.plus_one),
      onPressed: () async {
        (Sugar?, Insulin?)? result = await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: const Text("Insulin from template")),
              body: InsulinFormWidget(insulin: insulin, useAsTemplate: true),
            ),
          ),
        );
        if (result?.$2 != null) {
          setState(() => insulin = result!.$2!);
        }
      },
    );
  }

  IconButton _edit(BuildContext context, Insulin insulin) {
    return IconButton(
      icon: const Icon(Icons.edit),
      onPressed: () async {
        (Sugar?, Insulin?)? result = await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: const Text("Edit Insulin Entry")),
              body: InsulinFormWidget(insulin: insulin),
            ),
          ),
        );
        if (result?.$2 != null) {
          setState(() => insulin = result!.$2!);
        }
      },
    );
  }

  Widget categoryStrip(Insulin insulin) {
    return FutureBuilder(
      builder: (context, snapshot) => Container(
          width: 48,
          height: 32,
          decoration: BoxDecoration(
            gradient: _gradient(categoryColor(snapshot.data)),
            borderRadius: _categoryBorder,
          ),
          child: snapshot.data is MealCategory
              ? Icon(mealCategoryIcon(snapshot.data as MealCategory))
              : Icon(insulinCategoryIcon(snapshot.data as InsulinCategory))),
      future: () async {
        Meal meal = await MealAPI.selectByInsulinId(insulin);
        return meal.id == -1 ? insulin.category : meal.category;
      }(),
      initialData: insulin.category,
    );
  }

  LinearGradient _gradient(Color color) {
    return LinearGradient(
      begin: Alignment.centerRight,
      end: Alignment.bottomLeft,
      colors: [color.withOpacity(0.5), color],
    );
  }

  Color categoryColor(dynamic category) {
    if (category is InsulinCategory) return insulinCategoryColor(category);
    if (category is MealCategory) return mealCategoryColor(category);
    return Colors.transparent;
  }

  BorderRadius get _categoryBorder {
    return const BorderRadius.only(
      topRight: Radius.circular(8),
      bottomLeft: Radius.circular(32),
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
