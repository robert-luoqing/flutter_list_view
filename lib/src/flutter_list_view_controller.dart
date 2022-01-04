import 'flutter_list_view_element.dart';

class FlutterListViewController {
  FlutterListViewElement? _listView;
  jumpToIndex(int index,
      {double offset = 0, bool offsetBasedOnBottom = false}) {
    if (_listView != null) {
      _listView!.jumpToIndex(index, offset, offsetBasedOnBottom);
    }
  }
  // animiteToIndex(int index) {}

  /// Register the given position with this controller.
  ///
  /// After this function returns, the [animateTo] and [jumpTo] methods on this
  /// controller will manipulate the given position.
  void attach(FlutterListViewElement listView) {
    _listView = listView;
  }

  void detach() {
    _listView = null;
  }
}
