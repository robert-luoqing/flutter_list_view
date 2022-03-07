import 'package:flutter/widgets.dart';

import 'flutter_list_view_element.dart';
import 'flutter_list_view_model.dart';

typedef FlutterSliverListControllerOnPaintItemPositionCallback = void Function(
    double widgetHeight, List<FlutterListViewItemPosition> positions);

class FlutterSliverListController {
  final ValueNotifier<int?> stickyIndex = ValueNotifier<int?>(null);

  FlutterSliverListControllerOnPaintItemPositionCallback?
      onPaintItemPositionsCallback;

  FlutterListViewElement? _listView;
  void jumpToIndex(int index,
      {double offset = 0, bool offsetBasedOnBottom = false}) {
    if (_listView != null) {
      _listView!.jumpToIndex(index, offset, offsetBasedOnBottom);
    }
  }

  Future<void> animateToIndex(
    int index, {
    required Duration duration,
    required Curve curve,
    double offset = 0,
    bool offsetBasedOnBottom = false,
  }) async {
    if (_listView != null) {
      await _listView!.animateToIndex(index,
          offset: offset,
          basedOnBottom: offsetBasedOnBottom,
          duration: duration,
          curve: curve);
    }
  }

  void ensureVisible(int index,
      {double offset = 0, bool offsetBasedOnBottom = false}) {
    if (_listView != null) {
      _listView!.ensureVisible(index, offset, offsetBasedOnBottom);
    }
  }

  void attach(FlutterListViewElement listView) {
    _listView = listView;
  }

  void detach() {
    _listView = null;
  }

  void dispose() {
    stickyIndex.dispose();
  }
}
