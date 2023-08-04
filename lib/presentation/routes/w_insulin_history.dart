import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sugar_tracker/data/api/u_api_insulin.dart';
import 'package:sugar_tracker/data/api/u_api_meal.dart';
import 'package:sugar_tracker/data/models/m_insulin.dart';
import 'package:sugar_tracker/data/models/m_meal.dart';
import 'package:sugar_tracker/presentation/widgets/insulin/w_insulin_data.dart';

import 'package:flutter/material.dart';
import 'package:sugar_tracker/presentation/widgets/insulin/w_insulin_form.dart';

class InsulinHistoryWidget extends StatefulWidget {
  const InsulinHistoryWidget({super.key});

  @override
  State<InsulinHistoryWidget> createState() => _InsulinHistoryWidgetState();
}

class _InsulinHistoryWidgetState extends State<InsulinHistoryWidget> {
  @override
  Widget build(BuildContext context) {
    Size maxSize = MediaQuery.of(context).size;
    return FutureBuilder(
      builder: (builder, snapshot) {
        if (snapshot.hasData) {
          List<Insulin> insulin = snapshot.data as List<Insulin>;
          insulin.sort((a, b) => a.datetime!.compareTo(b.datetime!));
          insulin = insulin.reversed.toList();
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                for (int i = 0; i < insulin.length; i++) insulinCard(context, insulin[i]),
              ],
            ),
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
        child: categoryStrip(insulin.category),
        onTap: () async {
          bool? result = await showModalBottomSheet(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
            ),
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
      icon: const Icon(Icons.food_bank),
      onPressed: () async {
        Insulin? result = await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: const Text("Insulin from template")),
              // body: InsulinFormWidget(insulin: insulin, useAsTemplate: true),
            ),
          ),
        );
        if (result != null) {
          setState(() {});
        }
      },
    );
  }

  IconButton _edit(BuildContext context, Insulin insulin) {
    return IconButton(
      icon: const Icon(Icons.edit),
      onPressed: () async {
        Insulin? result = await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: const Text("Edit Insulin Entry")),
              body: InsulinFormWidget(insulin: insulin),
            ),
          ),
        );
        if (result != null) {
          setState(() => insulin = result);
        }
      },
    );
  }

  Widget categoryStrip(InsulinCategory category) {
    return Container(
      width: 48,
      height: 16,
      decoration: BoxDecoration(
        color: insulinCategoryColor(category),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(16),
          bottomLeft: Radius.circular(16),
        ),
      ),
    );
  }
}
