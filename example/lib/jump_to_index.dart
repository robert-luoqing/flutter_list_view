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
  TextEditingController indexTextController =
      TextEditingController(text: "5000");
  TextEditingController offsetTextController =
      TextEditingController(text: "60");

  List<int> data = [];
  List<double> heights = [];
  List<Color> colors = [];
  bool alignToBottom = false;
  @override
  initState() {
    for (var i = 0; i < 100000; i++) {
      data.add(i);
      int height = 35 + Random().nextInt(100);
      heights.add(double.parse(height.toString()));
      colors.add(Colors.lightBlue[100 * (height % 9)] ?? Colors.lightBlue);
    }
    super.initState();
  }

  @override
  dispose() {
    indexTextController.dispose();
    offsetTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Jump or scroll to index"),
      ),
      body: Column(
        children: [
          Row(
            children: [
              const Text("Index: "),
              SizedBox(
                  width: 80, child: TextField(controller: indexTextController)),
              ElevatedButton(
                  onPressed: () async {
                    controller.sliverController.jumpToIndex(
                        int.parse(indexTextController.text),
                        offset: double.parse(offsetTextController.text),
                        offsetBasedOnBottom: alignToBottom);
                    await Future.delayed(const Duration(seconds: 1));
                    // indexTextController.text =
                    //     Random().nextInt((10000)).toString();
                  },
                  child: const Text("Jump")),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ElevatedButton(
                    onPressed: () async {
                      await controller.sliverController.animateToIndex(
                          int.parse(indexTextController.text),
                          offset: double.parse(offsetTextController.text),
                          offsetBasedOnBottom: alignToBottom,
                          duration: const Duration(milliseconds: 3000),
                          curve: Curves.ease);
                      await Future.delayed(const Duration(seconds: 1));
                      // indexTextController.text =
                      //     Random().nextInt((10000)).toString();
                    },
                    child: const Text("Animite")),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ElevatedButton(
                    onPressed: () {
                      controller.sliverController.ensureVisible(
                          int.parse(indexTextController.text),
                          offset: double.parse(offsetTextController.text),
                          offsetBasedOnBottom: alignToBottom);
                    },
                    child: const Text("visible")),
              ),
            ],
          ),
          Row(
            children: [
              const Text("Offset: "),
              SizedBox(
                  width: 80,
                  child: TextField(controller: offsetTextController)),
              Checkbox(
                value: alignToBottom,
                onChanged: (value) {
                  setState(() {
                    alignToBottom = value ?? false;
                  });
                },
              ),
              const Text("Align to Bottom")
            ],
          ),
          Expanded(
            child: FlutterListView(
              controller: controller,
              delegate: FlutterListViewDelegate(
                (BuildContext context, int index) => Item(
                  text: data[index],
                  color: colors[index],
                  height: heights[index],
                ),
                childCount: data.length,
                preferItemHeight: 50,
                // onItemHeight: (context) => 33
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Item extends StatefulWidget {
  const Item(
      {Key? key, required this.text, required this.color, required this.height})
      : super(key: key);
  final int text;
  final Color color;
  final double height;
  @override
  _ItemState createState() => _ItemState();
}

class _ItemState extends State<Item> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: widget.height,
        child: Column(
          children: [
            Expanded(
              child: Container(
                  color: widget.color,
                  child: ListTile(title: Text('List Item ${widget.text}'))),
            ),
            const SizedBox(height: 1, child: Divider()),
          ],
        ),
      ),
    );
  }
}
