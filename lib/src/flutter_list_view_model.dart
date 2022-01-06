import 'package:flutter/widgets.dart';

class FlutterListViewGrowDirectionInfo {
  FlutterListViewGrowDirectionInfo(
      {required this.mainAxisUnit,
      required this.crossAxisUnit,
      required this.originOffset,
      required this.addExtent,
      required this.axisDirection});
  final Offset mainAxisUnit, crossAxisUnit, originOffset;
  final bool addExtent;
  final AxisDirection axisDirection;
}

class FlutterListViewItemPosition {
  FlutterListViewItemPosition(
      {required this.index, required this.offset, required this.height});
  final int index;
  final double offset;
  final double height;
}
