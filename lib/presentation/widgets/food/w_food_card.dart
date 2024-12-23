import 'dart:io';
import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:sugar_tracker/presentation/widgets/food/w_food_count.dart';
import 'package:sugar_tracker/presentation/widgets/food/w_food_form.dart';
import 'package:sugar_tracker/data/riverpod.dart/u_provider_food.dart';
import 'package:sugar_tracker/data/models/m_food.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FoodCard extends ConsumerStatefulWidget {
  final Food food;
  final Set<int> columns;
  final bool modifiable, showAmount, showAdditionalOptions;
  final void Function(dynamic)? onCreate, onDelete;
  const FoodCard({
    super.key,
    required this.food,
    this.columns = const {0, 1, 2},
    this.modifiable = false,
    this.showAmount = true,
    this.showAdditionalOptions = false,
    this.onCreate,
    this.onDelete,
  });

  @override
  ConsumerState<FoodCard> createState() => _FoodCardState();
}

class _FoodCardState extends ConsumerState<FoodCard> {
  late Food food;
  @override
  void initState() {
    super.initState();
    food = widget.food;
  }

  final GlobalKey glob = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        shadowColor: Colors.grey.shade200,
        child: InkWell(
          key: glob,
          onTap: () async => widget.showAdditionalOptions ? _modalWithOptions() : null,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  prefix(context),
                  const SizedBox(width: 16),
                  cardData(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  final ShapeBorder _modalShape = const RoundedRectangleBorder(
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(32),
      topRight: Radius.circular(32),
    ),
  );
  final SliverGridDelegate _modalGridDelegate = const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 6,
    childAspectRatio: 2,
  );
  Future<void> _modalWithOptions() async {
    bool? result = await showModalBottomSheet(
      shape: _modalShape,
      showDragHandle: true,
      context: context,
      builder: (context) => SizedBox(
        height: 64 + 16,
        child: GridView(
          gridDelegate: _modalGridDelegate,
          children: _modalOptions(),
        ),
      ),
    );
    if (result != null && result) {
      setState(() {});
    }
  }

  List<IconButton> _modalOptions() {
    return <IconButton>[
      _useAsTemplate(context, widget.food),
      _edit(context, widget.food),
      _delete(context, widget.food),
      _share(context, widget.food),
      _copy(context, widget.food),
      _saveAsImage(context, widget.food),
    ];
  }

  Column prefix(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 64 + 16,
          child: FractionallySizedBox(
            widthFactor: 1.25,
            child: FittedBox(fit: BoxFit.scaleDown, child: title(context)),
          ),
        ),
        const SizedBox(height: 16),
        FoodCountWidget(
          food: widget.food,
          modifiable: widget.modifiable,
          showAmount: widget.showAmount,
        ),
      ],
    );
  }

  Column cardData(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        data(widget.food),
        const SizedBox(height: 8),
        if (widget.food.notes != null) notes(widget.food.notes, context),
      ],
    );
  }

  Text title(BuildContext context) {
    String title = widget.food.name;
    // replace all " " with "\n"
    title = title.replaceAll(" ", "\n");
    TextStyle titleLarge = Theme.of(context).textTheme.titleLarge!;
    titleLarge = titleLarge.copyWith(
      fontWeight: FontWeight.w500,
    );
    return Text(
      title,
      style: titleLarge,
      textAlign: TextAlign.center,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget notes(String? notes, BuildContext context) {
    return Text(
      "${widget.food.notes}",
      style: const TextStyle(
        fontSize: 12,
        fontStyle: FontStyle.italic,
      ),
    );
  }

  DataTable data(Food food) {
    List<DataColumn> columns = const <DataColumn>[
      DataColumn(label: Center(child: Text("Carbs"))),
      DataColumn(label: Center(child: Text("Σ Carbs"))),
      DataColumn(label: Center(child: Text("Category"))),
    ];
    List<DataCell> cells = [
      DataCell(Center(child: Text("${(food.carbs).round()}g"))),
      DataCell(Center(child: Text("${((food.carbs / 100) * food.amount).round()}g"))),
      DataCell(Center(child: Text(food.foodCategory.name))),
    ];
    return DataTable(
      horizontalMargin: 10,
      columnSpacing: 25,
      showBottomBorder: true,
      columns: widget.columns.map((e) => columns[e]).toList(),
      rows: [DataRow(cells: widget.columns.map((e) => cells[e]).toList())],
    );
  }

  IconButton _delete(BuildContext context, Food food) {
    return IconButton(
      icon: const Icon(Icons.delete),
      onPressed: () async {
        bool? result = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Delete ${food.toString()}?"),
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
          try {
            await ref.read(FoodManager.provider.notifier).removeFood(food, ref: ref);
          } catch (e) {
            if (context.mounted)
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(e.toString()),
                  duration: const Duration(seconds: 2),
                ),
              );
          }
          widget.onDelete?.call(food.id);
          if (context.mounted) {
            setState(() {});
            Navigator.pop(context, true);
          }
        }
      },
    );
  }

  // save widget as image
  Future<Uint8List> getWidgetAsImageBytes(BuildContext context) async {
    RenderRepaintBoundary boundary =
        glob.currentContext!.findAncestorRenderObjectOfType<RenderRepaintBoundary>()!;
    final image = await boundary.toImage(pixelRatio: 3.0);
    final bytes = await image.toByteData(format: ImageByteFormat.png);
    return bytes!.buffer.asUint8List();
  }

  IconButton _saveAsImage(BuildContext context, Food food) {
    return IconButton(
      icon: const Icon(Icons.download),
      onPressed: () async {
        Uint8List imageBytes = await getWidgetAsImageBytes(context);
        SaveFileDialogParams params = SaveFileDialogParams(
          data: imageBytes,
          mimeTypesFilter: ["image/png"],
          fileName: "$food.png",
        );
        await FlutterFileDialog.saveFile(params: params);
        if (context.mounted) Navigator.pop(context);
      },
    );
  }

  IconButton _share(BuildContext context, Food food) {
    return IconButton(
      icon: const Icon(Icons.share),
      onPressed: () async {
        String imgName = "${food.toString()}.png";
        Uint8List imageBytes = await getWidgetAsImageBytes(context);

        // save imageBytes as temp file in cache
        String tempDir = Directory.systemTemp.path;
        File file = File(
          "$tempDir/$imgName",
        )
          ..createSync(recursive: true)
          ..writeAsBytesSync(imageBytes);
        XFile xFile = XFile(file.path);

        Share.shareXFiles(
          [xFile],
          text: food.toString(),
          subject: food.name.toString(),
        );

        if (context.mounted) Navigator.pop(context);
      },
    );
  }

  IconButton _copy(BuildContext context, Food food) {
    return IconButton(
      icon: const Icon(Icons.copy),
      onPressed: () {
        Clipboard.setData(ClipboardData(text: food.toString()));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Food data copied to clipboard"),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      },
    );
  }

  IconButton _useAsTemplate(BuildContext context, Food food) {
    return IconButton(
      icon: const Icon(Icons.plus_one),
      onPressed: () async {
        Food? result = await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: const Text("Food from template")),
              body: FoodFormWidget(food: food.copyWith(id: -1), useAsTemplate: true),
            ),
          ),
        );
        if (result != null && mounted) {
          setState(() {});
          widget.onCreate?.call(result);
        }
      },
    );
  }

  IconButton _edit(BuildContext context, Food food) {
    return IconButton(
      icon: const Icon(Icons.edit),
      onPressed: () async {
        Food? result = await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: const Text("Edit Meal")),
              body: FoodFormWidget(food: food),
            ),
          ),
        );
        if (result != null) setState(() => food = result);
      },
    );
  }
}
