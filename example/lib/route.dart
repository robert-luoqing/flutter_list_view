import 'pull_to_refresh_list.dart';
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
  };
}
