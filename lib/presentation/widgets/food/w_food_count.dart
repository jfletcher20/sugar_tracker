import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sugar_tracker/data/models/m_food.dart';

class FoodCountWidget extends StatefulWidget {
  final Food food;
  final bool autoSize, modifiable, showAmount;
  final double borderRadius;
  const FoodCountWidget({
    super.key,
    required this.food,
    this.autoSize = false,
    this.modifiable = false,
    this.showAmount = true,
    this.borderRadius = 5.0,
  });

  @override
  State<FoodCountWidget> createState() => FoodCountWidgetState();
}

class FoodCountWidgetState extends State<FoodCountWidget> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: imgSize + 24,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [img, if (widget.showAmount) amount(widget.food)],
      ),
    );
  }

  final double imgSize = 64 + 8;

  late TextEditingController _amountController;
  @override
  void initState() {
    super.initState();
    String amount = widget.food.amount > 0 ? widget.food.amount.toString() : "";
    _amountController = TextEditingController(text: amount);
  }

  Widget amount(Food food) {
    return Positioned(
      bottom: 0,
      child: InkWell(
        onTap: widget.modifiable
            ? () async {
                changeAmountDialog(food).call().then((value) => setState(() {}));
              }
            : null,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Colors.redAccent.withValues(alpha: 0.85),
          ),
          padding: const EdgeInsets.all(4),
          child: Text(
            " ${food.amount}g ",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> Function() changeAmountDialog(Food food) {
    return () async {
      String? amount = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Change amount"),
            content: TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                suffixText: "g",
                suffixStyle: TextStyle(color: Colors.white),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              // if food.weight is > 0, then show TextButton to add food.weight to _amountController.value
              if (food.weight > 0)
                TextButton(
                  onPressed: () {
                    int current = int.tryParse(_amountController.text) ?? 0;
                    current += food.weight.round();
                    _amountController.text = current.toString();
                    setState(() {});
                  },
                  child: Text("Add ${food.weight.round()}g"),
                ),
              TextButton(
                onPressed: () => Navigator.pop(context, _amountController.text),
                child: const Text("Save"),
              ),
            ],
          );
        },
      );
      try {
        food.amount = int.tryParse(amount ?? "0") ?? 0;
        if (context.mounted) setState(() {});
      } catch (e) {
        food.amount = 0;
        if (context.mounted) setState(() {});
      }
    };
  }

  Widget get img {
    return SizedBox(
      height: widget.autoSize ? null : imgSize,
      width: widget.autoSize ? null : imgSize,
      child: Center(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border:
                    Border.all(color: Colors.redAccent, strokeAlign: BorderSide.strokeAlignInside),
              ),
              child: image(widget.food),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border:
                    Border.all(color: Colors.redAccent, strokeAlign: BorderSide.strokeAlignCenter),
              ),
              child: Visibility(visible: false, child: image(widget.food)),
            )
          ],
        ),
      ),
    );
  }

  Image image(Food food) {
    return food.picture.contains("asset")
        ? Image.asset(
            height: widget.autoSize ? null : 48,
            width: widget.autoSize ? null : 48,
            food.picture,
            color: food.picture == "" ? Colors.greenAccent : null,
            errorBuilder: imageNotFound,
          )
        : Image.file(
            File(food.picture),
            height: widget.autoSize ? null : 48,
            width: widget.autoSize ? null : 48,
            color: food.picture == "" ? Colors.greenAccent : null,
            errorBuilder: imageNotFound,
          );
  }

  Widget imageNotFound(BuildContext context, Object error, StackTrace? stackTrace) {
    return Image.asset(
      "assets/images/food/unknown.png",
      color: Colors.redAccent,
      height: widget.autoSize ? null : 48,
      width: widget.autoSize ? null : 48,
    );
  }
}
