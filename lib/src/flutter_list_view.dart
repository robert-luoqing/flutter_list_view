import 'package:flutter/material.dart';

import 'flutter_list_view_element.dart';
import 'flutter_list_view_render.dart';

class FlutterListView extends SliverWithKeepAliveWidget {
  /// Creates a sliver that places box children in a linear array.
  const FlutterListView({
    Key? key,
    required this.delegate,
  }) : super(key: key);

  final SliverChildDelegate delegate;

  @override
  FlutterListViewElement createElement() => FlutterListViewElement(this);

  @override
  FlutterListViewRender createRenderObject(BuildContext context) {
    final FlutterListViewElement element = context as FlutterListViewElement;

    return FlutterListViewRender(childManager: element);
  }
}
