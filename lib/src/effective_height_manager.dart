import 'package:flutter/widgets.dart';

import '../flutter_list_view.dart';
import 'height_manager.dart';

class HeightList {
  final _indexList = <int>[];
  final Map<int, double> _itemHeights = {};

  get indexList => _indexList;

  void setHeight(int index, double height) {
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
          if (endIndex < startIndex) endIndex = startIndex;
          assertIndex = startIndex + ((endIndex - startIndex) / 2).floor();
        } else {
          startIndex = assertIndex + 1;
          if (startIndex > endIndex) startIndex = endIndex;
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
    var existHeight = _itemHeightObj.getHeight(index);
    if (existHeight != null) {
      return existHeight;
    } else {
      if (delegate is FlutterListViewDelegate) {
        var flutterListDelegate = delegate as FlutterListViewDelegate;
        return flutterListDelegate.preferItemHeight;
      }
      return 50.0;
    }
  }

  @override
  setItemHeight(String key, int index, double height) {
    _itemHeightObj.setHeight(index, height);
  }

  /// 只有当total count发生变化或第一次时，会调用
  @override
  void calcTotalItemHeight(
      {required int childCount,
      required String Function(int index) getKeyByItemIndex}) {
    _itemHeightObj.clear();
    var preferHeight = 50.0;
    if (delegate is FlutterListViewDelegate) {
      var flutterListDelegate = delegate as FlutterListViewDelegate;
      preferHeight = flutterListDelegate.preferItemHeight;
    }

    _totalItemHeight = preferHeight * childCount;
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
    var preferHeight = 50.0;
    if (delegate is FlutterListViewDelegate) {
      var flutterListDelegate = delegate as FlutterListViewDelegate;
      preferHeight = flutterListDelegate.preferItemHeight;
    }

    // 估算Index
    double startOffset = scrollOffset - cacheExtent;
    if (startOffset < 0) {
      startOffset = 0;
    }

    var estimateIndex = (startOffset / preferHeight).floor();
    if (estimateIndex >= childCount) {
      estimateIndex = childCount - 1;
    }
    // Estimate offset of estimateIndex
    var estimateOffset = estimateIndex * preferHeight;

    // Fixed estimate offset
    for (var renderedItemIndex in _itemHeightObj._indexList) {
      if (renderedItemIndex <= estimateIndex) {
        var existHeight = _itemHeightObj.getHeight(renderedItemIndex);
        if (existHeight != null) {
          estimateOffset += (existHeight - preferHeight);
        }
      }
    }

    if (estimateOffset <= startOffset) {
      for (var i = estimateIndex + 1; i < childCount; i++) {
        var itemHeight = getItemHeight(getKeyByItemIndex(i), i);
        if (estimateOffset <= startOffset &&
            (estimateOffset + itemHeight) >= startOffset) {
          return MatchScrollOffsetResult(index: i, accuHeight: estimateOffset);
        }
        estimateOffset += itemHeight;
      }
    } else {
      for (var i = estimateIndex - 1; i >= 0; i--) {
        var itemHeight = getItemHeight(getKeyByItemIndex(i), i);
        if (estimateOffset - itemHeight <= startOffset &&
            estimateOffset >= startOffset) {
          return MatchScrollOffsetResult(
              index: i, accuHeight: estimateOffset - itemHeight);
        }
        estimateOffset -= itemHeight;
      }
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
    var preferHeight = 50.0;
    if (delegate is FlutterListViewDelegate) {
      var flutterListDelegate = delegate as FlutterListViewDelegate;
      preferHeight = flutterListDelegate.preferItemHeight;
    }

    // Estimate offset of estimateIndex
    var estimateOffset = index * preferHeight;

    // Fixed estimate offset
    for (var renderedItemIndex in _itemHeightObj._indexList) {
      if (renderedItemIndex <= index) {
        var existHeight = _itemHeightObj.getHeight(renderedItemIndex);
        if (existHeight != null) {
          estimateOffset += (existHeight - preferHeight);
        }
      }
    }

    if (basedOnBottom) {
      var itemHeight = getItemHeight(getKeyByItemIndex(index), index);
      estimateOffset = estimateOffset - (viewportHeight - itemHeight - offset);
    } else {
      estimateOffset -= offset;
    }

    if (estimateOffset < 0) estimateOffset = 0;

    return estimateOffset;
  }
}
