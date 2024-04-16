import 'dart:math';
import 'dart:ui';

import 'package:flutter_list_view/flutter_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

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

class Chat4 extends StatefulWidget {
  const Chat4({Key? key}) : super(key: key);
  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat4> {
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
    var prevTimes = Random().nextInt(20) + 10;
    for (var i = 0; i < prevTimes; i++) {
      _insertReceiveMessage("The demo also show how to reverse a list in\r\n" *
          (Random().nextInt(4) + 10));
    }

    var nextTimes = Random().nextInt(20) + 10;
    for (var i = 0; i < nextTimes; i++) {
      _insertSendMessage("The demo also show how to reverse a list in\r\n" *
          (Random().nextInt(4) + 10));
    }

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
                child: Text(
                  index.toString() + ":" + msg.msg,
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
                child: Text(
                  index.toString() + ":" + msg.msg,
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

  const CollapsibleContainer({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isExpanded = useState(false);
    final isButtonVisible = useState(false);
    final scrollController = useScrollController();

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients &&
            scrollController.position.maxScrollExtent >
                scrollController.position.pixels) {
          isButtonVisible.value = true;
        }
      });

      scrollController.addListener(() {
        if (scrollController.hasClients &&
            scrollController.position.maxScrollExtent >
                scrollController.position.pixels) {
          if (!isButtonVisible.value) {
            isButtonVisible.value = true;
          }
        } else {
          if (isButtonVisible.value) {
            isButtonVisible.value = false;
          }
        }
      });

      return () {};
    }, []);

    Future<void> showMore() async {
      isExpanded.value = true;
    }

    return ConstrainedBox(
      constraints: isExpanded.value
          ? const BoxConstraints()
          : const BoxConstraints(
              minWidth: 30,
              maxHeight: 180,
            ),
      child: Stack(
        children: [
          SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            controller: scrollController,
            child: child,
          ),
          if (isButtonVisible.value && !isExpanded.value) ...[
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
