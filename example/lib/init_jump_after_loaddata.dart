import 'dart:math';

import 'package:flutter_list_view/flutter_list_view.dart';
import 'package:flutter/material.dart';

class InitJumpAfterLoadDataPage extends StatefulWidget {
  const InitJumpAfterLoadDataPage({Key? key}) : super(key: key);

  @override
  State<InitJumpAfterLoadDataPage> createState() =>
      _InitJumpAfterLoadDataPageState();
}

class _InitJumpAfterLoadDataPageState extends State<InitJumpAfterLoadDataPage> {
  List<int> data = [];
  @override
  initState() {
    super.initState();
  }

  @override
  dispose() {
    super.dispose();
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
                onPressed: () {
                  setState(() {
                    for (var i = 0; i < 1000; i++) {
                      data.add(i);
                    }
                  });
                },
                child: const Text("Load data")),
          ]),
          Expanded(
            child: FlutterListView(
                delegate: FlutterListViewDelegate(
              (BuildContext context, int index) {
                return Container(
                  height: 40 + (index % 10) * 10,
                  color: Colors.white,
                  child: ListTile(
                    title: Text('List Item ${data[index]}'),
                    subtitle:const Text("Sub title"),
                  ),
                );
              },
              preferItemHeight: 200,
              childCount: data.length,
              initIndex: 400,
              initOffset: 40,
              // initOffsetBasedOnBottom: false,
              firstItemAlign: FirstItemAlign.end,
            )),
          ),
        ],
      ),
    );
  }
}
