import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:timer_count_down/timer_count_down.dart';

class TimerCell extends StatefulWidget {
  const TimerCell({Key? key}) : super(key: key);

  @override
  State<TimerCell> createState() => _TimerCellState();
}

class _TimerCellState extends State<TimerCell> {
  @override
  Widget build(BuildContext context) {
    return Countdown(
      seconds: 2000,
      build: (BuildContext context, double time) => Text(time.toString()),
      interval: const Duration(milliseconds: 100),
      onFinished: () {
        if (kDebugMode) {
          print('Timer is done!');
        }
      },
    );
  }

  @override
  void deactivate() {
    if (kDebugMode) {
      print('deactivate invoke!');
    }
    super.deactivate();
  }
}
