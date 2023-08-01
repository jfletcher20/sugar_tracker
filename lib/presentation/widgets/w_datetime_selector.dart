import 'dart:async';

import 'package:flutter/material.dart';

class DateTimeSelectorWidget extends StatefulWidget {
  final DateTime? initialDateTime;
  const DateTimeSelectorWidget({super.key, this.initialDateTime});

  @override
  State<DateTimeSelectorWidget> createState() => DateTimeSelectorWidgetState();
}

class DateTimeSelectorWidgetState extends State<DateTimeSelectorWidget> {
  bool autoRefreshTime = true, autoRefreshDate = true;
  DateTime datetime = DateTime.now();
  late Timer timer;

  @override
  void initState() {
    super.initState();
    if (widget.initialDateTime != null) {
      datetime = widget.initialDateTime!;
      pauseDate();
      pauseTime();
    }
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      timerFunction();
    });
  }

  void timerFunction() {
    if (autoRefreshTime) {
      resetTime();
    }
    if (autoRefreshDate) {
      resetDate();
    }
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  String get time {
    String hour = datetime.hour.toString();
    String minute = datetime.minute.toString();
    if (hour.length == 1) {
      hour = "0$hour";
    }
    if (minute.length == 1) {
      minute = "0$minute";
    }
    return "$hour:$minute";
  }

  String get date {
    String day = datetime.day.toString();
    String month = datetime.month.toString();
    String year = datetime.year.toString();
    return "$day.$month.$year";
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        timeText(),
        const SizedBox(width: 8),
        dateText(),
      ],
    );
  }

  TextStyle _style(bool condition) => Theme.of(context)
      .textTheme
      .titleMedium!
      .copyWith(color: condition ? Colors.grey : Colors.white);

  InkWell timeText() {
    return InkWell(
      onTap: () => timePicker(),
      onDoubleTap: resetTime,
      onLongPress: pauseTime,
      child: Text(time, style: _style(autoRefreshTime)),
    );
  }

  InkWell dateText() {
    return InkWell(
      onTap: () => datePicker(),
      onDoubleTap: resetDate,
      onLongPress: pauseDate,
      child: Text(date, style: _style(autoRefreshDate)),
    );
  }

  Future<void> datePicker() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: datetime,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        datetime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          datetime.hour,
          datetime.minute,
        );
        pauseDate();
      });
    }
  }

  Future<void> timePicker() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(datetime),
    );
    if (picked != null) {
      setState(() {
        datetime = DateTime(
          datetime.year,
          datetime.month,
          datetime.day,
          picked.hour,
          picked.minute,
        );
        pauseTime();
      });
    }
  }

  void pauseDate() {
    setState(() {
      autoRefreshDate = !autoRefreshDate;
    });
  }

  void pauseTime() {
    setState(() {
      autoRefreshTime = !autoRefreshTime;
    });
  }

  void resetDatetime() {
    setState(() {
      datetime = DateTime.now();
      autoRefreshDate = autoRefreshTime = true;
    });
  }

  void resetDate() {
    setState(() {
      datetime = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        datetime.hour,
        datetime.minute,
      );
      autoRefreshDate = true;
    });
  }

  void resetTime() {
    setState(() {
      datetime = DateTime(
        datetime.year,
        datetime.month,
        datetime.day,
        DateTime.now().hour,
        DateTime.now().minute,
      );
      autoRefreshTime = true;
    });
  }
}
