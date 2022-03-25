import 'dart:math';

import 'package:flutter_list_view/flutter_list_view.dart';
import 'package:flutter/material.dart';

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

class Chat extends StatefulWidget {
  const Chat({Key? key}) : super(key: key);
  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  int currentId = 0;

  List<ChatModel> messages = [];
  final myController = TextEditingController();
  final FlutterListViewController listViewController =
      FlutterListViewController();
  int lastReadMessageIndex = 0;

  @override
  void initState() {
    _loadMessages();
    super.initState();
  }

  /// It is mockup to load messages from server
  _loadMessages() async {
    await Future.delayed(const Duration(milliseconds: 100));
    var prevTimes = Random().nextInt(30) + 10;
    for (var i = 0; i < prevTimes; i++) {
      _insertReceiveMessage("The demo also show how to reverse a list in\r\n" *
          (Random().nextInt(4) + 1));
    }
    _insertTagMessage("Last readed");
    var nextTimes = Random().nextInt(50) + 1;
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

    lastReadMessageIndex = messages.length - prevTimes - 1;
    print("--------------------$lastReadMessageIndex");

    setState(() {});
  }

  _insertSendMessage(String msg) {
    messages.insert(
        0, ChatModel(id: ++currentId, msg: msg.trim(), type: MessageType.sent));
  }

  _insertReceiveMessage(String msg) {
    messages.insert(0,
        ChatModel(id: ++currentId, msg: msg.trim(), type: MessageType.receive));
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
      setState(() {
        _insertSendMessage(myController.text);
      });
      listViewController.sliverController.jumpToIndex(0);
      myController.text = "";
    }
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
    return FlutterListView(
        reverse: true,
        controller: listViewController,
        delegate: FlutterListViewDelegate(
            (BuildContext context, int index) => _renderItem(index),
            childCount: messages.length,
            onItemKey: (index) => messages[index].id.toString(),
            keepPosition: true,
            keepPositionOffset: 40,
            initIndex: lastReadMessageIndex,
            initOffset: 0,
            initOffsetBasedOnBottom: true,
            firstItemAlign: FirstItemAlign.end));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Chat"),
          actions: [
            TextButton(
                onPressed: _mockToReceiveMessage,
                child: const Text(
                  "Mock To Receive",
                  style: TextStyle(color: Colors.white),
                ))
          ],
        ),
        resizeToAvoidBottomInset: true,
        body: GestureDetector(
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
              ),
            )));
  }

  @override
  void dispose() {
    myController.dispose();
    listViewController.dispose();
    super.dispose();
  }
}
