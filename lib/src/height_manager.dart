import 'package:flutter/widgets.dart';

import 'flutter_list_view_delegate.dart';

class MatchScrollOffsetResult {
  MatchScrollOffsetResult({required this.index, required this.accuHeight});
  int index;
  double accuHeight;
}

abstract class HeightManager {
  set delegate(SliverChildDelegate d);
  SliverChildDelegate get delegate;

  double getItemHeight(String key, int index);
  setItemHeight(String key, int index, double height);

  /// Total item height
  double get totalItemHeight;

  /// Calc item height
  /// The method will be invoke when itemCount changed and first loaded
  void calcTotalItemHeight(
      {required int childCount,
      required String Function(int index) getKeyByItemIndex});

  /// It will invoke when the estimate item height difference with actual item height which fetched by layout
  void increaseTotalItemHeight(double diff);

  /// When scroll to a position, it need fetch first item.
  MatchScrollOffsetResult? getFirstItemByScrollOffset(
      {required int childCount,
      required double scrollOffset,
      required double cacheExtent,
      required String Function(int index) getKeyByItemIndex});
}

class CommonHeightManager implements HeightManager {
  /// It will store the height of item which has rendered or provide by feedback
  final Map<String, double> _itemHeights = {};
  SliverChildDelegate? _delegate;

  /// 总的item的高度
  double _totalItemHeight = 0;
  @override
  double get totalItemHeight => _totalItemHeight;

  @override
  set delegate(SliverChildDelegate d) {
    _delegate = d;
  }

  @override
  SliverChildDelegate get delegate => _delegate ?? SliverChildListDelegate([]);

  /// [_itemHeights]维护着已经layout的高度, 如果_itemHeights有，则取这个高度
  /// 没有，则返回preferHeight或后面扩展的接口（要用户提供的Height）
  @override
  double getItemHeight(String key, int index) {
    if (_itemHeights.containsKey(key)) {
      return _itemHeights[key]!;
    } else {
      if (delegate is FlutterListViewDelegate) {
        var flutterListDelegate = delegate as FlutterListViewDelegate;
        if (flutterListDelegate.onItemHeight != null) {
          return flutterListDelegate.onItemHeight!(index);
        } else {
          return flutterListDelegate.preferItemHeight;
        }
      }
      return 50.0;
    }
  }

  @override
  setItemHeight(String key, int index, double height) {
    _itemHeights[key] = height;
  }

  /// 只有当total count发生变化或第一次时，会调用
  @override
  void calcTotalItemHeight(
      {required int childCount,
      required String Function(int index) getKeyByItemIndex}) {
    // To enhance performance when childcount more than 1 milloion
    // Because it will loop 1 milloion times
    // double height = 0;
    // for (var i = 0; i < childCount; i++) {
    //   height += getItemHeight(getKeyByItemIndex(i), i);
    // }
    // _totalItemHeight = height;

    // 以下是重写该方法
    var hasCalced = false;
    if (delegate is FlutterListViewDelegate) {
      var flutterListDelegate = delegate as FlutterListViewDelegate;
      if (flutterListDelegate.onItemKey != null ||
          flutterListDelegate.onItemHeight != null) {
        double height = 0;

        for (var i = 0; i < childCount; i++) {
          height += getItemHeight(getKeyByItemIndex(i), i);
        }
        _totalItemHeight = height;
        hasCalced = true;
      }
    }

    if (hasCalced == false) {
      double height = 0;
      int calcItemCount = 0;
      for (var index in _itemHeights.keys) {
        if (int.parse(index) < childCount) {
          height += _itemHeights[index]!;
          calcItemCount++;
        }
      }
      var itemHeight = 50.0;
      if (delegate is FlutterListViewDelegate) {
        var flutterListDelegate = delegate as FlutterListViewDelegate;
        itemHeight = flutterListDelegate.preferItemHeight;
      }

      height += ((childCount - calcItemCount) * itemHeight);
      _totalItemHeight = height;
    }
  }

  @override
  void increaseTotalItemHeight(double diff) {
    _totalItemHeight += diff;
  }

  @override
  MatchScrollOffsetResult? getFirstItemByScrollOffset(
      {required int childCount,
      required double scrollOffset,
      required double cacheExtent,
      required String Function(int index) getKeyByItemIndex}) {
    // 构造第一个显示的元素
    var accuHeight = 0.0;

    for (var i = 0; i < childCount; i++) {
      double startOffset = scrollOffset - cacheExtent;
      if (startOffset < 0) {
        startOffset = 0;
      }
      var itemHeight = getItemHeight(getKeyByItemIndex(i), i);
      if (accuHeight <= startOffset &&
          (accuHeight + itemHeight) >= startOffset) {
        return MatchScrollOffsetResult(index: i, accuHeight: accuHeight);
      }
      accuHeight += itemHeight;
    }

    return null;
  }
}
