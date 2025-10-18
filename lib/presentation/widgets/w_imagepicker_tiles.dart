import 'package:flutter/material.dart';

class ImagePickerTile extends ListTile {
  ImagePickerTile({
    super.key,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool enabled = true,
    bool? tileColorChange,
  }) : super(
          leading: Icon(icon, color: Colors.white),
          title: Text(title, style: const TextStyle(color: Colors.white)),
          onTap: onTap,
          enabled: enabled,
          tileColor: (tileColorChange ?? false) ? Colors.black.withValues(alpha: 0.4) : null,
        );
}
