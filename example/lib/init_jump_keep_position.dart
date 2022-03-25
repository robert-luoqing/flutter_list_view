import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_list_view/flutter_list_view.dart';

class InitJumpKeepPositionPage extends StatefulWidget {
  const InitJumpKeepPositionPage({Key? key}) : super(key: key);

  @override
  State<InitJumpKeepPositionPage> createState() =>
      _InitJumpKeepPositionPageState();
}

class _InitJumpKeepPositionPageState extends State<InitJumpKeepPositionPage> {
  int currentId = 0;

  List<Map<String, String>> data = [];
  final _random = Random();
  FlutterListViewController viewController = FlutterListViewController();
  String htmlLine = "<div>Single line</div>";

  @override
  initState() {
    super.initState();
    for (var i = 0; i < 100; i++) {
      data.add({
        "key": currentId.toString(),
        "display": "<div><b>$i</b></div>" +
            List.filled(2 + _random.nextInt(10), '\n').join(htmlLine)
      });
      currentId++;
    }
  }

  @override
  dispose() {
    super.dispose();
  }

  void _insertDataAndRestoreSaveScrollPosition() {
    data.insert(0, {
      "key": currentId.toString(),
      "display": List.filled(2 + _random.nextInt(10), '\n').join(htmlLine)
    });
    currentId++;
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
            child: Scrollbar(
              child: FlutterListView(
                key: ObjectKey(data.hashCode),
                controller: viewController,
                delegate: FlutterListViewDelegate(
                  (BuildContext context, int index) {
                    return Container(
                      color: Colors.white,
                      child: Html(data: data[index]["display"]),
                    );
                  },
                  childCount: data.length,
                  keepPosition: true,
                  keepPositionOffset: 0,
                  onItemKey: (index) {
                    return data[index]["key"]!;
                  },
                  initIndex: 90,
                  firstItemAlign: FirstItemAlign.end,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
