import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'chat_list_element.dart';
import 'chat_list_render_data.dart';

class ChatListRender extends RenderSliver with RenderSliverWithKeepAliveMixin {
  ChatListRender({
    required this.childManager,
  });

  final ChatListElement childManager;

  /// Remember the first paint item in viewport
  /// We will use the data to keep position if some items
  /// insert before the item
  ChatListRenderData? _firstPainItemInViewport;
  Offset? _firstPainItemOffset;

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
      if (childManager.getKeyByItemIndex(i) == key) {
        return i;
      }
    }
    for (var i = startIndex - 1; i >= 0; i--) {
      if (childManager.getKeyByItemIndex(i) == key) {
        return i;
      }
    }

    for (var i = endIndex + 1; i < childCount; i++) {
      if (childManager.getKeyByItemIndex(i) == key) {
        return i;
      }
    }

    return null;
  }

  /// The field will indicate next layout will not remove out of scope elements
  bool _ignoreScopeCheckInNext = false;

  @override
  void performLayout() {
    final SliverConstraints constraints = this.constraints;

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

      invokeLayoutCallback((constraints) {
        childManager.removeAllChildren();
      });

      if (childManager.keepFloat &&
          _firstPainItemInViewport != null &&
          constraints.cacheOrigin < 0) {
        /// keep position when insert before rendered item.
        /// 1. find item by itemKey
        /// 2. cache position of the item
        /// To resave performance. we will found on a range
        var matchedIndex = findIndexByKeyAndOldIndex(
            _firstPainItemInViewport!.itemKey, _firstPainItemInViewport!.index);
        if (matchedIndex != null) {
          // Calculate and correct the value
          var itemDy = childManager.getScrollOffsetByIndex(matchedIndex);
          var correctOffsetDy = itemDy - _firstPainItemOffset!.dy;
          if (constraints.scrollOffset != correctOffsetDy) {
            late ChatListRenderData chatElem;
            invokeLayoutCallback((constraints) {
              chatElem = childManager
                  .constructOneIndexElement(matchedIndex, itemDy, []);
            });
            RenderBox child = chatElem.element.renderObject! as RenderBox;
            child.layout(childConstraints, parentUsesSize: true);
            var itemHeight = child.size.height;
            childManager.updateElementPosition(
                spEle: chatElem,
                height: itemHeight,
                needUpdateNextElementOffset: false);

            _ignoreScopeCheckInNext = true;
            geometry = SliverGeometry(
                scrollExtent: childManager.totalItemHeight,
                hasVisualOverflow: true,
                scrollOffsetCorrection:
                    correctOffsetDy - constraints.scrollOffset);
            return;
          }
        }
      }
    }

    List<Element> cachedElements = [];
    if (_ignoreScopeCheckInNext == false) {
      cachedElements =
          childManager.removeOutOfScopeElements(scrollOffset, viewportHeight);
    }

    /// It the prev element's height not same with prefer's
    /// We need correct scrollOffset
    double compensationScroll = 0;

    while (true) {
      ChatListRenderData? spElement;
      invokeLayoutCallback((constraints) {
        spElement = childManager.constructPrevElement(
            scrollOffset, viewportHeight, cachedElements);
      });
      if (spElement == null) break;
      RenderBox child = spElement!.element.renderObject! as RenderBox;
      child.layout(childConstraints, parentUsesSize: true);
      var itemHeight = child.size.height;
      compensationScroll += childManager.updateElementPosition(
          spEle: spElement!,
          height: itemHeight,
          needUpdateNextElementOffset: true);
    }

    while (true) {
      ChatListRenderData? spElement;
      invokeLayoutCallback((constraints) {
        spElement = childManager.constructNextElement(
            scrollOffset, viewportHeight, cachedElements);
      });

      if (spElement == null) break;
      RenderBox child = spElement!.element.renderObject! as RenderBox;
      child.layout(childConstraints, parentUsesSize: true);
      var itemHeight = child.size.height;
      childManager.updateElementPosition(
          spEle: spElement!,
          height: itemHeight,
          needUpdateNextElementOffset: false);
    }

    for (var item in cachedElements) {
      invokeLayoutCallback((constraints) {
        childManager.removeChildElement(item);
      });
    }

    var paintExtent = viewportHeight;
    if (paintExtent > constraints.remainingPaintExtent) {
      paintExtent = constraints.remainingPaintExtent;
    }
    geometry = SliverGeometry(
        scrollExtent: childManager.totalItemHeight,
        paintExtent: paintExtent,
        cacheExtent: viewportHeight,
        maxPaintExtent: paintExtent,
        // Conservative to avoid flickering away the clip during scroll.
        // hasVisualOverflow: endScrollOffset > targetEndScrollOffsetForPaint ||
        //     constraints.scrollOffset > 0.0,
        hasVisualOverflow: true,
        scrollOffsetCorrection:
            compensationScroll == 0 ? null : compensationScroll);
    // print(
    //     "------------------------------->${constraints.scrollOffset}, $compensationScroll");
    _determineStickyElement(childConstraints);
    _ignoreScopeCheckInNext = false;
  }

  void _determineStickyElement(BoxConstraints childConstraints) {
    final double scrollOffset = constraints.scrollOffset;
    final double cacheOrigin = constraints.cacheOrigin;
    if (cacheOrigin < 0) {
      ChatListRenderData? firstElementInViewport;
      ChatListRenderData? prevStickyElement;
      for (var item in childManager.renderedElements) {
        if (item.offset > scrollOffset) {
          firstElementInViewport = item;
          break;
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

      ChatListRenderData? removedSticky;
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
                childManager.constructOneIndexElement(prevStickyIndex!, 0, []);
          });
          RenderBox child =
              prevStickyElement!.element.renderObject! as RenderBox;
          child.layout(childConstraints, parentUsesSize: true);
          var itemHeight = child.size.height;
          childManager.updateElementPosition(
              spEle: prevStickyElement!,
              height: itemHeight,
              needUpdateNextElementOffset: false);
        } else {
          if (childManager.stickyElement != prevStickyElement) {
            removedSticky = childManager.stickyElement;
          }
        }

        childManager.stickyElement = prevStickyElement!;
      } else {
        removedSticky = childManager.stickyElement;
      }

      if (removedSticky != null) {
        invokeLayoutCallback((constraints) {
          childManager.removeChildElement(removedSticky!.element);
        });
      }
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // print("-------offset: ${constraints.scrollOffset}");
    var renderedElements = childManager.renderedElements;
    if (renderedElements.isEmpty) return;

    // offset is to the top-left corner, regardless of our axis direction.
    // originOffset gives us the delta from the real origin to the origin in the axis direction.
    final Offset mainAxisUnit, crossAxisUnit, originOffset;
    final bool addExtent;
    switch (applyGrowthDirectionToAxisDirection(
        constraints.axisDirection, constraints.growthDirection)) {
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

    _firstPainItemInViewport = null;

    for (var chatElement in renderedElements) {
      RenderBox child = chatElement.element.renderObject as RenderBox;
      final double mainAxisDelta = childMainAxisPosition(child);
      final double crossAxisDelta = childCrossAxisPosition(child);
      Offset childOffset = Offset(
        originOffset.dx +
            mainAxisUnit.dx * mainAxisDelta +
            crossAxisUnit.dx * crossAxisDelta,
        originOffset.dy +
            mainAxisUnit.dy * mainAxisDelta +
            crossAxisUnit.dy * crossAxisDelta,
      );
      if (addExtent) childOffset += mainAxisUnit * child.size.height;

      // If the child's visible interval (mainAxisDelta, mainAxisDelta + paintExtentOf(child))
      // does not intersect the paint extent interval (0, constraints.remainingPaintExtent), it's hidden.
      if (mainAxisDelta < constraints.remainingPaintExtent &&
          mainAxisDelta + child.size.height > 0) {
        if (_firstPainItemInViewport == null) {
          _firstPainItemInViewport = chatElement;
          _firstPainItemOffset = childOffset;
        }

        context.paintChild(child, childOffset);
      }
    }
  }

  @override
  void visitChildren(RenderObjectVisitor visitor) {
    for (var item in childManager.renderedElements) {
      visitor(item.element.renderObject!);
    }
  }

  @override
  double childMainAxisPosition(RenderBox child) {
    return childScrollOffset(child)! - constraints.scrollOffset;
  }

  @override
  double? childScrollOffset(RenderObject child) {
    assert(child.parent == this);
    final SliverMultiBoxAdaptorParentData? childParentData =
        child.parentData! as SliverMultiBoxAdaptorParentData;
    return childParentData!.layoutOffset;
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    var renderedElements = childManager.renderedElements;
    for (var element in renderedElements) {
      element.element.renderObject!.attach(owner);
    }
  }

  @override
  void detach() {
    super.detach();
    var renderedElements = childManager.renderedElements;
    for (var element in renderedElements) {
      element.element.renderObject!.detach();
    }
  }
}
