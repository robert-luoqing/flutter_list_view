import 'package:chat_list/chat_list.dart';
import 'package:flutter/material.dart';

class TestListPage extends StatefulWidget {
  const TestListPage({Key? key}) : super(key: key);

  @override
  State<TestListPage> createState() => _TestListPageState();
}

class _TestListPageState extends State<TestListPage> {
  ScrollController scrollController = ScrollController();
  bool closeList = false;
  List<int> data = [];
  bool keepPosition = false;
  bool reverse = false;
  FirstItemAlign firstItemAlign = FirstItemAlign.start;
  @override
  initState() {
    for (var i = 0; i < 5; i++) {
      data.add(i);
    }
    super.initState();
  }

  Widget buildSliverList(int itemCount) {
    return SliverFixedExtentList(
      itemExtent: 50.0,
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return Container(
            alignment: Alignment.centerLeft,
            color: Colors.lightBlue[100 * (index % 9)],
            // color: Colors.blue,
            child: Text('List Item $index'),
          );
        },
        childCount: itemCount,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Test"),
        ),
        body: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            // print(
            //     "scroll pixel: ${notification.metrics.pixels}, max: ${notification.metrics.maxScrollExtent}");
            return true;
          },
          child: Column(
            children: [
              Wrap(spacing: 20, children: [
                ElevatedButton(
                    onPressed: () {
                      scrollController.jumpTo(0);
                    },
                    child: const Text("Scroll to 0")),
                ElevatedButton(
                    onPressed: () {
                      scrollController.jumpTo(10000);
                    },
                    child: const Text("Scroll to ...")),
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        closeList = !closeList;
                      });
                    },
                    child: const Text("Switch List")),
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        var i = data[0];
                        data.insert(0, i - 1);
                      });
                    },
                    child: Text("Inset to first: ${data.length}")),
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        var i = data[data.length - 1];
                        data.add(i + 1);
                      });
                    },
                    child: Text("Inset to last: ${data.length}")),
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        keepPosition = (!keepPosition);
                      });
                    },
                    child: Text("Keep Float: $keepPosition")),
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        reverse = (!reverse);
                      });
                    },
                    child: Text("Reverse: $reverse")),
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        if (firstItemAlign == FirstItemAlign.start) {
                          firstItemAlign = FirstItemAlign.end;
                        } else {
                          firstItemAlign = FirstItemAlign.start;
                        }
                      });
                    },
                    child:
                        Text("FirstItemAlign: ${firstItemAlign.toString()}")),
              ]),
              Expanded(
                child: CustomScrollView(
                  //为了能使CustomScrollView拉到顶部时还能继续往下拉，必须让 physics 支持弹性效果
                  // physics: const BouncingScrollPhysics(
                  //     parent: AlwaysScrollableScrollPhysics()),
                  controller: scrollController,
                  reverse: reverse,
                  slivers: [
                    // buildSliverList(15),
                    ChatList(
                        delegate: ChatListDelegate(
                            (BuildContext context, int index) => Container(
                                  alignment: Alignment.centerLeft,
                                  // color: Colors.lightBlue[100 * (index % 9)],
                                  color: Colors.blue,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('List Item ${data[index]}'),
                                  ),
                                ),
                            childCount: data.length,
                            onItemKey: (index) => data[index].toString(),
                            keepPosition: keepPosition,
                            keepPositionOffset: 80,
                            firstItemAlign: firstItemAlign)),
                    // buildSliverList(50),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
