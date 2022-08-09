import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'dart:async';

import 'package:fr_control/utilities/notification_widget.dart';

class TimerView extends StatefulWidget {
  const TimerView(
      {Key? key, required this.timeCreated, required this.itemDescription})
      : super(key: key);
  final String timeCreated;
  final String itemDescription;

  @override
  State<TimerView> createState() => _TimerViewState();
}

class _TimerViewState extends State<TimerView> {
  Timer? timer;

  @override
  void initState() {
    super.initState();
    NotificationWidget.init();
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        const Duration();
      });
    });
  }

  Duration timePassed() {
    final String timeCreated = widget.timeCreated;
    String now = DateTime.now().toString();

    DateTime dtCreated = DateTime.parse(timeCreated);
    DateTime dtNow = DateTime.parse(now);

    Duration diff = dtNow.difference(dtCreated);

    return diff;
  }

  @override
  Widget build(BuildContext context) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final Duration diff = timePassed();

    final hours = twoDigits(diff.inHours);
    final minutes = twoDigits(diff.inMinutes.remainder(60));
    final seconds = twoDigits(diff.inSeconds.remainder(60));

    if (diff.inHours >= 24) {
      return const Text(
        'Please, check the fitting room.',
        style: TextStyle(fontSize: 18),
      );
    }

    if ((minutes == '30' && seconds == '00') ||
        (diff.inHours > 0 && minutes == '00' && seconds == '00')) {
      NotificationWidget.showNotification(
          title: 'Alert',
          body:
              'The item "${widget.itemDescription}" has been in the fitting room for too long.\nPlease, check the fitting room.');
    }

    return Text(
      '$hours:$minutes:$seconds',
      style: const TextStyle(fontSize: 18),
    );
  }
}
