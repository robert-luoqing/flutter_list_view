import 'dart:math';

import 'package:flutter_list_view/flutter_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

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
                    color: Colors.white, child: Html(data: """<div>$index:
        <h1>Demo Page</h1>
        <p>This is a fantastic product that you should buy!</p>
        <h3>Features</h3>
        <ul>
          ${"<li>Item data</li>" * ((index + 1) % 5)}
        </ul>
      </div>"""));
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
