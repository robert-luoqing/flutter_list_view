import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed("/pullToRefreshList");
                },
                child: const Text("Intergrate pull to refresh")),
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed("/stickyHeader");
                },
                child: const Text("Sticky Header In List")),
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed("/stickyHeaderWithRefresh");
                },
                child: const Text("Sticky Header With Pull to Refresh")),
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed("/chat");
                },
                child: const Text("Chat")),
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed("/chat2");
                },
                child: const Text("Chat2")),
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed("/jumpToIndexPage");
                },
                child: const Text("Jump to index")),
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed("/initJumpPage");
                },
                child: const Text("Initilize Jump")),
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed("/initJumpAfterLoadDataPage");
                },
                child: const Text("Initilize Jump after load data")),
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed("/testListPage");
                },
                child: const Text("Test List")),
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context)
                      .pushNamed("/flutterListViewPerformance");
                },
                child: const Text("Test Flutter List Performance")),
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed("/listViewPerformance");
                },
                child: const Text("Test List Performance")),
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed("/permanentItem");
                },
                child: const Text("Test Permanent Item")),
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed("/separatedListPage");
                },
                child: const Text("Separated List")),
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed("/initJumpKeepPositionPage");
                },
                child: const Text("Init index and keep position")),
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed("/testKeepAliveIssue");
                },
                child: const Text("Test Keep Alive Issue")),
          ],
        ),
      ),
    );
  }
}
