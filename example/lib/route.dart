import 'package:flutter_list_view_example/dismissable_item_test.dart';
import 'package:flutter_list_view_example/dynamic_content.dart';
import 'package:flutter_list_view_example/init_jump2.dart';
import 'package:flutter_list_view_example/mulitple_slivers.dart';
import 'package:flutter_list_view_example/simple_chat.dart';
import 'package:flutter_list_view_example/sticky_header2.dart';
import 'package:flutter_list_view_example/timer_list_view.dart';

import 'chat.dart';
import 'chat2.dart';
import 'chat3.dart';
import 'expend_reverse.dart';
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
import 'test1.dart';
import 'test_case2.dart';
import 'test_keep_alive_issue.dart';
import 'testlist.dart';
import 'home.dart';
import 'package:flutter/widgets.dart';

class SectionViewRoute {
  static const String initialRoute = "/";
  static final Map<String, WidgetBuilder> routes = {
    "/": (context) => const Stack(
          children: [
            HomePage(
              title: "Home",
            ),
          ],
        ),
    "/testListPage": (context) => const TestListPage(),
    "/pullToRefreshList": (context) => const PullToRefreshList(),
    "/stickyHeader": (context) => const StickyHeader(),
    "/stickyHeader2": (context) => const StickyHeader2(),
    "/stickyHeaderWithRefresh": (context) => const StickyHeaderWithRefresh(),
    "/jumpToIndexPage": (context) => const JumpToIndexPage(),
    "/chat": (context) => const Chat(),
    "/chat2": (context) => const Chat2(),
    "/chat3": (context) => const Chat3(),
    "/simple_chat": (context) => const SimpleChat(),
    "/initJumpPage": (context) => const InitJumpPage(),
    "/initJumpAfterLoadDataPage": (context) =>
        const InitJumpAfterLoadDataPage(),
    "/flutterListViewPerformance": (context) =>
        const FlutterListViewPerformance(),
    "/listViewPerformance": (context) => const ListViewPerformance(),
    "/permanentItem": (context) => const PermanentItem(),
    "/separatedListPage": (context) => const SeparatedListPage(),
    "/initJumpKeepPositionPage": (context) => const InitJumpKeepPositionPage(),
    "/testKeepAliveIssue": (context) => const TestKeepAliveIssue(),
    "/testCase2": (context) => const TestCase2(),
    "/testDismissableItem": (context) => const DismissibleItemTest(),
    "/timerListView": (context) => const TimerListView(),
    "/chat4": (context) => const Chat4(),
    "/dynamicContent": (context) => const DynamicContent(),
    "/test1": (context) => const Test1(),
    "/init_jump2": (context) => TestApiWidget(),
    "/multiple_slivers": (context) => MultipleSlivers()
  };
}
