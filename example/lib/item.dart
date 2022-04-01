import 'dart:math';

import 'package:flutter/material.dart';

class Item extends StatefulWidget {
  const Item({Key? key, required this.index}) : super(key: key);
  final int index;
  @override
  State<Item> createState() => _ItemState();
}

int itemTimes = 0;

class _ItemState extends State<Item> {
  late double height;
  @override
  void initState() {
    itemTimes++;
    // print("==============itemTimes: $itemTimes");
    height = 40 + Random().nextInt(20).toDouble();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: height,
        child: ListTile(
          title: Text("List Item ${widget.index}"),
        ));
  }
}
