import 'package:flutter/material.dart';

import '../flutter_list_view.dart';
import 'flutter_list_view_element.dart';
import 'flutter_list_view_render.dart';

class FlutterSliverList extends SliverWithKeepAliveWidget {
  /// Creates a sliver that places box children in a linear array.
  const FlutterSliverList({Key? key, required this.delegate, this.controller})
      : super(key: key);

  final SliverChildDelegate delegate;
  final FlutterSliverListController? controller;

  @override
  FlutterListViewElement createElement() => FlutterListViewElement(this);

  @override
  FlutterListViewRender createRenderObject(BuildContext context) {
    final FlutterListViewElement element = context as FlutterListViewElement;

    return FlutterListViewRender(childManager: element);
  }
}
