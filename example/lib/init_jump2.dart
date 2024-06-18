import 'dart:math';

import 'package:flutter_list_view/flutter_list_view.dart';
import 'package:flutter/material.dart';

class InitJump2Page extends StatefulWidget {
  const InitJump2Page({Key? key}) : super(key: key);

  @override
  State<InitJump2Page> createState() => _InitJump2PageState();
}

class _InitJump2PageState extends State<InitJump2Page> {
  List<int> chatList = [];
  FlutterListViewController chatListScrollController =
      FlutterListViewController();

  @override
  initState() {
    for (var i = 0; i < 1000; i++) {
      chatList.add(i);
    }
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
        title: const Text("Init Index Test"),
      ),
      body: Column(
        children: [
          Expanded(
              child: FlutterListView(
            controller: chatListScrollController,
            shrinkWrap: true,
            delegate: FlutterListViewDelegate(
              (final BuildContext _, final int index) {
                final item = chatList[index];
                return Container(
                  color: Colors.white,
                  child: SizedBox(
                      height: Random().nextInt(50) + 60,
                      child: ListTile(title: Text('List Item $item'))),
                );
              },
              onItemKey: (final index) => index.toString(),
              childCount: chatList.length,
              initIndex: 50,
              disableCacheItems: true,
            ),
          )),
        ],
      ),
    );
  }
}
