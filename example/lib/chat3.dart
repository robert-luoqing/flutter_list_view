import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_list_view/flutter_list_view.dart';
import 'package:styled_text/styled_text.dart';

class Chat3 extends StatefulWidget {
  const Chat3({Key? key}) : super(key: key);

  @override
  State<Chat3> createState() => _Chat3State();
}

class _Chat3State extends State<Chat3> {
  final easyRefreshController = EasyRefreshController();
  final listViewController = FlutterListViewController();
  var messageList = <Map<String, dynamic>>[];
  _generateMsg() {
    var time = DateTime.now();
    var newMsg = {
      "id": time.microsecondsSinceEpoch.toString(),
      "time": time.toString(),
      "msg": time.toString()
    };
    messageList.insert(0, newMsg);
    setState(() {});
  }

  _generateMsgs() {
    var time = DateTime.now();
    for (int i = 0; i < 10; i++) {
      time = time.add(const Duration(milliseconds: 1));
      var newMsg = {
        "id": time.microsecondsSinceEpoch.toString(),
        "time": time.toString(),
        "msg": time.toString()
      };
      messageList.add(newMsg);
    }
  }

  @override
  void initState() {
    _generateMsgs();
    super.initState();
  }

  Future<void> doLoadAction() async {
    await Future.delayed(const Duration(seconds: 1));
    _generateMsgs();
    easyRefreshController.finishLoad(success: true, noMore: false);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat"),
        actions: [
          TextButton(
              onPressed: _generateMsg,
              child: const Text(
                "Mock To Receive",
                style: TextStyle(color: Colors.white),
              ))
        ],
      ),
      body: _buildMessageDetailList(),
    );
  }

  _buildMessageDetailList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 24),
      child: EasyRefresh(
        controller: easyRefreshController,
        footer: ClassicalFooter(),
        child: FlutterListView(
          reverse: true,
          physics: const BouncingScrollPhysics(),
          controller: listViewController,
          delegate: FlutterListViewDelegate(
            (BuildContext context, int index) => _buildTextMessageDetail(index),
            childCount: messageList.length,
            onItemKey: (index) => messageList[index]["id"],
            keepPosition: false,
            initOffsetBasedOnBottom: true,
            firstItemAlign: FirstItemAlign.end,
            onIsPermanent: (key) => true,
          ),
        ),
        onLoad: doLoadAction,
      ),
    );
  }

  Widget _buildTextMessageDetail(int index) {
    final message = messageList[index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: StyledText.selectable(text: message["time"].toString()),
        ),
        Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.symmetric(vertical: 18),
          decoration: const BoxDecoration(
              color: Colors.yellow,
              borderRadius: BorderRadius.all(Radius.circular(6.66))),
          child: StyledText.selectable(text: message["msg"]),
        )
      ],
    );
  }
}
