import 'chat.dart';
import 'flutter_list_view_performance.dart';
import 'init_jump.dart';
import 'init_jump_after_loaddata.dart';
import 'jump_to_index.dart';
import 'pull_to_refresh_list.dart';
import 'sticky_header.dart';
import 'sticky_header_refresh.dart';
import 'testlist.dart';
import 'home.dart';
import 'package:flutter/widgets.dart';

class SectionViewRoute {
  static const String initialRoute = "/";
  static final Map<String, WidgetBuilder> routes = {
    "/": (context) => Stack(
          children: const [
            HomePage(
              title: "Home",
            ),
          ],
        ),
    "/testListPage": (context) => const TestListPage(),
    "/pullToRefreshList": (context) => const PullToRefreshList(),
    "/stickyHeader": (context) => const StickyHeader(),
    "/stickyHeaderWithRefresh": (context) => const StickyHeaderWithRefresh(),
    "/jumpToIndexPage": (context) => const JumpToIndexPage(),
    "/chat": (context) => const Chat(),
    "/initJumpPage": (context) => const InitJumpPage(),
    "/initJumpAfterLoadDataPage": (context) =>
        const InitJumpAfterLoadDataPage(),
    "/flutterListViewPerformance": (context) =>
        const FlutterListViewPerformance(),
  };
}
