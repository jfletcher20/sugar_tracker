import 'dart:io';

import 'package:flutter/material.dart';

class BackupProgressDialog extends StatelessWidget {
  final List<File> files;
  final ValueNotifier<double> progressNotifier;
  const BackupProgressDialog({super.key, required this.progressNotifier, required this.files});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Backup in progress", textAlign: TextAlign.center),
      content: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: progressNotifier,
              builder: (context, child) {
                return Column(
                  children: [
                    _progress(context),
                    const SizedBox(height: 16),
                    _fileProgress,
                    _currentFile,
                    const SizedBox(height: 16),
                    _currentFileNameDisplay(context),
                  ],
                );
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Close"),
        ),
      ],
    );
  }

  Widget _progress(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [_progressText(context), _progressIndicator],
    );
  }

  Widget _progressText(BuildContext context) {
    TextStyle? style = Theme.of(context).textTheme.headlineLarge;
    style = style?.copyWith(
      color: AlwaysStoppedAnimation<Color>(
        ColorTween(begin: Colors.red, end: Colors.green).lerp(progressNotifier.value)!,
      ).value,
    );
    return Text(
      "${(progressNotifier.value * 100).toStringAsFixed(0)}%",
      style: style,
    );
  }

  Widget get _progressIndicator {
    return SizedBox(
      height: 128,
      width: 128,
      child: CircularProgressIndicator(
        strokeWidth: 10,
        value: progressNotifier.value,
        valueColor: AlwaysStoppedAnimation<Color>(
          ColorTween(begin: Colors.red, end: Colors.green).lerp(progressNotifier.value)!,
        ),
      ),
    );
  }

  Widget get _fileProgress {
    double totalBytes = files.fold(0, (prev, file) {
      int fileSize = 0;
      try {
        fileSize = file.lengthSync();
      } catch (e) {}
      return prev + fileSize;
    });
    return Text(
      "${_formatBytes(progressNotifier.value * totalBytes)} / ${_formatBytes(totalBytes)}",
    );
  }

  Widget _currentFileNameDisplay(BuildContext context) {
    return Text(
      _currentFileName,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
    );
  }

  Widget get _currentFile {
    int currentFile = (progressNotifier.value * files.length).toInt();
    if (currentFile >= files.length) currentFile = files.length - 1;
    return Text(
      "File ${currentFile + 1} of ${files.length}",
    );
  }

  String get _currentFileName {
    int fileIndex = (progressNotifier.value * files.length).toInt();
    if (fileIndex >= files.length) fileIndex = files.length - 1;
    String fileName = files[fileIndex].path.split("/").last;
    return fileName.length > 19 ? "${fileName.substring(0, 16)}..." : fileName;
  }

  String _formatBytes(double bytes) {
    if (bytes < 1024) {
      return "${bytes.toStringAsFixed(0)} B";
    } else if (bytes < 1024 * 1024) {
      return "${(bytes / 1024).toStringAsFixed(2)} KB";
    } else {
      return "${(bytes / 1024 / 1024).toStringAsFixed(2)} MB";
    }
  }
}
