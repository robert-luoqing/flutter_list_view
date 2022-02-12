import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../flutter_list_view.dart';
import 'dart:math' as math;

class FlutterListView extends CustomScrollView {
  final SliverChildDelegate delegate;
  final FlutterListViewController? _controller;

  const FlutterListView({
    Key? key,
    required this.delegate,
    FlutterListViewController? controller,
    bool reverse = false,
    Axis scrollDirection = Axis.vertical,
    bool? primary,
    ScrollPhysics? physics,
    ScrollBehavior? scrollBehavior,
    bool shrinkWrap = false,
    Key? center,
    double anchor = 0.0,
    double? cacheExtent,
    int? semanticChildCount,
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
    ScrollViewKeyboardDismissBehavior keyboardDismissBehavior =
        ScrollViewKeyboardDismissBehavior.manual,
    String? restorationId,
    Clip clipBehavior = Clip.hardEdge,
  })  : _controller = controller,
        super(
            key: key,
            controller: controller,
            reverse: reverse,
            scrollDirection: scrollDirection,
            primary: primary,
            physics: physics,
            scrollBehavior: scrollBehavior,
            shrinkWrap: shrinkWrap,
            center: center,
            anchor: anchor,
            cacheExtent: cacheExtent,
            semanticChildCount: semanticChildCount,
            dragStartBehavior: dragStartBehavior,
            restorationId: restorationId,
            clipBehavior: clipBehavior);

  FlutterListView.builder({
    Key? key,
    Axis scrollDirection = Axis.vertical,
    bool reverse = false,
    FlutterListViewController? controller,
    bool? primary,
    ScrollPhysics? physics,
    bool shrinkWrap = false,
    // EdgeInsetsGeometry? padding,
    required IndexedWidgetBuilder itemBuilder,
    int? itemCount,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
    double? cacheExtent,
    int? semanticChildCount,
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
    ScrollViewKeyboardDismissBehavior keyboardDismissBehavior =
        ScrollViewKeyboardDismissBehavior.manual,
    String? restorationId,
    Clip clipBehavior = Clip.hardEdge,
  })  : _controller = controller,
        delegate = SliverChildBuilderDelegate(
          itemBuilder,
          childCount: itemCount,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addRepaintBoundaries: addRepaintBoundaries,
          addSemanticIndexes: addSemanticIndexes,
        ),
        super(
          key: key,
          scrollDirection: scrollDirection,
          reverse: reverse,
          controller: controller,
          primary: primary,
          physics: physics,
          shrinkWrap: shrinkWrap,
          // padding: padding,
          cacheExtent: cacheExtent,
          semanticChildCount: semanticChildCount ?? itemCount,
          dragStartBehavior: dragStartBehavior,
          keyboardDismissBehavior: keyboardDismissBehavior,
          restorationId: restorationId,
          clipBehavior: clipBehavior,
        );

  FlutterListView.separated({
    Key? key,
    Axis scrollDirection = Axis.vertical,
    bool reverse = false,
    FlutterListViewController? controller,
    bool? primary,
    ScrollPhysics? physics,
    bool shrinkWrap = false,
    // EdgeInsetsGeometry? padding,
    required IndexedWidgetBuilder itemBuilder,
    required IndexedWidgetBuilder separatorBuilder,
    required int itemCount,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
    double? cacheExtent,
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
    ScrollViewKeyboardDismissBehavior keyboardDismissBehavior =
        ScrollViewKeyboardDismissBehavior.manual,
    String? restorationId,
    Clip clipBehavior = Clip.hardEdge,
  })  : _controller = controller,
        delegate = SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            final int itemIndex = index ~/ 2;
            final Widget widget;
            if (index.isEven) {
              widget = itemBuilder(context, itemIndex);
            } else {
              widget = separatorBuilder(context, itemIndex);
              assert(() {
                if (widget == null) {
                  throw FlutterError('separatorBuilder cannot return null.');
                }
                return true;
              }());
            }
            return widget;
          },
          childCount: _computeActualChildCount(itemCount),
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addRepaintBoundaries: addRepaintBoundaries,
          addSemanticIndexes: addSemanticIndexes,
          semanticIndexCallback: (Widget _, int index) {
            return index.isEven ? index ~/ 2 : null;
          },
        ),
        super(
          key: key,
          scrollDirection: scrollDirection,
          reverse: reverse,
          controller: controller,
          primary: primary,
          physics: physics,
          shrinkWrap: shrinkWrap,
          //  padding: padding,
          cacheExtent: cacheExtent,
          semanticChildCount: itemCount,
          dragStartBehavior: dragStartBehavior,
          keyboardDismissBehavior: keyboardDismissBehavior,
          restorationId: restorationId,
          clipBehavior: clipBehavior,
        );

  @override
  List<Widget> buildSlivers(BuildContext context) {
    return [
      FlutterSliverList(
        delegate: delegate,
        controller: _controller?.sliverController,
      )
    ];
  }

  static int _computeActualChildCount(int itemCount) {
    return math.max(0, itemCount * 2 - 1);
  }
}
