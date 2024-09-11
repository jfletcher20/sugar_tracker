import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class DownloadProgressDialog extends StatelessWidget {
  final ListResult files;
  final ValueNotifier<double> progressNotifier;
  final ValueNotifier<String> currentFileName;
  const DownloadProgressDialog({
    super.key,
    required this.progressNotifier,
    required this.files,
    required this.currentFileName,
  });

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
    return Text(
      "File ${(progressNotifier.value * files.items.length).round()} of ${files.items.length}",
    );
  }

  Widget _currentFileNameDisplay(BuildContext context) {
    return Text(
      _currentFileName,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
    );
  }

  String get _currentFileName {
    String fileName = currentFileName.value;
    return fileName.length > 19 ? "${fileName.substring(0, 16)}..." : fileName;
  }
}
