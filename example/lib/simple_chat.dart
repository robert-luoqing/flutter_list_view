import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_list_view/flutter_list_view.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

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

class SimpleChat extends StatefulWidget {
  const SimpleChat({Key? key}) : super(key: key);
  @override
  _SimpleChatState createState() => _SimpleChatState();
}

class _SimpleChatState extends State<SimpleChat> {
  int currentId = 0;
  List<ChatModel> messages = [];
  final myController = TextEditingController();
  final listViewController = FlutterListViewController();

  @override
  void initState() {
    _loadMessages();
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
    var nextTimes = Random().nextInt(20) + 1;
    for (var i = 0; i < nextTimes; i++) {
      _insertReceiveMessage("The demo also show how to reverse a list in\r\n" *
          (Random().nextInt(4) + 1));
    }

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
                  style: TextStyle(color: Colors.black),
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
                    Expanded(
                        flex: 1,
                        child: FlutterListView(
                          reverse: true,
                          controller: listViewController,
                          delegate: FlutterListViewDelegate(
                              (BuildContext context, int index) =>
                                  _renderItem(index),
                              childCount: messages.length,
                              onItemKey: (index) =>
                                  messages[index].id.toString(),
                              keepPosition: true,
                              keepPositionOffset: 40,
                              firstItemAlign: FirstItemAlign.end),
                        )),
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
