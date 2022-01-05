import 'package:flutter_list_view/flutter_list_view.dart';
import 'package:flutter/material.dart';

class ChatModel {
  ChatModel({required this.id, required this.msg});
  int id;
  String msg;
}

class Chat extends StatefulWidget {
  const Chat({Key? key}) : super(key: key);
  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  int currentId = 0;
  List<ChatModel> chatListContents = [];
  final myController = TextEditingController();
  var stackKey = GlobalKey();

  @override
  void initState() {
    _insertMessage(
        "If message more than two screens and scroll over 80px, the scroll not move if a message coming or you input a message");
    _insertMessage(
        "It resoved the problem which is when you read a message while a lot of messages coming");
    _insertMessage("You can't focus the message content what you read");
    _insertMessage("The demo also show how to reverse a list in the controll");
    _insertMessage(
        "When reverse the list, the item still show on top of list if the messages didn't fill full screen");
    super.initState();
  }

  _insertMessage(String msg) {
    chatListContents.insert(0, ChatModel(id: ++currentId, msg: msg.trim()));
  }

  _submitMessage() {
    if (myController.text.isNotEmpty) {
      setState(() {
        _insertMessage(myController.text);
      });
      myController.text = "";
    }
  }

  _renderList() {
    return FlutterListView(
        reverse: true,
        delegate: FlutterListViewDelegate(
            (BuildContext context, int index) => Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      decoration: const BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20))),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          chatListContents[index].msg,
                          style: const TextStyle(
                              fontSize: 14.0, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
            childCount: chatListContents.length,
            onItemKey: (index) => chatListContents[index].id.toString(),
            keepPosition: true,
            keepPositionOffset: 80,
            firstItemAlign: FirstItemAlign.end));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Chat")),
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
                            onPressed: () {
                              _submitMessage();
                            },
                            child: const Text("Send"))
                      ]),
                    )
                  ],
                ),
              ),
            )));
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    myController.dispose();
    super.dispose();
  }
}
