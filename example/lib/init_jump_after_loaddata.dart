import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_list_view/flutter_list_view.dart';

class InitJumpAfterLoadDataPage extends StatefulWidget {
  const InitJumpAfterLoadDataPage({Key? key}) : super(key: key);

  @override
  State<InitJumpAfterLoadDataPage> createState() =>
      _InitJumpAfterLoadDataPageState();
}

class _InitJumpAfterLoadDataPageState extends State<InitJumpAfterLoadDataPage> {
  List<String> data = [];
  final _random = Random();
  FlutterListViewController viewController = FlutterListViewController();
  int initIndex = 90;
  double initOffset = 0;
  List<FlutterListViewItemPosition> lastPositions = [];
  String htmlLine = "<div>Single line</div>";
  int forceToExecuteInitIndex = 0;

  @override
  initState() {
    super.initState();

    viewController.sliverController.onPaintItemPositionsCallback =
        (height, positions) {
      lastPositions = positions;
    };

    for (var i = 0; i < 100; i++) {
      data.add("<div><b>$i</b></div>" +
          List.filled(2 + _random.nextInt(10), '\n').join(htmlLine));
    }
  }

  @override
  dispose() {
    super.dispose();
  }

  void _insertDataAndRestoreSaveScrollPosition() {
    initIndex = lastPositions[1].index;
    initOffset = lastPositions[1].offset;

    List<String> newData = [];
    newData.addAll(data);
    newData.insert(
        0, List.filled(2 + _random.nextInt(10), '\n').join(htmlLine));
    data = newData;
    initIndex++;
    forceToExecuteInitIndex++;
    print("---------------index:$initIndex, offset: $initOffset");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Jump to the index what you want"),
      ),
      body: Column(
        children: [
          Wrap(spacing: 20, children: [
            ElevatedButton(
                onPressed: _insertDataAndRestoreSaveScrollPosition,
                child: const Text("Insert line at index 0")),
          ]),
          Expanded(
            child: FlutterListView(
              scrollDirection: Axis.vertical,
              key: ObjectKey(data.hashCode),
              controller: viewController,
              delegate: FlutterListViewDelegate(
                (BuildContext context, int index) {
                  return Container(
                    color: Colors.white,
                    child: Html(data: data[index]),
                  );
                },
                preferItemHeight: 200,
                childCount: data.length,
                initIndex: initIndex,
                forceToExecuteInitIndex: forceToExecuteInitIndex,
                initOffset: initOffset,
                firstItemAlign: FirstItemAlign.end,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
