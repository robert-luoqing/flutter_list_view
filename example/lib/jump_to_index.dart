import 'dart:math';

import 'package:flutter_list_view/flutter_list_view.dart';
import 'package:flutter/material.dart';

class JumpToIndexPage extends StatefulWidget {
  const JumpToIndexPage({Key? key}) : super(key: key);

  @override
  State<JumpToIndexPage> createState() => _JumpToIndexPageState();
}

class _JumpToIndexPageState extends State<JumpToIndexPage> {
  FlutterListViewController controller = FlutterListViewController();
  TextEditingController textController = TextEditingController(text: "50");

  List<int> data = [];
  @override
  initState() {
    for (var i = 0; i < 100000; i++) {
      data.add(i);
    }
    super.initState();
  }

  @override
  dispose() {
    textController.dispose();
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
            TextField(controller: textController),
            ElevatedButton(
                onPressed: () {
                  controller.sliverController
                      .jumpToIndex(int.parse(textController.text));
                },
                child: const Text("Jump")),
            ElevatedButton(
                onPressed: () {
                  controller.sliverController.animateToIndex(
                      int.parse(textController.text),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.ease);
                },
                child: const Text("Animite")),
          ]),
          Expanded(
            child: FlutterListView(
                controller: controller,
                delegate: FlutterListViewDelegate(
                  (BuildContext context, int index) => Item(text: data[index]),
                  childCount: data.length,
                )),
          ),
        ],
      ),
    );
  }
}

class Item extends StatefulWidget {
  const Item({Key? key, required this.text}) : super(key: key);
  final int text;
  @override
  _ItemState createState() => _ItemState();
}

class _ItemState extends State<Item> {
  double height = 40.0;
  Color? color = Colors.white;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          var randomNum = Random().nextInt(100000);
          color = Colors.lightBlue[100 * (randomNum % 9)];
        });
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: height,
        child: Container(
            color: color,
            child: ListTile(title: Text('List Item ${widget.text}'))),
      ),
    );
  }
}
