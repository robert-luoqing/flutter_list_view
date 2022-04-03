import 'package:flutter/widgets.dart';

import '../flutter_list_view.dart';
import 'height_manager.dart';

class HeightList {
  final _indexList = <int>[];
  final Map<int, double> _itemHeights = {};

  get indexList => _indexList;

  void addHeight(int index, double height) {
    _itemHeights[index] = height;
    // Maintain the orders
    var length = _indexList.length;
    if (length == 0) {
      _indexList.add(index);
    } else {
      bool found = false;
      int startIndex = 0;
      int endIndex = length - 1;
      int assertIndex = ((endIndex - startIndex) / 2).floor();
      while (true) {
        if (endIndex == startIndex) {
          if (_indexList[startIndex] == index) {
            found = true;
            assertIndex = startIndex;
          } else if (_indexList[startIndex] > index) {
            found = false;
            assertIndex = startIndex;
          } else {
            found = false;
            assertIndex = startIndex + 1;
          }
          break;
        }

        if (_indexList[assertIndex] == index) {
          found = true;
          break;
        } else if (_indexList[assertIndex] > index) {
          endIndex = assertIndex - 1;
          assertIndex = startIndex + ((endIndex - startIndex) / 2).floor();
        } else {
          startIndex = assertIndex + 1;
          assertIndex = startIndex + ((endIndex - startIndex) / 2).floor();
        }
      }
      if (!found) {
        _indexList.insert(assertIndex, index);
      }
    }
  }

  double? getHeight(int index) {
    return _itemHeights[index];
  }

  void clear() {
    _indexList.clear();
    _itemHeights.clear();
  }
}

class EffectiveHeightManager implements HeightManager {
  /// It will store the height of item which has rendered or provide by feedback
  final Map<String, double> _itemHeights = {};

  final HeightList _itemHeightObj = HeightList();

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

  @override
  double getScrollOffsetByIndex(
      {required int index,
      required double offset,
      required bool basedOnBottom,
      required double viewportHeight,
      required String Function(int index) getKeyByItemIndex}) {
    return 0;
  }
}
