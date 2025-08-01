import 'package:flutter/material.dart';

class IconWithInfo extends StatelessWidget {
  final IconData icon;
  final String info;
  final Color? iconColor;
  final double iconSize;
  final double? width;
  final TextStyle? textStyle;
  final MainAxisAlignment? alignment;
  final bool shrink;
  const IconWithInfo({
    super.key,
    this.icon = Icons.info,
    required this.info,
    this.iconColor,
    this.iconSize = 16,
    this.width,
    this.textStyle,
    this.alignment,
    this.shrink = false,
  }) : assert(shrink && width != null || !shrink, 'Width must be provided when shrink is true');

  @override
  Widget build(BuildContext context) {
    TextStyle style = textStyle ?? Theme.of(context).textTheme.bodyMedium!;
    if (width != null) {
      return SizedBox(
        width: width,
        child: shrink
            ? FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: alignment ?? MainAxisAlignment.start,
                  children: [
                    Icon(icon, size: iconSize, color: iconColor),
                    Text(info, style: style),
                  ],
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: alignment ?? MainAxisAlignment.start,
                children: [
                  Icon(icon, size: iconSize, color: iconColor),
                  Text(info, style: style),
                ],
              ),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: alignment ?? MainAxisAlignment.start,
      children: [
        Icon(icon, size: iconSize, color: iconColor),
        Text(info, style: style),
      ],
    );
  }
}
