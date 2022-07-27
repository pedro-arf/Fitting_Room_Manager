import 'package:flutter/cupertino.dart';
import 'dart:async';

class TimerView extends StatefulWidget {
  const TimerView({Key? key, required this.timeCreated}) : super(key: key);
  final String timeCreated;

  @override
  State<TimerView> createState() => _TimerViewState();
}

class _TimerViewState extends State<TimerView> {
  Timer? timer;

  @override
  void initState() {
    super.initState();

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

    return Text(
      '$hours:$minutes:$seconds',
      style: const TextStyle(fontSize: 18),
    );
  }
}
