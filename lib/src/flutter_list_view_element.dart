import '../flutter_list_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'flutter_list_view_render.dart';
import 'flutter_list_view_render_data.dart';

class FlutterListViewElement extends RenderObjectElement {
  FlutterListViewElement(FlutterSliverList widget) : super(widget) {
    if (widget.controller != null) {
      widget.controller!.attach(this);
      if (stickyElement != null) {
        widget.controller!.stickyIndex.value = stickyElement!.index;
      }
    }

    _handleInitIndex(widget.delegate, null);
  }

  _handleInitIndex(
      SliverChildDelegate newDelegate, SliverChildDelegate? oldDelegate) {
    int oldInitIndex = 0;
    int newInitIndex = 0;
    int oldChildCount = 0;
    int newChildCount = 0;
    int? oldForceToExecuteInitIndex;
    int? newForceToExecuteInitIndex;

    double newInitOffset = 0.0;
    bool newInitOffsetBasedOnBottom = false;

    if (oldDelegate != null && oldDelegate is FlutterListViewDelegate) {
      oldInitIndex = oldDelegate.initIndex;
      oldChildCount = oldDelegate.childCount ?? 99999999;
      oldForceToExecuteInitIndex = oldDelegate.forceToExecuteInitIndex;
    }
    if (newDelegate is FlutterListViewDelegate) {
      newInitIndex = newDelegate.initIndex;
      newChildCount = newDelegate.childCount ?? 99999999;
      newInitOffset = newDelegate.initOffset;
      newInitOffsetBasedOnBottom = newDelegate.initOffsetBasedOnBottom;
      newForceToExecuteInitIndex = newDelegate.forceToExecuteInitIndex;
    }

    bool needJump = false;
    if (newChildCount > 0) {
      if (oldInitIndex != newInitIndex && newInitIndex > 0) {
        needJump = true;
      } else if (newInitIndex > 0 && oldChildCount == 0) {
        needJump = true;
      }
    }

    if (oldForceToExecuteInitIndex != newForceToExecuteInitIndex) {
      needJump = true;
    }

    if (needJump) {
      indexShoudBeJumpTo = newInitIndex;
      indexShoudBeJumpOffset = newInitOffset;
      offsetBasedOnBottom = newInitOffsetBasedOnBottom;
      markAsInvalid = true;
    }
  }

  @override
  void update(covariant FlutterSliverList newWidget) {
    final FlutterSliverList oldWidget = widget;
    super.update(newWidget);
    if (oldWidget.controller != newWidget.controller) {
      if (oldWidget.controller != null) {
        oldWidget.controller!.detach();
      }
      if (newWidget.controller != null) {
        newWidget.controller!.attach(this);
        if (stickyElement != null) {
          newWidget.controller!.stickyIndex.value = stickyElement!.index;
        }
      }
    }

    final SliverChildDelegate newDelegate = newWidget.delegate;
    final SliverChildDelegate oldDelegate = oldWidget.delegate;
    if (newDelegate != oldDelegate &&
        (newDelegate.runtimeType != oldDelegate.runtimeType ||
            newDelegate.shouldRebuild(oldDelegate))) performRebuild();
    _handleInitIndex(newDelegate, oldDelegate);
    markAsInvalid = true;
    renderObject.markNeedsLayout();
  }

  /// If the field is true, then next layout will remove all chilrend first
  /// Then create new children according to scrolloffset
  bool markAsInvalid = true;

  /// [indexShoudBeJumpTo] is mean not jump to
  /// [redoJumpIndexTimes] is used to two times evalute the position
  int? indexShoudBeJumpTo;
  double indexShoudBeJumpOffset = 0.0;

  /// [offsetBasedOnBottom] only apply to jumpTo and comunicate with render
  bool offsetBasedOnBottom = false;

  /// When [supressElementGenerate] is true, then notify render don't need
  /// create and drop element, just kepp current element
  bool supressElementGenerate = false;

  /// Does it in scrolling when the user invoke animateToIndex
  /// During scrolling, the item's height will not be save
  /// Because if save the height, the destination offset will not correct
  /// It may cause scroll back
  bool _isInScrolling = false;

  @override
  FlutterSliverList get widget => super.widget as FlutterSliverList;

  ScrollableState? get parentScrollableState {
    ScrollableState? scrollable = Scrollable.of(this);
    return scrollable;
  }

  /// Rendered child element, The elements which only fill one view port
  /// The elements will be reusable
  /// The order of list it the item sequence shows in UI
  final List<FlutterListViewRenderData> _renderedElements = [];
  List<FlutterListViewRenderData> get renderedElements => _renderedElements;

  /// permanentElements is used to hold the element not release once created
  /// And also it will not reused
  /// [permanentElements] key is the item's key or index
  final Map<String, FlutterListViewRenderData> _permanentElements = {};
  Map<String, FlutterListViewRenderData> get permanentElements =>
      _permanentElements;

  /// Current sticky element which show on top of list
  FlutterListViewRenderData? stickyElement;

  /// It will store the height of item which has rendered or provide by feedback
  final Map<String, double> _itemHeights = {};

  /// The cache'd element. These element will be reused
  final List<FlutterListViewRenderData> _cachedElements = [];
  List<FlutterListViewRenderData> get cachedElements => _cachedElements;

  /// 总的item的高度
  double _totalItemHeight = 0;

  double get totalItemHeight => _totalItemHeight;

  void jumpToIndex(int index, double offset, bool basedOnBottom) {
    assert(index >= 0 && index < childCount,
        "Index should be >=0 and  <= child count");
    indexShoudBeJumpTo = index;
    indexShoudBeJumpOffset = offset;
    offsetBasedOnBottom = basedOnBottom;
    markAsInvalid = true;
    renderObject.markNeedsLayout();
  }

  Future<void> animateToIndex(int index,
      {required double offset,
      required bool basedOnBottom,
      required Duration duration,
      required Curve curve}) async {
    assert(index >= 0 && index < childCount,
        "Index should be >=0 and  <= child count");

    var scrollOffset = getScrollOffsetByIndex(index);
    var flutterListViewRender = renderObject as FlutterListViewRender;
    var viewportHeight = flutterListViewRender.currentViewportHeight ?? 0;

    if (basedOnBottom) {
      var itemHeight = getItemHeight(getKeyByItemIndex(index), index);
      scrollOffset = scrollOffset - (viewportHeight - itemHeight - offset);
    } else {
      scrollOffset -= offset;
    }

    if (scrollOffset < 0) scrollOffset = 0;

    supressElementGenerate = false;
    if (widget.delegate is FlutterListViewDelegate) {
      var flutterListDelegate = widget.delegate as FlutterListViewDelegate;
      supressElementGenerate = flutterListDelegate.isSupressElementGenerate;
    }

    try {
      _isInScrolling = true;
      var position = parentScrollableState?.position;
      await position?.animateTo(scrollOffset, duration: duration, curve: curve);
    } catch (e, s) {
      print("error in animateToIndex in flutter list view element, $e, $s");
    } finally {
      _isInScrolling = false;
      supressElementGenerate = false;
    }

    jumpToIndex(index, offset, basedOnBottom);
  }

  void ensureVisible(int index, double offset, bool basedOnBottom) {
    assert(index >= 0 && index < childCount,
        "Index should be >=0 and  <= child count");
    // paintedElements
    var flutterListViewRender = renderObject as FlutterListViewRender;
    var viewportHeight = flutterListViewRender.currentViewportHeight ?? 0;
    for (var item in flutterListViewRender.paintedElements) {
      if (item.index == index &&
          item.offset > 0 &&
          item.offset + item.height < viewportHeight) {
        return;
      }
    }

    jumpToIndex(index, offset, basedOnBottom);
  }

  /// [notifyPositionChanged] is used to send ScrollNotification
  void notifyPositionChanged() {
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      try {
        var position = parentScrollableState?.position;

        // If current position is not IdleScrollActivity, We don't need notification.
        if (position != null &&
            position.activity != null &&
            position.activity is IdleScrollActivity) {
          position.didStartScroll();
          position.didEndScroll();
        }
      } catch (e, s) {
        print(
            "error in notifyPositionChanged in flutter list view element, $e, $s");
      }
    });
  }

  void notifyStickyChanged(int? index) {
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      if (widget.controller != null) {
        if (widget.controller!.stickyIndex.value != index) {
          widget.controller!.stickyIndex.value = index;
        }
      }
    });
  }

  void notifyPaintItemPositionsCallback(
      double widgetHeight, List<FlutterListViewItemPosition> paintElements) {
    try {
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        var onPaintItemPositionsCallback =
            widget.controller?.onPaintItemPositionsCallback;
        if (onPaintItemPositionsCallback != null) {
          onPaintItemPositionsCallback(widgetHeight, paintElements);
        }
      });
    } catch (e, s) {
      print("notifyPaintItemPositionsCallback error $e, $s");
    }
  }

  FirstItemAlign get firstItemAlign {
    if (widget.delegate is FlutterListViewDelegate) {
      var flutterListDelegate = widget.delegate as FlutterListViewDelegate;
      return flutterListDelegate.firstItemAlign;
    }
    return FirstItemAlign.start;
  }

  bool get keepPosition {
    if (widget.delegate is FlutterListViewDelegate) {
      var flutterListDelegate = widget.delegate as FlutterListViewDelegate;
      return flutterListDelegate.keepPosition;
    }
    return false;
  }

  double get keepPositionOffset {
    if (widget.delegate is FlutterListViewDelegate) {
      var flutterListDelegate = widget.delegate as FlutterListViewDelegate;
      return flutterListDelegate.keepPositionOffset;
    }
    return 0;
  }

  /// [_itemHeights]维护着已经layout的高度, 如果_itemHeights有，则取这个高度
  /// 没有，则返回preferHeight或后面扩展的接口（要用户提供的Height）
  double getItemHeight(String key, int index) {
    if (_itemHeights.containsKey(key)) {
      return _itemHeights[key]!;
    } else {
      if (widget.delegate is FlutterListViewDelegate) {
        var flutterListDelegate = widget.delegate as FlutterListViewDelegate;
        if (flutterListDelegate.onItemHeight != null) {
          return flutterListDelegate.onItemHeight!(index);
        } else {
          return flutterListDelegate.preferItemHeight;
        }
      }
      return 50.0;
    }
  }

  bool queryIsStickyItemByIndex(int index) {
    if (widget.delegate is FlutterListViewDelegate) {
      var flutterListDelegate = widget.delegate as FlutterListViewDelegate;
      if (flutterListDelegate.onItemSticky != null) {
        return flutterListDelegate.onItemSticky!(index);
      }
    }

    return false;
  }

  bool get stickyAtTailer {
    if (widget.delegate is FlutterListViewDelegate) {
      var flutterListDelegate = widget.delegate as FlutterListViewDelegate;
      return flutterListDelegate.stickyAtTailer;
    }

    return false;
  }

  bool get isSupportSticky {
    if (widget.delegate is FlutterListViewDelegate) {
      var flutterListDelegate = widget.delegate as FlutterListViewDelegate;
      return flutterListDelegate.onItemSticky != null;
    }

    return false;
  }

  setItemHeight(String key, double height) {
    if (!_isInScrolling) {
      _itemHeights[key] = height;
    }
  }

  String getKeyByItemIndex(int index) {
    if (widget.delegate is FlutterListViewDelegate) {
      var flutterListDelegate = widget.delegate as FlutterListViewDelegate;
      if (flutterListDelegate.onItemKey != null) {
        return flutterListDelegate.onItemKey!(index);
      }
    }
    return index.toString();
  }

  /// 只有当total count发生变化或第一次时，会调用
  void calcTotalItemHeight() {
    // To enhance performance when childcount more than 1 milloion
    // Because it will loop 1 milloion times
    // double height = 0;
    // for (var i = 0; i < childCount; i++) {
    //   height += getItemHeight(getKeyByItemIndex(i), i);
    // }
    // _totalItemHeight = height;

    // 以下是重写该方法
    var hasCalced = false;
    if (widget.delegate is FlutterListViewDelegate) {
      var flutterListDelegate = widget.delegate as FlutterListViewDelegate;
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
      if (widget.delegate is FlutterListViewDelegate) {
        var flutterListDelegate = widget.delegate as FlutterListViewDelegate;
        itemHeight = flutterListDelegate.preferItemHeight;
      }

      height += ((childCount - calcItemCount) * itemHeight);
      _totalItemHeight = height;
    }
  }

  double getScrollOffsetByIndex(int index) {
    var offset = 0.0;
    for (var i = 0; i < index; i++) {
      var itemKey = getKeyByItemIndex(i);
      var itemHeight = getItemHeight(itemKey, i);
      offset += itemHeight;
    }
    return offset;
  }

  /// 用于找到并构造当前屏的Element
  /// [scrollOffset]为当前scroll的位置
  void removeOutOfScopeElements(double scrollOffset, double viewportHeight) {
    double cacheExtent = viewportHeight;
    double startOffset = scrollOffset - cacheExtent;
    if (startOffset < 0) {
      startOffset = 0;
    }
    double endOffset = scrollOffset + viewportHeight + cacheExtent;

    /// Remove unrenderable item from [_renderedElements]
    /// Notice remove left and remove right is good for performance.
    /// Remove left out of scope items
    while (_renderedElements.isNotEmpty) {
      var item = _renderedElements[0];
      if ((item.offset + item.height) < startOffset) {
        _renderedElements.removeAt(0);
        putRenderItemToCacheOrPermanent(item);
        if (item == stickyElement) {
          stickyElement = null;
        }
      } else {
        break;
      }
    }

    /// Remove right out of scope
    while (_renderedElements.isNotEmpty) {
      var length = _renderedElements.length;
      var item = _renderedElements[length - 1];
      if (item.offset > endOffset) {
        _renderedElements.removeAt(length - 1);
        putRenderItemToCacheOrPermanent(item);
        if (item == stickyElement) {
          stickyElement = null;
        }
      } else {
        break;
      }
    }
  }

  FlutterListViewRenderData constructOneIndexElement(
      int index, double itemOffset, bool needInsertToRenderElement) {
    var result = _createOrReuseElement(index);
    result.offset = itemOffset;
    if (needInsertToRenderElement) {
      _renderedElements.insert(0, result);
    }

    return result;
  }

  /// [targetScrollOffset] = [scrollOffset]+[cacheOrig]
  /// for example if user set cacheExtent=100, cacheOrig should be [-100, 0]
  FlutterListViewRenderData? constructPrevElement(double targetScrollOffset) {
    // double cacheExtent = viewportHeight;
    double startOffset = targetScrollOffset;
    if (startOffset < 0) {
      startOffset = 0;
    }
    FlutterListViewRenderData? result;

    /// 构造上面的element
    if (_renderedElements.isNotEmpty) {
      var firstElement = _renderedElements[0];
      if (firstElement.offset > startOffset && firstElement.index > 0) {
        var indexOfCreate = firstElement.index - 1;
        result = _createOrReuseElement(indexOfCreate);
        result.offset = firstElement.offset - result.height;
        _renderedElements.insert(0, result);
      }
    }
    return result;
  }

  /// 返回新的与旧的差别
  double updateElementPosition(
      {required FlutterListViewRenderData spEle,
      required double newHeight,
      required bool needUpdateNextElementOffset}) {
    var diff =
        updateElementPosition2(spEle, offset: spEle.offset, height: newHeight);

    // 更新所有后面的offset;
    if (needUpdateNextElementOffset) {
      for (var i = 1; i < _renderedElements.length; i++) {
        var item = _renderedElements[i];
        item.offset += diff;
        final itemParentData = item.element.renderObject!.parentData!
            as SliverMultiBoxAdaptorParentData;
        itemParentData.layoutOffset = item.offset;
      }
    }

    return diff;
  }

  /// 返回新的与旧的差别
  double updateElementPosition2(
    FlutterListViewRenderData spEle, {
    required double offset,
    required double height,
  }) {
    var oldHeight = spEle.height;
    var diff = height - oldHeight;
    _totalItemHeight += diff;
    spEle.offset = offset;
    spEle.height = height;
    final parentData = spEle.element.renderObject!.parentData!
        as SliverMultiBoxAdaptorParentData;
    parentData.layoutOffset = spEle.offset;
    setItemHeight(getKeyByItemIndex(spEle.index), height);
    return diff;
  }

  FlutterListViewRenderData _createOrReuseElement(int index) {
    Element? newElement = fetchItemFromCacheOrPermanent(index);
    if (newElement != null) {
      updateChild(newElement, _build(index), index);
    } else {
      newElement = createChild2(index);
    }

    var itemKey = getKeyByItemIndex(index);
    var height = getItemHeight(itemKey, index);
    var isSticky = queryIsStickyItemByIndex(index);
    var result = FlutterListViewRenderData(
        element: newElement!,
        index: index,
        offset: 0,
        height: height,
        itemKey: itemKey,
        isSticky: isSticky);

    return result;
  }

  Widget? _build(int index) {
    return widget.delegate.build(this, index);
  }

  Element? createChild2(int index) {
    Element? newChild;
    newChild = updateChild(null, _build(index), index);
    return newChild;
  }

  FlutterListViewRenderData? constructNextElement(
      double targetStartScrollOffset, double targetEndScrollOffset) {
    double endOffset = targetEndScrollOffset;

    FlutterListViewRenderData? result;

    /// 构造下面的element
    if (_renderedElements.isNotEmpty) {
      var lastElement = _renderedElements[_renderedElements.length - 1];
      if ((lastElement.offset + lastElement.height) <= endOffset &&
          lastElement.index < childCount - 1) {
        var indexOfCreate = lastElement.index + 1;
        result = _createOrReuseElement(indexOfCreate);
        result.offset = lastElement.offset + lastElement.height;
        _renderedElements.add(result);
      }
    } else {
      // 构造第一个显示的元素
      var accuHeight = 0.0;
      var firstIndex = 0;
      for (var i = 0; i < childCount; i++) {
        double startOffset = targetStartScrollOffset;
        if (startOffset < 0) {
          startOffset = 0;
        }
        var itemHeight = getItemHeight(getKeyByItemIndex(i), i);
        if (accuHeight <= startOffset &&
            (accuHeight + itemHeight) >= startOffset) {
          firstIndex = i;
          result = _createOrReuseElement(firstIndex);
          result.offset = accuHeight;
          _renderedElements.add(result);
          break;
        }
        accuHeight += itemHeight;
      }
    }

    return result;
  }

  void removeChildElement(Element child) {
    final Element? result = updateChild(child, null, null);
    assert(result == null);
  }

  @override
  Element? updateChild(Element? child, Widget? newWidget, Object? newSlot) {
    final SliverMultiBoxAdaptorParentData? oldParentData =
        child?.renderObject?.parentData as SliverMultiBoxAdaptorParentData?;
    Element? newChild;
    owner!.buildScope(this, () {
      newChild = super.updateChild(child, newWidget, newSlot);
    });
    final SliverMultiBoxAdaptorParentData? newParentData =
        newChild?.renderObject?.parentData as SliverMultiBoxAdaptorParentData?;

    // Preserve the old layoutOffset if the renderObject was swapped out.
    if (oldParentData != newParentData &&
        oldParentData != null &&
        newParentData != null) {
      newParentData.layoutOffset = oldParentData.layoutOffset;
    }
    return newChild;
  }

  static double _extrapolateMaxScrollOffset(
    int firstIndex,
    int lastIndex,
    double leadingScrollOffset,
    double trailingScrollOffset,
    int childCount,
  ) {
    if (lastIndex == childCount - 1) return trailingScrollOffset;
    final int reifiedCount = lastIndex - firstIndex + 1;
    final double averageExtent =
        (trailingScrollOffset - leadingScrollOffset) / reifiedCount;
    final int remainingCount = childCount - lastIndex - 1;
    return trailingScrollOffset + averageExtent * remainingCount;
  }

  /// The best available estimate of [childCount], or null if no estimate is available.
  ///
  /// This differs from [childCount] in that [childCount] never returns null (and must
  /// not be accessed if the child count is not yet available, meaning the [createChild]
  /// method has not been provided an index that does not create a child).
  ///
  /// See also:
  ///
  ///  * [SliverChildDelegate.estimatedChildCount], to which this getter defers.
  int? get estimatedChildCount => widget.delegate.estimatedChildCount;

  @override
  int get childCount {
    int? result = estimatedChildCount;
    if (result == null) {
      // Since childCount was called, we know that we reached the end of
      // the list (as in, _build return null once), so we know that the
      // list is finite.
      // Let's do an open-ended binary search to find the end of the list
      // manually.
      int lo = 0;
      int hi = 1;
      const int max = kIsWeb
          ? 9007199254740992 // max safe integer on JS (from 0 to this number x != x+1)
          : ((1 << 63) - 1);
      while (_build(hi - 1) != null) {
        lo = hi - 1;
        if (hi < max ~/ 2) {
          hi *= 2;
        } else if (hi < max) {
          hi = max;
        } else {
          throw FlutterError(
            'Could not find the number of children in ${widget.delegate}.\n'
            "The childCount getter was called (implying that the delegate's builder returned null "
            'for a positive index), but even building the child with index $hi (the maximum '
            'possible integer) did not return null. Consider implementing childCount to avoid '
            'the cost of searching for the final child.',
          );
        }
      }
      while (hi - lo > 1) {
        final int mid = (hi - lo) ~/ 2 + lo;
        if (_build(mid - 1) == null) {
          hi = mid;
        } else {
          lo = mid;
        }
      }
      result = lo;
    }
    return result;
  }

  @override
  void visitChildren(ElementVisitor visitor) {
    // The toList() is to make a copy so that the underlying list can be modified by
    // the visitor:
    bool stickyElementHasVisited = false;
    for (var item in _renderedElements) {
      visitor(item.element);
      if (item == stickyElement) {
        stickyElementHasVisited = true;
      }
    }

    if (stickyElement != null && stickyElementHasVisited == false) {
      visitor(stickyElement!.element);
    }

    for (var item in cachedElements) {
      visitor(item.element);
    }

    for (var key in permanentElements.keys) {
      visitor(permanentElements[key]!.element);
    }
  }

  @override
  void debugVisitOnstageChildren(ElementVisitor visitor) {
    // _renderedElements.map((e) => e.element).where((Element child) {
    //   final SliverMultiBoxAdaptorParentData parentData =
    //       child.renderObject!.parentData! as SliverMultiBoxAdaptorParentData;
    //   final double itemExtent;
    //   switch (renderObject.constraints.axis) {
    //     case Axis.horizontal:
    //       itemExtent = child.renderObject!.paintBounds.width;
    //       break;
    //     case Axis.vertical:
    //       itemExtent = child.renderObject!.paintBounds.height;
    //       break;
    //   }

    //   return parentData.layoutOffset != null &&
    //       parentData.layoutOffset! <
    //           renderObject.constraints.scrollOffset +
    //               renderObject.constraints.remainingPaintExtent &&
    //       parentData.layoutOffset! + itemExtent >
    //           renderObject.constraints.scrollOffset;
    // }).forEach(visitor);
  }

  @override
  void insertRenderObjectChild(covariant RenderBox child, int slot) {
    renderObject.adoptChild(child);
  }

  @override
  void moveRenderObjectChild(
      covariant RenderObject child, int oldSlot, int newSlot) {}

  @override
  void removeRenderObjectChild(covariant RenderObject child, int slot) {
    renderObject.dropChild(child as RenderBox);
  }

  void removeAllChildren() {
    if (_renderedElements.isNotEmpty) {
      for (var item in _renderedElements) {
        removeChildElement(item.element);
        if (item == stickyElement) {
          stickyElement = null;
        }
      }
      _renderedElements.clear();
    }

    if (stickyElement != null) {
      removeChildElement(stickyElement!.element);
    }
    stickyElement = null;

    for (var item in cachedElements) {
      removeChildElement(item.element);
    }
    cachedElements.clear();

    for (var key in permanentElements.keys) {
      removeChildElement(permanentElements[key]!.element);
    }

    permanentElements.clear();
  }

  void removeAllChildrenToCachedElements() {
    for (var item in _renderedElements) {
      putRenderItemToCacheOrPermanent(item);
      if (item == stickyElement) {
        stickyElement = null;
      }
    }
    _renderedElements.clear();

    if (stickyElement != null) {
      putRenderItemToCacheOrPermanent(stickyElement!);
    }
    stickyElement = null;
  }

  bool isPermanentItem(String key) {
    if (widget.delegate is FlutterListViewDelegate) {
      var flutterListDelegate = widget.delegate as FlutterListViewDelegate;
      if (flutterListDelegate.onIsPermanent != null) {
        return flutterListDelegate.onIsPermanent!(key);
      }
    }
    return false;
  }

  void putRenderItemToCacheOrPermanent(FlutterListViewRenderData item) {
    var key = item.itemKey;
    if (isPermanentItem(key)) {
      if (permanentElements.containsKey(key)) {
        assert(false, "Item key has duplicate when cache permanent item");
      }
      permanentElements[key] = item;
    } else {
      cachedElements.add(item);
    }
  }

  Element? fetchItemFromCacheOrPermanent(int index) {
    Element? newElement;
    var itemKey = getKeyByItemIndex(index);
    if (permanentElements.containsKey(itemKey)) {
      newElement = permanentElements[itemKey]!.element;
      permanentElements.remove(itemKey);
    } else {
      /// PermanentItem will not reused exist cached item.
      /// It will create new one.
      if (!isPermanentItem(itemKey) && cachedElements.isNotEmpty) {
        /// Priority reuse same key elements
        var matchedIndex = 0;
        for (var i = 0; i < cachedElements.length; i++) {
          if (cachedElements[i].itemKey == itemKey) {
            matchedIndex = i;
            break;
          }
        }

        newElement = cachedElements[matchedIndex].element;
        cachedElements.removeAt(matchedIndex);
      }
    }

    return newElement;
  }

  @override
  void unmount() {
    if (widget.controller != null) {
      widget.controller!.detach();
    }
    super.unmount();
  }
}
