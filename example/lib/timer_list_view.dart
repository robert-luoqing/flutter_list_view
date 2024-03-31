import 'package:flutter/material.dart';
import 'package:flutter_list_view/flutter_list_view.dart';
import 'package:flutter_list_view_example/timer_cell.dart';

class TimerListView extends StatefulWidget {
  const TimerListView({Key? key}) : super(key: key);

  @override
  State<TimerListView> createState() => _TimerListViewState();
}

class _TimerListViewState extends State<TimerListView> {
  List<int> items = List<int>.generate(1000, (int index) => index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FlutterListView(
            delegate: FlutterListViewDelegate(
      (BuildContext context, int index) {
        return Padding(padding: const EdgeInsets.all(10.0), child: TimerCell());
      },
      childCount: items.length,
      // disableCacheItems: true,
    )));
  }
}
