import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_list_view/flutter_list_view.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'list_skeleton.dart';

enum MessageType {
  sent,
  receive,
  tag,
}

class ChatModel {
  ChatModel({required this.id, required this.msg, required this.type});
  int id;
  String msg;
  MessageType type;
}

const constKeepPositionOffset = 40.0;

class TestKeepAliveIssueItem extends StatefulWidget {
  const TestKeepAliveIssueItem({Key? key}) : super(key: key);
  @override
  _TestKeepAliveIssueItemState createState() => _TestKeepAliveIssueItemState();
}

class _TestKeepAliveIssueItemState extends State<TestKeepAliveIssueItem>
    with AutomaticKeepAliveClientMixin {
  int currentId = 0;
  List<ChatModel> messages = [];
  final myController = TextEditingController();
  final listViewController = FlutterListViewController();
  final refreshController = RefreshController(initialRefresh: false);

  int initIndex = 0;

  // Fire refresh temp variable
  double prevScrollOffset = 0;
  // keepPositionOffset will be set to 0 during refresh
  double keepPositionOffset = constKeepPositionOffset;

  @override
  void initState() {
    _loadMessages();
    listViewController.addListener(() {
      const torrentDistance = 40;
      var offset = listViewController.offset;
      if (offset <= torrentDistance && prevScrollOffset > torrentDistance) {
        if (!refreshController.isRefresh) {
          refreshController.requestRefresh();
        }
      }

      prevScrollOffset = offset;
    });

    super.initState();
  }

  /// It is mockup to load messages from server
  _loadMessages() async {
    await Future.delayed(const Duration(milliseconds: 100));
    var prevTimes = Random().nextInt(20) + 1;
    for (var i = 0; i < prevTimes; i++) {
      _insertReceiveMessage("The demo also show how to reverse a list in\r\n" *
          (Random().nextInt(4) + 1));
    }
    _insertTagMessage("Last readed");
    var nextTimes = Random().nextInt(20) + 1;
    for (var i = 0; i < nextTimes; i++) {
      _insertReceiveMessage("The demo also show how to reverse a list in\r\n" *
          (Random().nextInt(4) + 1));
    }
    _insertSendMessage(
        "If message more than two screens and scroll over 80px, the scroll not move if a message coming or you input a message");
    _insertSendMessage(
        "It resoved the problem which is when you read a message while a lot of messages coming");
    _insertSendMessage("You can't focus the message content what you read");
    _insertSendMessage(
        "The demo also show how to reverse a list in the controll");
    _insertSendMessage(
        "When reverse the list, the item still show on top of list if the messages didn't fill full screen");

    initIndex = messages.length - prevTimes - 1;
    print("--------------------$initIndex");

    setState(() {});
  }

  _insertSendMessage(String msg, {bool appendToTailer = false}) {
    if (appendToTailer) {
      messages.add(
          ChatModel(id: ++currentId, msg: msg.trim(), type: MessageType.sent));
    } else {
      messages.insert(0,
          ChatModel(id: ++currentId, msg: msg.trim(), type: MessageType.sent));
    }
  }

  _insertReceiveMessage(String msg, {bool appendToTailer = false}) {
    if (appendToTailer) {
      messages.add(ChatModel(
          id: ++currentId, msg: msg.trim(), type: MessageType.receive));
    } else {
      messages.insert(
          0,
          ChatModel(
              id: ++currentId, msg: msg.trim(), type: MessageType.receive));
    }
  }

  _insertTagMessage(String msg) {
    messages.insert(
        0, ChatModel(id: ++currentId, msg: msg.trim(), type: MessageType.tag));
  }

  _mockToReceiveMessage() {
    var times = Random().nextInt(4) + 1;
    for (var i = 0; i < times; i++) {
      _insertReceiveMessage("The demo also show how to reverse a list in\r\n" *
          (Random().nextInt(4) + 1));
    }
    setState(() {});
  }

  _sendMessage() {
    if (myController.text.isNotEmpty) {
      if (messages.isNotEmpty) {
        listViewController.sliverController.jumpToIndex(0);
      }
      setState(() {
        _insertSendMessage(myController.text);
      });

      myController.text = "";
    }
  }

  void _onRefresh() async {
    print("------------------------------------_onRefresh");
    await Future.delayed(const Duration(milliseconds: 2000));
    for (var i = 0; i < 20; i++) {
      _insertReceiveMessage("The demo also show how to reverse a list in\r\n" *
          (Random().nextInt(4) + 1));
    }

    keepPositionOffset = 0;

    refreshController.refreshCompleted();
    if (mounted) {
      setState(() {});

      Future.delayed(const Duration(milliseconds: 50), (() {
        if (mounted) {
          keepPositionOffset = constKeepPositionOffset;
          setState(() {});
        }
      }));
    }
  }

  void _onLoading() async {
    await Future.delayed(const Duration(milliseconds: 1000));

    for (var i = 0; i < 50; i++) {
      _insertReceiveMessage(
          "The demo also show how to append message\r\n" *
              (Random().nextInt(4) + 1),
          appendToTailer: true);
    }

    if (mounted) setState(() {});
    refreshController.loadComplete();
  }

  _renderItem(int index) {
    var msg = messages[index];
    if (msg.type == MessageType.tag) {
      return Align(
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            decoration: const BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.all(Radius.circular(5))),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                msg.msg,
                style: const TextStyle(fontSize: 14.0, color: Colors.white),
              ),
            ),
          ),
        ),
      );
    } else {
      return Align(
        alignment: msg.type == MessageType.sent
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            decoration: BoxDecoration(
                color:
                    msg.type == MessageType.sent ? Colors.blue : Colors.green,
                borderRadius: msg.type == MessageType.sent
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20))
                    : const BorderRadius.only(
                        topRight: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20))),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                msg.msg,
                style: const TextStyle(fontSize: 14.0, color: Colors.white),
              ),
            ),
          ),
        ),
      );
    }
  }

  _renderList() {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      }),
      child: SmartRefresher(
          enablePullDown: true,
          enablePullUp: true,
          header: CustomHeader(
            completeDuration: const Duration(milliseconds: 0),
            builder: (context, mode) {
              Widget body;
              if (mode == RefreshStatus.idle) {
                body = const Text("Pull up load prev msg");
              } else if (mode == RefreshStatus.refreshing) {
                body = const ListSkeleton(line: 2);
              } else if (mode == RefreshStatus.failed) {
                body = const Text("Load Failed!Click retry!");
              } else if (mode == RefreshStatus.canRefresh) {
                body = const Text("Release to load more");
              } else {
                body = const Text("No more Data");
              }
              if (mode == RefreshStatus.completed) {
                return Container();
              } else {
                return RotatedBox(
                  quarterTurns: 2,
                  child: SizedBox(
                    height: 55.0,
                    child: Center(child: body),
                  ),
                );
              }
            },
          ),
          // const WaterDropHeader(),
          footer: CustomFooter(
            builder: (context, mode) {
              Widget body;
              if (mode == LoadStatus.idle) {
                body = const Text("Pull down to load more message");
              } else if (mode == LoadStatus.loading) {
                body = const CupertinoActivityIndicator();
              } else if (mode == LoadStatus.failed) {
                body = const Text("Load Failed!Click retry!");
              } else if (mode == LoadStatus.canLoading) {
                body = const Text("Release to load more");
              } else {
                body = const Text("No more Data");
              }
              return SizedBox(
                height: 55.0,
                child: Center(child: body),
              );
            },
          ),
          controller: refreshController,
          onRefresh: _onRefresh,
          onLoading: _onLoading,
          child: FlutterListView(
              reverse: true,
              controller: listViewController,
              delegate: FlutterListViewDelegate(
                  (BuildContext context, int index) => _renderItem(index),
                  childCount: messages.length,
                  onItemKey: (index) => messages[index].id.toString(),
                  keepPosition: true,
                  keepPositionOffset: 0,
                  initIndex: initIndex,
                  initOffset: 0,
                  initOffsetBasedOnBottom: true,
                  firstItemAlign: FirstItemAlign.end))),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        behavior: HitTestBehavior.opaque,
        child: SafeArea(
            child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(flex: 1, child: _renderList()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(children: [
                  Expanded(
                    child: TextField(
                      controller: myController,
                    ),
                  ),
                  ElevatedButton(
                      onPressed: _sendMessage, child: const Text("Send"))
                ]),
              )
            ],
          ),
        )));
  }

  @override
  void dispose() {
    myController.dispose();
    listViewController.dispose();
    refreshController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}
