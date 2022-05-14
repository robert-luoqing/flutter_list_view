import 'chat.dart';
import 'chat2.dart';
import 'flutter_list_view_performance.dart';
import 'init_jump.dart';
import 'init_jump_after_loaddata.dart';
import 'init_jump_keep_position.dart';
import 'jump_to_index.dart';
import 'list_view_performance.dart';
import 'permanent_item.dart';
import 'pull_to_refresh_list.dart';
import 'separatedList.dart';
import 'sticky_header.dart';
import 'sticky_header_refresh.dart';
import 'test_keep_alive_issue.dart';
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
    "/chat2": (context) => const Chat2(),
    "/initJumpPage": (context) => const InitJumpPage(),
    "/initJumpAfterLoadDataPage": (context) =>
        const InitJumpAfterLoadDataPage(),
    "/flutterListViewPerformance": (context) =>
        const FlutterListViewPerformance(),
    "/listViewPerformance": (context) => const ListViewPerformance(),
    "/permanentItem": (context) => const PermanentItem(),
    "/separatedListPage": (context) => const SeparatedListPage(),
    "/initJumpKeepPositionPage": (context) => const InitJumpKeepPositionPage(),
    "/testKeepAliveIssue":(context) => const TestKeepAliveIssue(),
  };
}
