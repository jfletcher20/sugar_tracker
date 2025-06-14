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
import 'package:sugar_tracker/presentation/widgets/meal/w_icon_info.dart';

class FoodCard extends ConsumerStatefulWidget {
  final Food food;
  final Set<int> columns;
  final bool modifiable, showAmount, showAdditionalOptions;
  final void Function(dynamic)? onCreate, onDelete;
  const FoodCard({
    super.key,
    required this.food,
    this.columns = const {0, 1},
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
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      shadowColor: Colors.grey.shade200,
      child: InkWell(
        key: glob,
        onTap: () async => widget.showAdditionalOptions ? _modalWithOptions() : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          width: MediaQuery.of(context).size.width * 0.9,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(padding: const EdgeInsets.only(left: 4), child: title(context)),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 48,
                      child: FittedBox(fit: BoxFit.scaleDown, child: prefix(context)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2.0),
                      child: cardData(context),
                    ),
                  ],
                ),
              ),
            ],
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

  Widget prefix(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: FoodCountWidget(
        food: widget.food,
        modifiable: widget.modifiable,
        showAmount: widget.showAmount,
        // autoSize: widget.food.amount <= 0,
        // autoSize: true,
      ),
    );
  }

  Column cardData(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        data(widget.food),
        // const SizedBox(height: 8),
        if (widget.food.notes != null) notes(widget.food.notes, context),
      ],
    );
  }

  Text title(BuildContext context) {
    String title = widget.food.name;
    // replace all " " with "\n"
    // title = title.replaceAll(" ", "\n");
    // break the title text with a newline only if it is longer tahn 20 characters; break it at the first space after the 20 character mark
    // if (title.length >= 20) {
    //   if (title.substring(16).contains(" ")) {
    //     title = title.substring(0, 16) + title.substring(16).replaceFirst(" ", "\n");
    //   }
    // }
    TextStyle titleLarge = Theme.of(context).textTheme.titleMedium!;
    titleLarge = titleLarge.copyWith(
        fontWeight: FontWeight.w600, color: food.amount <= 0 ? null : Colors.redAccent);
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

  Widget data(Food food) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconWithInfo(
          info: "${food.carbs.round()}g / 100g",
          icon: Icons.scale,
          iconColor: food.foodCategory.color,
          width: 116,
        ),
        const SizedBox(width: 12),
        if (food.amount > 0)
          IconWithInfo(
            info: "${food.totalCarbs.round()}g",
            icon: Icons.calculate,
            iconColor: Colors.redAccent,
            // width: 48 + 24,
          ),
      ],
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
