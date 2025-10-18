import 'package:flutter/material.dart';

enum InsulinCategory {
  bolus,
  basal;

  Color get color => this == InsulinCategory.bolus ? Colors.deepOrange : Colors.lightGreen;
  IconData get icon => this == InsulinCategory.bolus ? Icons.fast_forward : Icons.slow_motion_video;
}
