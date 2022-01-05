import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../flutter_list_view.dart';

class FlutterListView extends CustomScrollView {
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

  final SliverChildDelegate delegate;
  final FlutterListViewController? _controller;

  @override
  List<Widget> buildSlivers(BuildContext context) {
    return [
      FlutterSliverList(
        delegate: delegate,
        controller: _controller?.sliverController,
      )
    ];
  }
}
