import 'package:flutter/material.dart';

import 'test_keep_alive_issue_item.dart';


class TestKeepAliveIssue extends StatefulWidget {
  const TestKeepAliveIssue({Key? key}) : super(key: key);

  @override
  State<TestKeepAliveIssue> createState() => _TestKeepAliveIssueState();
}

class _TestKeepAliveIssueState extends State<TestKeepAliveIssue> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: AppBar(
              title: const Text("Host"),
            ),
            body: Column(
              children: [
                const TabBar(tabs: [
                  Tab(
                    icon: Icon(
                      Icons.cloud_outlined,
                      color: Colors.black,
                    ),
                  ),
                  Tab(
                    icon: Icon(Icons.beach_access_sharp, color: Colors.black),
                  ),
                ]),
                Expanded(
                    child: TabBarView(children: [
                  Container(),
                  const TestKeepAliveIssueItem(),
                ]))
              ],
            )));
  }
}
