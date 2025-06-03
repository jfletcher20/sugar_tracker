import 'package:flutter/material.dart';

class IconWithInfo extends StatelessWidget {
  final IconData icon;
  final String info;
  final Color? iconColor;
  final double iconSize;
  final double? width;
  final TextStyle? textStyle;
  const IconWithInfo({
    super.key,
    this.icon = Icons.info,
    required this.info,
    this.iconColor,
    this.iconSize = 16,
    this.width,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    if (width != null) {
      return SizedBox(
        width: width,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: iconSize, color: iconColor),
            Text(info, style: textStyle),
          ],
        ),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: iconSize, color: iconColor),
        Text(info, style: textStyle),
      ],
    );
  }
}
