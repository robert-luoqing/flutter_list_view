import 'package:flutter/widgets.dart';

import 'flutter_sliver_list_controller.dart';

class FlutterListViewController extends ScrollController {
  FlutterListViewController()
      : sliverController = FlutterSliverListController(),
        super();
  final FlutterSliverListController sliverController;

  @override
  void dispose() {
    sliverController.dispose();
    super.dispose();
  }
}
