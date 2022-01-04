import 'package:flutter/widgets.dart';

class FlutterListViewRenderData {
  FlutterListViewRenderData({
    required this.index,
    required this.element,
    required this.offset,
    required this.height,
    required this.itemKey,
    required this.isSticky,
  });
  Element element;
  int index;
  double offset;
  double height;
  String itemKey;
  bool isSticky;
}
