import 'package:flutter/material.dart';
import 'package:flutter_list_view/flutter_list_view.dart';

import 'item.dart';

class FlutterListViewPerformance extends StatefulWidget {
  const FlutterListViewPerformance({Key? key}) : super(key: key);

  @override
  _FlutterListViewPerformanceState createState() =>
      _FlutterListViewPerformanceState();
}

class _FlutterListViewPerformanceState
    extends State<FlutterListViewPerformance> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Test Performance"),
        ),
        body: FlutterListView(
            delegate: SliverChildBuilderDelegate(
          (context, index) {
            return Item(index: index);
          },
          childCount: 1000000,
        )));
  }
}
