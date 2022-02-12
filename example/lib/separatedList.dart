import 'dart:math';

import 'package:flutter_list_view/flutter_list_view.dart';
import 'package:flutter/material.dart';

class SeparatedListPage extends StatefulWidget {
  const SeparatedListPage({Key? key}) : super(key: key);

  @override
  State<SeparatedListPage> createState() => _SeparatedListPageState();
}

class _SeparatedListPageState extends State<SeparatedListPage> {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Separated List"),
      ),
      body: Column(
        children: [
          Expanded(
              child: FlutterListView.separated(
                  itemBuilder: (context, index) => Item(
                        text: data[index],
                        color: colors[index],
                        height: heights[index],
                      ),
                  separatorBuilder: (context, index) => const Divider(
                        height: 1,
                      ),
                  itemCount: data.length)),
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
