import 'package:flutter/material.dart';
import 'package:sugar_tracker/data/api/u_api_sugar.dart';
import 'package:sugar_tracker/data/models/m_insulin.dart';
import 'package:sugar_tracker/data/models/m_sugar.dart';

class InsulinDataWidget extends StatefulWidget {
  final Insulin insulin;
  const InsulinDataWidget({super.key, required this.insulin});

  @override
  State<InsulinDataWidget> createState() => _InsulinDataWidgetState();
}

class _InsulinDataWidgetState extends State<InsulinDataWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        title(context),
        SizedBox(
          width: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 30,
                child: Center(
                  child: Text(
                    widget.insulin.units.toString(),
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              SizedBox(
                width: 60,
                child: Center(
                  child: FutureBuilder(
                    future: SugarAPI.selectAll(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        List<Sugar> sugarLevels = snapshot.data as List<Sugar>;
                        Sugar sugar = sugarLevels.firstWhere(
                            (element) => element.datetime == widget.insulin.datetime,
                            orElse: () => Sugar());
                        return Text(sugar.id != -1 ? sugar.sugar.toString() : "");
                      } else {
                        return const Text("");
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget title(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      width: 230,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(bottomRight: Radius.circular(32)),
        gradient: _gradient(context),
      ),
      child: titleText(context),
    );
  }

  LinearGradient _gradient(BuildContext context) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Colors.black, insulinCategoryColor(widget.insulin.category)],
    );
  }

  RichText titleText(BuildContext context) {
    // return time and category
    return RichText(
      text: TextSpan(
        children: [
          time(context),
          const TextSpan(text: " "),
          category(context),
        ],
      ),
    );
  }

  TextSpan category(BuildContext context) {
    return TextSpan(
      text: "${widget.insulin.name}"
          " (${InsulinCategory.values[widget.insulin.category.index].name.toUpperCase()})",
      style: Theme.of(context)
          .textTheme
          .titleLarge
          ?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
    );
  }

  TextSpan time(BuildContext context) {
    return TextSpan(
      text: widget.insulin.time,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: insulinCategoryColor(
              widget.insulin.category,
            ),
          ),
    );
  }
}
