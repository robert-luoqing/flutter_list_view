import 'dart:ffi';
import 'dart:math';
import 'dart:ui';

import 'package:flutter_list_view/flutter_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

String longString = '''
Long String D
1
2
3
5D
1
2
3D
1
2
3D
1
2
3D
1
2
3
5
5
5
5D
1
2
3
5D
1
2
3D
1
2
3D
1
2
3D
1
2
3
5
5
5D
1
2
3
5D
1
2
3D
1
2
3D
1
2
3D
1
2
3
5
5
5
5
5
''';

List<String> messageList = [
  longString,
  longString,
  longString,
  "collapsible",
  "Wq",
  "Sa",
  "A",
  "a",
  "A",
  "a",
  "A"
      "Q",
  "A",
  "Q",
  "Qw",
  "Qw",
  "Qw",
  "Qw",
  "Q",
  "Qw",
  "1",
  "A",
  "S",
  "S",
  "A",
  "Sas"
      "A",
  "a",
  "S",
  "Q",
  "E",
  "W",
  "Qw",
  "Qw",
  longString,
  "Qw",
  "Sa",
  "Ss",
  longString,
  "Sss",
  "Qw",
  "W",
  "Q",
  longString,
  "Wq",
  "Ww",
  longString,
  "M: scrollController.hasClients  && scrollController.position.maxScrollExtent  >  scrollController.position.pixelsscrollController.hasClients",
  "Dsd",
  "Sss",
  "Ewew",
  "Wq",
  "Q",
  "A",
  "Sd",
  "Sd",
  longString,
  "Ssss",
  "Ssss",
  "Ssss",
  "Ssss",
  "Ssss",
  "Ssss",
  "Ssss",
  "Ssss",
  "Ssss",
  "Ssss",
  "Ssss",
  "Ssss",
  "Ssss",
  "Ssss",
  "Ssss",
  "Ssss",
  "Ssss",
  "Ssss",
  "Ssss",
  "Ssss",
  "Ssss",
  "Ssss",
  "Ssss",
  "Ssss",
  "Ssss",
  "Ssss",
  "Ssss",
  "Ssss",
  longString,
  longString,
  longString,
  "S",
  longString,
  longString,
  longString,
  longString,
  longString,
  "s",
  "Wq",
];

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
  bool expand = false;
}

class DynamicContent extends StatefulWidget {
  const DynamicContent({Key? key}) : super(key: key);
  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<DynamicContent> {
  int currentId = 0;
  List<ChatModel> messages = [];
  final myController = TextEditingController();
  final listViewController = FlutterListViewController();

  /// Using init index to control load first messages
  int initIndex = 0;
  double initOffset = 0.0;
  bool initOffsetBasedOnBottom = true;
  int forceToExecuteInitIndex = 0;

  // Fire refresh temp variable
  double prevScrollOffset = 0;

  List<FlutterListViewItemPosition>? itemPositions;
  double listviewHeight = 0;

  @override
  void initState() {
    _loadMessages();
    listViewController.addListener(() {
      var offset = listViewController.offset;
      prevScrollOffset = offset;
    });

    listViewController.sliverController.onPaintItemPositionsCallback =
        (widgetHeight, positions) {
      itemPositions = positions;
      listviewHeight = widgetHeight;
    };

    super.initState();
  }

  /// It is mockup to load messages from server
  _loadMessages() async {
    await Future.delayed(const Duration(milliseconds: 100));
    // var prevTimes = Random().nextInt(20) + 30;
    // for (var i = 0; i < prevTimes; i++) {
    //   _insertReceiveMessage(
    //       "$i--${"The demo also show how to reverse a list in\r\n" * (Random().nextInt(10) + 1)}");
    // }

    // var nextTimes = Random().nextInt(20) + 30;
    // for (var i = 0; i < nextTimes; i++) {
    //   _insertSendMessage(
    //       '$i--${"The demo also show how to reverse a list in\r\n" * (Random().nextInt(10) + 1)}');
    // }

    // initIndex = messages.length - prevTimes - 1;
    // print("--------------------$initIndex");

    for (var str in messageList) {
      _insertSendMessage(str);
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

  void _onItemExpand(int index) {
    setState(() {
      messages[index].expand = true;
    });
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
              child: CollapsibleContainer(
                index: index,
                onExpand: _onItemExpand,
                expanded: msg.expand,
                child: Text(
                  index.toString() + ": " + msg.msg,
                  style: const TextStyle(fontSize: 14.0, color: Colors.white),
                ),
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
              child: CollapsibleContainer(
                index: index,
                onExpand: _onItemExpand,
                expanded: msg.expand,
                child: Text(
                  index.toString() + ": " + msg.msg,
                  style: const TextStyle(fontSize: 14.0, color: Colors.white),
                ),
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
      child: FlutterListView(
        reverse: true,
        controller: listViewController,
        delegate: FlutterListViewDelegate(
          (BuildContext context, int index) => _renderItem(index),
          childCount: messages.length,
          onItemKey: (index) => messages[index].id.toString(),
          keepPosition: true,
          keepPositionOffset: 40,
          initIndex: initIndex,
          initOffset: initOffset,
          initOffsetBasedOnBottom: initOffsetBasedOnBottom,
          forceToExecuteInitIndex: forceToExecuteInitIndex,
          firstItemAlign: FirstItemAlign.end,
          expandDirectToDownWhenFirstItemAlignToEnd: true,
          // disableCacheItems: true,
          onIsPermanent: (keyOrIndex) => true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Chat"),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    myController.dispose();
    listViewController.dispose();
    super.dispose();
  }
}

class CollapsibleContainer extends HookWidget {
  final Widget child;
  final int index;
  final void Function(int index) onExpand;
  final bool expanded;

  const CollapsibleContainer(
      {Key? key,
      required this.index,
      required this.child,
      required this.onExpand,
      required this.expanded})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isButtonVisible = useState(false);
    final scrollController = useScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients &&
          scrollController.position.maxScrollExtent >
              scrollController.position.pixels) {
        isButtonVisible.value = true;
      }
      // else {
      //   isButtonVisible.value = false;
      // }
    });

    Future<void> showMore() async {
      onExpand(index);
    }

    return ConstrainedBox(
      constraints: expanded
          ? const BoxConstraints()
          : const BoxConstraints(
              minWidth: 160,
              maxHeight: 500,
            ),
      child: Stack(
        children: [
          SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            controller: scrollController,
            child: child,
          ),
          if (isButtonVisible.value && !expanded) ...[
            Positioned.fill(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: GestureDetector(
                  onTap: showMore,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 6, horizontal: 20),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          spreadRadius: 2,
                          blurRadius: 3,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Text(
                      "Load More",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
