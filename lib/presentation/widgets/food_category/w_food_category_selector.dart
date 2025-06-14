import 'package:sugar_tracker/data/models/m_food_category.dart';

import 'package:flutter/material.dart';

class FoodCategorySelectorWidget extends StatefulWidget {
  final FoodCategory foodCategory;
  final double imgSize;
  final bool showLabel, selectable, initializeSelected, cancelDeselect;
  final Function()? onTap;
  const FoodCategorySelectorWidget({
    super.key,
    required this.foodCategory,
    this.imgSize = 64,
    this.showLabel = false,
    this.selectable = false,
    this.initializeSelected = false,
    this.cancelDeselect = false,
    this.onTap,
  });

  @override
  State<FoodCategorySelectorWidget> createState() => FoodCategorySelectorWidgetState();
}

class FoodCategorySelectorWidgetState extends State<FoodCategorySelectorWidget> {
  bool selected = false;
  bool select() {
    setState(() => selected = !selected);
    return selected;
  }

  @override
  void initState() {
    super.initState();
    selected = widget.initializeSelected;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: selected ? Colors.red.withValues(alpha: 0.5) : Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? widget.foodCategory.color : Colors.transparent,
            width: 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: (widget.cancelDeselect && selected)
              ? null
              : widget.selectable
                  ? () {
                      select();
                      widget.onTap?.call();
                    }
                  : null,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: Image.asset(
                  widget.foodCategory.picture,
                  width: widget.imgSize,
                  height: widget.imgSize,
                  errorBuilder: imageNotFound,
                ),
              ),
              if (widget.showLabel) label(),
            ],
          ),
        ),
      ),
    );
  }

  Widget imageNotFound(BuildContext context, Object error, StackTrace? stackTrace) {
    return Image.asset(
      "assets/images/food/unknown.png",
      color: Colors.redAccent,
      height: widget.imgSize,
      width: widget.imgSize,
    );
  }

  String get categoryName {
    String name = widget.foodCategory.name.substring(0, 1).toUpperCase();
    name += widget.foodCategory.name.substring(1);
    return name;
  }

  Widget label() {
    return Positioned(
      bottom: 0,
      child: SizedBox(
        width: widget.imgSize + 16,
        child: FittedBox(
          fit: BoxFit.fitWidth,
          child: Text(
            categoryName,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              shadows: [const Shadow(color: Colors.black, offset: Offset(1, 1), blurRadius: 2)],
            ),
          ),
        ),
      ),
    );
  }

  void setSelected(bool state) => setState(() => selected = state);
}
