import 'flutter_list_view_delegate.dart';
import 'package:flutter/rendering.dart';
import 'flutter_list_view_element.dart';
import 'flutter_list_view_model.dart';
import 'flutter_list_view_render_data.dart';

class FlutterListViewRender extends RenderSliver
    with RenderSliverWithKeepAliveMixin, RenderSliverHelpers {
  FlutterListViewRender({
    required this.childManager,
  });

  final FlutterListViewElement childManager;

  /// Remember the first paint item in viewport
  /// We will use the data to keep position if some items
  /// insert before the item
  FlutterListViewRenderData? firstPainItemInViewport;
  double? firstPainItemOffsetY;
  Offset? firstPainItemOffset;
  double? currentScrollOffset;
  double? currentViewportHeight;

  /// [_trackedNextStickyElement] is evaluate in performLayout and used it paint
  FlutterListViewRenderData? _trackedNextStickyElement;
  List<FlutterListViewRenderData> paintedElements = [];

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! SliverMultiBoxAdaptorParentData) {
      child.parentData = SliverMultiBoxAdaptorParentData();
    }
  }

  /// The method will keep performance. not loop all item
  /// If not find any item match the key, then return null;
  int? findIndexByKeyAndOldIndex(String key, int oldIndex) {
    // Find the item around the oldIndex first
    var childCount = childManager.childCount;
    int startIndex = oldIndex - 5;
    if (startIndex < 0) startIndex = 0;
    int endIndex = oldIndex + 5;
    if (endIndex >= childCount) endIndex = childCount - 1;

    for (var i = startIndex; i <= endIndex; i++) {
      if (i >= 0 && i < childCount) {
        if (childManager.getKeyByItemIndex(i) == key) {
          return i;
        }
      }
    }
    for (var i = startIndex - 1; i >= 0; i--) {
      if (i >= 0 && i < childCount) {
        if (childManager.getKeyByItemIndex(i) == key) {
          return i;
        }
      }
    }

    for (var i = endIndex + 1; i < childCount; i++) {
      if (i >= 0 && i < childCount) {
        if (childManager.getKeyByItemIndex(i) == key) {
          return i;
        }
      }
    }

    return null;
  }

  List<double> _calcPaintExtentAndCacehExtent() {
    double firstRenderChildOffset = 0;
    double endRenderChildOffset = 0;
    var elements = childManager.renderedElements;
    if (elements.isNotEmpty) {
      firstRenderChildOffset = elements.first.offset;
      var lastElement = elements.last;
      endRenderChildOffset = lastElement.offset + lastElement.height;
    }

    double paintExtent = constraints.viewportMainAxisExtent;

    paintExtent = calculatePaintOffset(
      constraints,
      from: firstRenderChildOffset,
      to: endRenderChildOffset,
    );

    final double cacheExtent = calculateCacheOffset(
      constraints,
      from: firstRenderChildOffset,
      to: endRenderChildOffset,
    );

    return [
      paintExtent,
      cacheExtent,
      firstRenderChildOffset,
      endRenderChildOffset
    ];
  }

  /// The field will indicate next layout will not remove out of scope elements
  /// true: only need correct layout
  bool _isAdjustOperation = false;

  @override
  void performLayout() {
    if (childManager.supressElementGenerate) {
      return;
    }

    final SliverConstraints constraints = this.constraints;

    // layout between start and end
    final double targetStartScrollOffset =
        constraints.scrollOffset + constraints.cacheOrigin;
    final double targetEndScrollOffset =
        targetStartScrollOffset + constraints.remainingCacheExtent;

    // print("cacheOrigin: ${constraints.cacheOrigin}");

    // final double scrollOffset =
    //     constraints.scrollOffset + constraints.cacheOrigin;
    final double scrollOffset = constraints.scrollOffset;
    assert(scrollOffset >= 0.0);
    final double viewportHeight = constraints.viewportMainAxisExtent;
    // final double remainingExtent = constraints.remainingCacheExtent;
    // assert(remainingExtent >= 0.0);
    // final double targetEndScrollOffset = scrollOffset + remainingExtent;
    final BoxConstraints childConstraints = constraints.asBoxConstraints();

    if (childManager.markAsInvalid) {
      childManager.markAsInvalid = false;
      childManager.calcTotalItemHeight();

      childManager.removeAllChildrenToCachedElements();

      final jumpIndex = childManager.indexShoudBeJumpTo;
      final jumpOffset = childManager.indexShoudBeJumpOffset;
      final offsetBasedOnBottom = childManager.offsetBasedOnBottom;
      // Clear it and make sure not effect to next render
      childManager.indexShoudBeJumpTo = null;
      childManager.indexShoudBeJumpOffset = 0.0;
      childManager.offsetBasedOnBottom = false;

      if (jumpIndex != null && jumpIndex < childManager.childCount) {
        if (_handleJump(jumpIndex, jumpOffset, offsetBasedOnBottom,
            viewportHeight, childConstraints)) {
          return;
        }
      } else {
        if (_handleKeepPositionInLayout(viewportHeight, childConstraints)) {
          return;
        }
      }
    }

    if (_isAdjustOperation == false) {
      childManager.removeOutOfScopeElements(scrollOffset, viewportHeight);
    }

    /// It the prev element's height not same with prefer's
    /// We need correct scrollOffset
    double compensationScroll = 0;

    /// Relayout these elements, avoid exception when some child need relayout
    if (childManager.renderedElements.isNotEmpty) {
      double accumulateOffset = childManager.renderedElements[0].offset;
      for (var renderedElement in childManager.renderedElements) {
        RenderBox child = renderedElement.element.renderObject! as RenderBox;
        child.layout(childConstraints, parentUsesSize: true);
        var itemHeight = child.size.height;

        childManager.updateElementPosition2(
          renderedElement,
          offset: accumulateOffset,
          height: itemHeight,
        );

        accumulateOffset += itemHeight;
      }
    }

    /// Construct the element before exist element
    while (true) {
      FlutterListViewRenderData? spElement;
      invokeLayoutCallback((constraints) {
        spElement = childManager.constructPrevElement(targetStartScrollOffset);
      });
      if (spElement == null) break;
      RenderBox child = spElement!.element.renderObject! as RenderBox;
      child.layout(childConstraints, parentUsesSize: true);
      var itemHeight = child.size.height;
      var singleCompensationScroll = childManager.updateElementPosition(
          spEle: spElement!,
          newHeight: itemHeight,
          needUpdateNextElementOffset: true);

      compensationScroll += singleCompensationScroll;
    }

    while (true) {
      FlutterListViewRenderData? spElement;
      invokeLayoutCallback((constraints) {
        spElement = childManager.constructNextElement(
            targetStartScrollOffset, targetEndScrollOffset);
      });

      if (spElement == null) break;
      RenderBox child = spElement!.element.renderObject! as RenderBox;
      child.layout(childConstraints, parentUsesSize: true);
      var itemHeight = child.size.height;
      childManager.updateElementPosition(
          spEle: spElement!,
          newHeight: itemHeight,
          needUpdateNextElementOffset: false);
    }

    // 这段代码用于以下情况
    // 如果记录数为1000, 跳转到每1000条记录时下面会出现空白，并会返弹回去
    // 去掉这个情况，所以加上了这些
    if (_isAdjustOperation) {
      var maxRemainArea = childManager.totalItemHeight - viewportHeight;
      if (childManager.totalItemHeight <= viewportHeight &&
          constraints.scrollOffset > 0) {
        geometry = SliverGeometry(
            scrollExtent: _getScrollExtent(),
            hasVisualOverflow: true,
            scrollOffsetCorrection: -constraints.scrollOffset);
        return;
      } else if (maxRemainArea > 0 &&
          maxRemainArea < (constraints.scrollOffset + compensationScroll)) {
        geometry = SliverGeometry(
            scrollExtent: _getScrollExtent(),
            hasVisualOverflow: true,
            scrollOffsetCorrection: maxRemainArea - constraints.scrollOffset);
        return;
      }
    }

    /// find sticky item and construct it
    if (childManager.isSupportSticky) {
      if (childManager.stickyAtTailer) {
        _determineTailerStickyElement(childConstraints);
      } else {
        _determineHeaderStickyElement(childConstraints);
      }
    }
    // if (childManager.cachedElements.isNotEmpty) {
    //   invokeLayoutCallback((constraints) {
    //     for (var item in childManager.cachedElements) {
    //       childManager.removeChildElement(item.element);
    //     }
    //   });
    //   childManager.cachedElements.clear();
    // }

    var extentResults = _calcPaintExtentAndCacehExtent();
    final double paintExtent = extentResults[0];
    final double cacheExtent = extentResults[1];
    final double firstRenderChildOffset = extentResults[2];
    final double endRenderChildOffset = extentResults[3];

    if (_jumpToElement != null) {
      var elementOffset = _jumpToElement!.offset;
      var currentOffset = scrollOffset + compensationScroll;
      var targetOffsetFromTop = elementOffset - currentOffset;
      var distance = targetOffsetFromTop - _jumpDistanceFromTop;
      if (distance != 0.0) {
        compensationScroll += distance;
      }
      if (scrollOffset + compensationScroll < 0) {
        compensationScroll = -scrollOffset;
      } else if (scrollOffset + compensationScroll >
          childManager.totalItemHeight) {
        compensationScroll = childManager.totalItemHeight - scrollOffset;
      }
    }

    final double targetEndScrollOffsetForPaint =
        constraints.scrollOffset + constraints.remainingPaintExtent;
    geometry = SliverGeometry(
        scrollExtent: _getScrollExtent(),
        paintExtent: _getPaintExtent(paintExtent),
        cacheExtent: _getCacheExtent(cacheExtent),
        maxPaintExtent: _getPaintExtent(paintExtent),
        // Conservative to avoid flickering away the clip during scroll.
        hasVisualOverflow:
            endRenderChildOffset > targetEndScrollOffsetForPaint ||
                constraints.scrollOffset > 0.0,
        // hasVisualOverflow: true,
        scrollOffsetCorrection:
            (compensationScroll < 0.01 && compensationScroll >= -0.01)
                ? null
                : compensationScroll);
    // print("------>scrollExtent:${_getScrollExtent()}, paintExtent:${_getPaintExtent(paintExtent)}， cacheExtent:${_getCacheExtent(cacheExtent)}");
    if (_isAdjustOperation) {
      childManager.notifyPositionChanged();
    }
    _jumpToElement = null;
    _isAdjustOperation = false;
  }

  // [_jumpToElement] Temp restore jumpToElement
  // It used to verify does the jump position is correct
  // [_jumpDistanceFromTop] is store the distance from top
  FlutterListViewRenderData? _jumpToElement;
  double _jumpDistanceFromTop = 0;

  bool _handleJump(
      int jumpIndex,
      double indexShoudBeJumpOffset,
      bool offsetBasedOnBottom,
      double viewportHeight,
      Constraints childConstraints) {
    if (jumpIndex >= 0 && jumpIndex < childManager.childCount) {
      var itemDy = childManager.getScrollOffsetByIndex(jumpIndex);

      invokeLayoutCallback((constraints) {
        _jumpToElement =
            childManager.constructOneIndexElement(jumpIndex, itemDy, true);
      });
      RenderBox child = _jumpToElement!.element.renderObject! as RenderBox;
      child.layout(childConstraints, parentUsesSize: true);
      var itemHeight = child.size.height;
      childManager.updateElementPosition(
          spEle: _jumpToElement!,
          newHeight: itemHeight,
          needUpdateNextElementOffset: false);

      var scrollDy = itemDy - indexShoudBeJumpOffset;
      _jumpDistanceFromTop = indexShoudBeJumpOffset;
      if (offsetBasedOnBottom) {
        scrollDy =
            itemDy - (viewportHeight - (indexShoudBeJumpOffset + itemHeight));
        _jumpDistanceFromTop =
            viewportHeight - (indexShoudBeJumpOffset + itemHeight);
      }

      if (scrollDy < 0) scrollDy = 0;

      if (constraints.scrollOffset != scrollDy) {
        _isAdjustOperation = true;
        geometry = SliverGeometry(
            scrollExtent: _getScrollExtent(),
            hasVisualOverflow: true,
            scrollOffsetCorrection: scrollDy - constraints.scrollOffset);
        return true;
      }
    }

    return false;
  }

  bool _handleKeepPositionInLayout(
      double viewportHeight, Constraints childConstraints) {
    if (childManager.keepPosition &&
        childManager.keepPositionOffset <= constraints.scrollOffset &&
        firstPainItemInViewport != null &&
        constraints.cacheOrigin <= 0 &&
        // constraints.remainingPaintExtent >=
        //     constraints.viewportMainAxisExtent &&
        childManager.totalItemHeight > viewportHeight) {
      /// keep position when insert before rendered item.
      /// 1. find item by itemKey
      /// 2. cache position of the item
      /// To resave performance. we will found on a range
      var matchedIndex = findIndexByKeyAndOldIndex(
          firstPainItemInViewport!.itemKey, firstPainItemInViewport!.index);

      if (matchedIndex != null) {
        // Calculate and correct the value
        var itemDy = childManager.getScrollOffsetByIndex(matchedIndex);
        if (itemDy != firstPainItemOffsetY) {
          // var correctOffsetDy = itemDy - firstPainItemOffset!.dy;
          var correctOffsetDy =
              constraints.scrollOffset + (itemDy - (firstPainItemOffsetY ?? 0));

          if (constraints.scrollOffset != correctOffsetDy) {
            late FlutterListViewRenderData chatElem;
            invokeLayoutCallback((constraints) {
              chatElem = childManager.constructOneIndexElement(
                  matchedIndex, itemDy, true);
            });
            RenderBox child = chatElem.element.renderObject! as RenderBox;
            child.layout(childConstraints, parentUsesSize: true);
            var itemHeight = child.size.height;
            childManager.updateElementPosition(
                spEle: chatElem,
                newHeight: itemHeight,
                needUpdateNextElementOffset: false);
            _isAdjustOperation = true;
            
            var extentResults = _calcPaintExtentAndCacehExtent();
            final double paintExtent = extentResults[0];
            final double cacheExtent = extentResults[1];

            geometry = SliverGeometry(
                scrollExtent: _getScrollExtent(),
                paintExtent: _getPaintExtent(paintExtent),
                cacheExtent: _getCacheExtent(cacheExtent),
                maxPaintExtent: _getPaintExtent(paintExtent),
                hasVisualOverflow: false,
                scrollOffsetCorrection:
                    correctOffsetDy - constraints.scrollOffset);
            return true;
          }
        }
      }
    }

    return false;
  }

  double _getScrollExtent() {
    var totalItemHeight = childManager.totalItemHeight;
    if (childManager.firstItemAlign == FirstItemAlign.end) {
      if (totalItemHeight < constraints.viewportMainAxisExtent) {
        return constraints.viewportMainAxisExtent;
      }
    }

    return totalItemHeight;
  }

  double _getPaintExtent(double origPaintExtent) {
    if (childManager.firstItemAlign == FirstItemAlign.end) {
      var totalItemHeight = childManager.totalItemHeight;
      if (totalItemHeight < constraints.viewportMainAxisExtent) {
        var paintExtent = calculatePaintOffset(
          constraints,
          from: 0,
          to: constraints.viewportMainAxisExtent,
        );
        return paintExtent;
      }
    }

    return origPaintExtent;
  }

  double _getCacheExtent(double origCacehExtent) {
    if (childManager.firstItemAlign == FirstItemAlign.end) {
      var totalItemHeight = childManager.totalItemHeight;
      if (totalItemHeight < constraints.viewportMainAxisExtent) {
        final double cacheExtent = calculateCacheOffset(
          constraints,
          from: 0,
          to: constraints.viewportMainAxisExtent,
        );

        return cacheExtent;
      }
    }
    return origCacehExtent;
  }

  void _determineHeaderStickyElement(BoxConstraints childConstraints) {
    final double scrollOffset = constraints.scrollOffset;
    final double cacheOrigin = constraints.cacheOrigin;
    final double viewportHeight = constraints.viewportMainAxisExtent;
    _trackedNextStickyElement = null;

    /// The three condition indicate it is already reach header in multiple sliver
    if (cacheOrigin <= 0 &&
        constraints.remainingPaintExtent >= viewportHeight &&
        childManager.totalItemHeight > viewportHeight) {
      FlutterListViewRenderData? firstElementInViewport;

      bool oldStickyInRenderedElements = false;
      for (var item in childManager.renderedElements) {
        if (firstElementInViewport == null && item.offset > scrollOffset) {
          firstElementInViewport = item;
        }
        if (item == childManager.stickyElement) {
          oldStickyInRenderedElements = true;
        }

        if (firstElementInViewport != null &&
            _trackedNextStickyElement == null) {
          var isSticky = childManager.queryIsStickyItemByIndex(item.index);
          if (isSticky) {
            _trackedNextStickyElement = item;
          }
        }
      }

      int? prevStickyIndex;
      // Find prev sticky index
      if (firstElementInViewport != null) {
        for (var i = firstElementInViewport.index - 1; i >= 0; i--) {
          var isSticky = childManager.queryIsStickyItemByIndex(i);
          if (isSticky) {
            prevStickyIndex = i;
            break;
          }
        }
      }

      removeOldStickyElement(
          childConstraints, prevStickyIndex, oldStickyInRenderedElements);
    }

    if (childManager.stickyElement != null) {
      childManager.notifyStickyChanged(childManager.stickyElement!.index);
    } else {
      childManager.notifyStickyChanged(null);
    }
  }

  void _determineTailerStickyElement(BoxConstraints childConstraints) {
    final double scrollOffset = constraints.scrollOffset;
    final double cacheOrigin = constraints.cacheOrigin;
    final double viewportHeight = constraints.viewportMainAxisExtent;
    _trackedNextStickyElement = null;

    /// The three condition indicate it is already reach header in multiple sliver
    if (cacheOrigin <= 0 &&
        constraints.remainingPaintExtent >= viewportHeight &&
        childManager.totalItemHeight > viewportHeight) {
      FlutterListViewRenderData? fristOrLastElementInViewport;

      bool oldStickyInRenderedElements = false;

      for (var i = childManager.renderedElements.length - 1; i >= 0; i--) {
        var item = childManager.renderedElements[i];

        if (fristOrLastElementInViewport == null &&
            item.offset + item.height < scrollOffset + viewportHeight) {
          fristOrLastElementInViewport = item;
        }
        if (item == childManager.stickyElement) {
          oldStickyInRenderedElements = true;
        }

        if (fristOrLastElementInViewport != null &&
            _trackedNextStickyElement == null) {
          var isSticky = childManager.queryIsStickyItemByIndex(item.index);
          if (isSticky) {
            _trackedNextStickyElement = item;
          }
        }
      }

      int? prevStickyIndex;
      // Find prev sticky index
      if (fristOrLastElementInViewport != null) {
        for (var i = fristOrLastElementInViewport.index + 1;
            i < childManager.childCount;
            i++) {
          var isSticky = childManager.queryIsStickyItemByIndex(i);
          if (isSticky) {
            prevStickyIndex = i;
            break;
          }
        }
      }

      removeOldStickyElement(
          childConstraints, prevStickyIndex, oldStickyInRenderedElements);
    }

    if (childManager.stickyElement != null) {
      childManager.notifyStickyChanged(childManager.stickyElement!.index);
    } else {
      childManager.notifyStickyChanged(null);
    }
  }

  removeOldStickyElement(BoxConstraints childConstraints, int? prevStickyIndex,
      bool oldStickyInRenderedElements) {
    FlutterListViewRenderData? prevStickyElement;
    FlutterListViewRenderData? removedSticky;
    if (prevStickyIndex != null) {
      // Check the sticky element is in renderElements
      for (var item in childManager.renderedElements) {
        if (item.index == prevStickyIndex) {
          prevStickyElement = item;
          break;
        }
      }
      if (prevStickyElement == null) {
        removedSticky = childManager.stickyElement;
        invokeLayoutCallback((constraints) {
          prevStickyElement =
              childManager.constructOneIndexElement(prevStickyIndex, 0, false);
        });
        RenderBox child = prevStickyElement!.element.renderObject! as RenderBox;
        child.layout(childConstraints, parentUsesSize: true);
        var itemHeight = child.size.height;
        childManager.updateElementPosition(
            spEle: prevStickyElement!,
            newHeight: itemHeight,
            needUpdateNextElementOffset: false);
      } else {
        if (childManager.stickyElement != prevStickyElement) {
          removedSticky = childManager.stickyElement;
        }
      }

      childManager.stickyElement = prevStickyElement!;
    } else {
      removedSticky = childManager.stickyElement;
      childManager.stickyElement = null;
    }

    if (removedSticky != null) {
      if (oldStickyInRenderedElements == false) {
        invokeLayoutCallback((constraints) {
          childManager.removeChildElement(removedSticky!.element);
        });
      }
    }
  }

  FlutterListViewGrowDirectionInfo _getGrowDirectionInfo(Offset offset) {
// offset is to the top-left corner, regardless of our axis direction.
    // originOffset gives us the delta from the real origin to the origin in the axis direction.
    final Offset mainAxisUnit, crossAxisUnit, originOffset;
    final bool addExtent;
    final axisDirection = applyGrowthDirectionToAxisDirection(
        constraints.axisDirection, constraints.growthDirection);
    switch (axisDirection) {
      case AxisDirection.up:
        mainAxisUnit = const Offset(0.0, -1.0);
        crossAxisUnit = const Offset(1.0, 0.0);
        originOffset = offset + Offset(0.0, geometry!.paintExtent);
        addExtent = true;
        break;
      case AxisDirection.right:
        mainAxisUnit = const Offset(1.0, 0.0);
        crossAxisUnit = const Offset(0.0, 1.0);
        originOffset = offset;
        addExtent = false;
        break;
      case AxisDirection.down:
        mainAxisUnit = const Offset(0.0, 1.0);
        crossAxisUnit = const Offset(1.0, 0.0);
        originOffset = offset;
        addExtent = false;
        break;
      case AxisDirection.left:
        mainAxisUnit = const Offset(-1.0, 0.0);
        crossAxisUnit = const Offset(0.0, 1.0);
        originOffset = offset + Offset(geometry!.paintExtent, 0.0);
        addExtent = true;
        break;
    }

    return FlutterListViewGrowDirectionInfo(
        addExtent: addExtent,
        mainAxisUnit: mainAxisUnit,
        crossAxisUnit: crossAxisUnit,
        originOffset: originOffset,
        axisDirection: axisDirection);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    paintedElements.clear();
    var renderedElements = childManager.renderedElements;
    if (renderedElements.isEmpty) return;

    // offset is to the top-left corner, regardless of our axis direction.
    // originOffset gives us the delta from the real origin to the origin in the axis direction.
    var growInfo = _getGrowDirectionInfo(offset);
    firstPainItemInViewport = null;
    Offset? nextStickyOffset;
    var paintElements = <FlutterListViewItemPosition>[];
    // If all element height is not enough fill full screen, all element must be show
    var showAllEmenets = false;
    if (renderedElements.isNotEmpty &&
        renderedElements.last.offset + renderedElements.last.height <
            constraints.viewportMainAxisExtent) {
      showAllEmenets = true;
    }
    for (var renderElement in renderedElements) {
      RenderBox child = renderElement.element.renderObject as RenderBox;
      final double mainAxisDelta = childMainAxisPosition(child);
      final double crossAxisDelta = childCrossAxisPosition(child);

      /// [normalChildOffset] is not care about the axis direction, it just down direction
      var normalMainAxisUnit = const Offset(0.0, 1.0);
      var normalCrossAxisUnit = const Offset(1.0, 0.0);
      var normalChildOffset = Offset(
        offset.dx +
            normalMainAxisUnit.dx * mainAxisDelta +
            normalCrossAxisUnit.dx * crossAxisDelta,
        offset.dy +
            normalMainAxisUnit.dy * mainAxisDelta +
            normalCrossAxisUnit.dy * crossAxisDelta,
      );

      Offset childOffset = Offset(
        growInfo.originOffset.dx +
            growInfo.mainAxisUnit.dx * mainAxisDelta +
            growInfo.crossAxisUnit.dx * crossAxisDelta,
        growInfo.originOffset.dy +
            growInfo.mainAxisUnit.dy * mainAxisDelta +
            growInfo.crossAxisUnit.dy * crossAxisDelta,
      );
      if (growInfo.addExtent) {
        childOffset += growInfo.mainAxisUnit * child.size.height;
      }

      // If the child's visible interval (mainAxisDelta, mainAxisDelta + paintExtentOf(child))
      // does not intersect the paint extent interval (0, constraints.remainingPaintExtent), it's hidden.
      if ((mainAxisDelta < constraints.remainingPaintExtent &&
              mainAxisDelta + child.size.height > 0) ||
          showAllEmenets) {
        if (firstPainItemInViewport == null) {
          firstPainItemInViewport = renderElement;
          firstPainItemOffset = normalChildOffset;
          firstPainItemOffsetY = renderElement.offset;
        }

        if (childManager.firstItemAlign == FirstItemAlign.end) {
          var actualScrollExtent = childManager.totalItemHeight;

          var geometryScrollExtent = geometry!.scrollExtent;
          if (actualScrollExtent < constraints.viewportMainAxisExtent) {
            if (growInfo.axisDirection == AxisDirection.down) {
              childOffset = Offset(
                  childOffset.dx,
                  childOffset.dy +
                      constraints.viewportMainAxisExtent -
                      actualScrollExtent);
            } else {
              childOffset = Offset(
                  childOffset.dx,
                  childOffset.dy +
                      actualScrollExtent -
                      constraints.viewportMainAxisExtent);
            }
          }
        }

        paintElements.add(FlutterListViewItemPosition(
            index: renderElement.index,
            offset: childOffset.dy,
            height: child.size.height));
        if (renderElement != childManager.stickyElement) {
          context.paintChild(child, childOffset);
          paintedElements.add(renderElement);
          if (renderElement == _trackedNextStickyElement) {
            nextStickyOffset = normalChildOffset;
          }
        }
      }
    }

    if (childManager.stickyAtTailer) {
      paintTailerSticky(context, offset, nextStickyOffset, growInfo);
    } else {
      paintHeaderSticky(context, offset, nextStickyOffset, growInfo);
    }

    // Nofify the items has repaint and offset/height may changed
    childManager.notifyPaintItemPositionsCallback(
        constraints.viewportMainAxisExtent, paintElements);

    currentScrollOffset = constraints.scrollOffset;
    currentViewportHeight = constraints.viewportMainAxisExtent;
  }

  void paintHeaderSticky(PaintingContext context, Offset offset,
      Offset? nextStickyOffset, FlutterListViewGrowDirectionInfo growInfo) {
    if (childManager.stickyElement != null) {
      var stickyRenderObj =
          childManager.stickyElement!.element.renderObject! as RenderBox;

      if (nextStickyOffset == null ||
          nextStickyOffset.dy > stickyRenderObj.size.height) {
        var stickyOffsetDy = offset.dy;

        if (growInfo.axisDirection == AxisDirection.up) {
          stickyOffsetDy = offset.dy +
              constraints.viewportMainAxisExtent -
              stickyRenderObj.size.height;
        }
        var childOffset = Offset(offset.dx, stickyOffsetDy);
        context.paintChild(stickyRenderObj, childOffset);
      } else {
        var stickyOffsetDy = nextStickyOffset.dy - stickyRenderObj.size.height;
        if (growInfo.axisDirection == AxisDirection.up) {
          stickyOffsetDy = constraints.viewportMainAxisExtent -
              stickyRenderObj.size.height -
              stickyOffsetDy;
        }
        var childOffset = Offset(0, stickyOffsetDy);
        context.paintChild(stickyRenderObj, childOffset);
      }
      paintedElements.add(childManager.stickyElement!);
    }
  }

  void paintTailerSticky(PaintingContext context, Offset offset,
      Offset? nextStickyOffset, FlutterListViewGrowDirectionInfo growInfo) {
    if (childManager.stickyElement != null) {
      var stickyRenderObj =
          childManager.stickyElement!.element.renderObject! as RenderBox;
      if (nextStickyOffset == null ||
          nextStickyOffset.dy + _trackedNextStickyElement!.height <
              constraints.viewportMainAxisExtent -
                  stickyRenderObj.size.height) {
        var stickyOffsetDy = offset.dy +
            constraints.viewportMainAxisExtent -
            stickyRenderObj.size.height;

        if (growInfo.axisDirection == AxisDirection.up) {
          stickyOffsetDy = offset.dy;
        }
        var childOffset = Offset(offset.dx, stickyOffsetDy);
        context.paintChild(stickyRenderObj, childOffset);
      } else {
        var stickyOffsetDy =
            _trackedNextStickyElement!.height + nextStickyOffset.dy;
        if (growInfo.axisDirection == AxisDirection.up) {
          stickyOffsetDy = constraints.viewportMainAxisExtent -
              nextStickyOffset.dy -
              _trackedNextStickyElement!.height -
              stickyRenderObj.size.height;
        }
        var childOffset = Offset(0, stickyOffsetDy);
        context.paintChild(stickyRenderObj, childOffset);
      }
      paintedElements.add(childManager.stickyElement!);
    }
  }

  @override
  double childMainAxisPosition(RenderBox child) {
    if (childManager.stickyElement != null &&
        childManager.stickyElement!.element.renderObject == child) {
      return 0;
    } else {
      return childScrollOffset(child)! - constraints.scrollOffset;
    }
  }

  @override
  double? childScrollOffset(RenderObject child) {
    assert(child.parent == this);
    final SliverMultiBoxAdaptorParentData? childParentData =
        child.parentData! as SliverMultiBoxAdaptorParentData;
    return childParentData!.layoutOffset;
  }

  void _loopAllRenderObjects(void Function(RenderObject obj) handler) {
    var renderedElements = childManager.renderedElements;
    var stickyElement = childManager.stickyElement;
    var permanentElements = childManager.permanentElements;
    var stickyIsInRenderedElements = false;
    for (var element in renderedElements) {
      handler(element.element.renderObject!);
      if (element == stickyElement) {
        stickyIsInRenderedElements = true;
      }
    }
    if (stickyIsInRenderedElements == false && stickyElement != null) {
      handler(stickyElement.element.renderObject!);
    }

    for (var element in childManager.cachedElements) {
      var eleRenderObj = element.element.renderObject!;
      handler(eleRenderObj);
    }

    for (var key in permanentElements.keys) {
      handler(permanentElements[key]!.element.renderObject!);
    }
  }

  @override
  void visitChildren(RenderObjectVisitor visitor) {
    _loopAllRenderObjects((obj) {
      visitor(obj);
    });
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _loopAllRenderObjects((obj) {
      obj.attach(owner);
    });
  }

  @override
  void detach() {
    super.detach();
    _loopAllRenderObjects((obj) {
      obj.detach();
    });
  }

  @override
  void applyPaintTransform(covariant RenderBox child, Matrix4 transform) {
    // final SliverMultiBoxAdaptorParentData childParentData =
    //     child.parentData! as SliverMultiBoxAdaptorParentData;
    // if (childParentData.index == null) {
    //   // If the child has no index, such as with the prototype of a
    //   // SliverPrototypeExtentList, then it is not visible, so we give it a
    //   // zero transform to prevent it from painting.
    //   transform.setZero();
    // } else {
    applyPaintTransformForBoxChild(child, transform);
    // }
  }

  @override
  bool hitTestChildren(SliverHitTestResult result,
      {required double mainAxisPosition, required double crossAxisPosition}) {
    final BoxHitTestResult boxResult = BoxHitTestResult.wrap(result);
    if (childManager.stickyElement != null) {
      var child = childManager.stickyElement!.element.renderObject as RenderBox;
      if (hitTestBoxChild(boxResult, child,
          mainAxisPosition: mainAxisPosition,
          crossAxisPosition: crossAxisPosition)) {
        return true;
      }
    }
    for (var i = childManager.renderedElements.length - 1; i >= 0; i--) {
      var item = childManager.renderedElements[i];
      if (childManager.stickyElement != item) {
        var child = item.element.renderObject as RenderBox;

        if (hitTestBoxChild(boxResult, child,
            mainAxisPosition: mainAxisPosition,
            crossAxisPosition: crossAxisPosition)) {
          return true;
        }
      }
    }

    return false;
  }

  @override
  bool hitTestBoxChild(BoxHitTestResult result, RenderBox child,
      {required double mainAxisPosition, required double crossAxisPosition}) {
    final bool rightWayUp = _getRightWayUp(constraints);
    double delta = childMainAxisPosition(child);

    if (childManager.firstItemAlign == FirstItemAlign.end) {
      if (childManager.totalItemHeight < constraints.viewportMainAxisExtent) {
        delta = delta +
            (constraints.viewportMainAxisExtent - childManager.totalItemHeight);
      }
    }

    final double crossAxisDelta = childCrossAxisPosition(child);
    double absolutePosition = mainAxisPosition - delta;
    final double absoluteCrossAxisPosition = crossAxisPosition - crossAxisDelta;
    Offset paintOffset, transformedPosition;
    switch (constraints.axis) {
      case Axis.horizontal:
        if (!rightWayUp) {
          absolutePosition = child.size.width - absolutePosition;
          delta = geometry!.paintExtent - child.size.width - delta;
        }
        paintOffset = Offset(delta, crossAxisDelta);
        transformedPosition =
            Offset(absolutePosition, absoluteCrossAxisPosition);
        break;
      case Axis.vertical:
        if (!rightWayUp) {
          absolutePosition = child.size.height - absolutePosition;
          delta = geometry!.paintExtent - child.size.height - delta;
        }
        paintOffset = Offset(crossAxisDelta, delta);
        transformedPosition =
            Offset(absoluteCrossAxisPosition, absolutePosition);
        break;
    }
    return result.addWithOutOfBandPosition(
      paintOffset: paintOffset,
      hitTest: (BoxHitTestResult result) {
        return child.hitTest(result, position: transformedPosition);
      },
    );
  }

  bool _getRightWayUp(SliverConstraints constraints) {
    bool rightWayUp;
    switch (constraints.axisDirection) {
      case AxisDirection.up:
      case AxisDirection.left:
        rightWayUp = false;
        break;
      case AxisDirection.down:
      case AxisDirection.right:
        rightWayUp = true;
        break;
    }
    switch (constraints.growthDirection) {
      case GrowthDirection.forward:
        break;
      case GrowthDirection.reverse:
        rightWayUp = !rightWayUp;
        break;
    }
    return rightWayUp;
  }

  @override
  void applyPaintTransformForBoxChild(RenderBox child, Matrix4 transform) {
    final bool rightWayUp = _getRightWayUp(constraints);
    double delta = childMainAxisPosition(child);
    final double crossAxisDelta = childCrossAxisPosition(child);
    switch (constraints.axis) {
      case Axis.horizontal:
        if (!rightWayUp) {
          delta = geometry!.paintExtent - child.size.width - delta;
        }
        transform.translate(delta, crossAxisDelta);
        break;
      case Axis.vertical:
        if (!rightWayUp) {
          delta = geometry!.paintExtent - child.size.height - delta;
        }
        transform.translate(crossAxisDelta, delta);
        break;
    }
  }
}
