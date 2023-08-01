import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sugar_tracker/data/models/m_food.dart';

class FoodCountWidget extends StatefulWidget {
  final Food food;
  final bool autoSize, modifiable;
  const FoodCountWidget({
    super.key,
    required this.food,
    this.autoSize = false,
    this.modifiable = false,
  });

  @override
  State<FoodCountWidget> createState() => FoodCountWidgetState();
}

class FoodCountWidgetState extends State<FoodCountWidget> {
  @override
  Widget build(BuildContext context) {
    return imageWithCounter(widget.food, context);
  }

  final double imgSize = 64 + 8;

  late TextEditingController _amountController;
  @override
  void initState() {
    super.initState();
    String amount = widget.food.amount > 0 ? widget.food.amount.toString() : "";
    _amountController = TextEditingController(text: amount);
  }

  Widget imageWithCounter(Food food, BuildContext context) {
    return SizedBox(
      height: imgSize + 24,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          img(),
          Positioned(
            bottom: 0,
            child: InkWell(
              onTap: widget.modifiable
                  ? () async {
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
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context, _amountController.text);
                                },
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
                    }
                  : null,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.redAccent.withOpacity(0.85),
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
          ),
        ],
      ),
    );
  }

  Widget img() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.redAccent),
        color: Colors.white,
      ),
      padding: const EdgeInsets.all(4),
      child: SizedBox(
        height: widget.autoSize ? null : imgSize,
        width: widget.autoSize ? null : imgSize,
        child: Center(
          child: Stack(
            fit: StackFit.expand,
            children: [image(widget.food)],
          ),
        ),
      ),
    );
  }

  Image image(Food food) {
    return Image.asset(
      height: widget.autoSize ? null : 48,
      width: widget.autoSize ? null : 48,
      food.picture ?? "assets/images/foods/unknown.png",
      color: food.picture == null ? Colors.greenAccent : null,
      errorBuilder: imageNotFound,
    );
  }

  Widget imageNotFound(BuildContext context, Object error, StackTrace? stackTrace) {
    return Image.asset(
      "assets/images/foods/unknown.png",
      color: Colors.redAccent,
      height: widget.autoSize ? null : 48,
      width: widget.autoSize ? null : 48,
    );
  }
}
