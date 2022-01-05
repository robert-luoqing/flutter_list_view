import 'package:flutter_list_view/flutter_list_view.dart';
import 'package:flutter/material.dart';

class TestListPage extends StatefulWidget {
  const TestListPage({Key? key}) : super(key: key);

  @override
  State<TestListPage> createState() => _TestListPageState();
}

class _TestListPageState extends State<TestListPage> {
  ScrollController scrollController = ScrollController();
  FlutterListViewController flutterListViewController =
      FlutterListViewController();
  TextEditingController textController = TextEditingController(text: "");
  bool closeList = false;
  List<int> data = [];
  bool keepPosition = false;
  bool reverse = false;
  FirstItemAlign firstItemAlign = FirstItemAlign.start;
  @override
  initState() {
    for (var i = 0; i < 1000; i++) {
      data.add(i);
    }
    super.initState();
  }

  @override
  dispose() {
    textController.dispose();
    super.dispose();
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
            print(
                "scroll pixel: ${notification.metrics.pixels}, max: ${notification.metrics.maxScrollExtent}");
            return true;
          },
          child: Column(
            children: [
              Wrap(spacing: 20, children: [
                TextField(controller: textController),
                ElevatedButton(
                    onPressed: () {
                      flutterListViewController.jumpToIndex(
                          int.parse(textController.text),
                          offset: 100,
                          offsetBasedOnBottom: true);
                    },
                    child: const Text("Jump")),
                ElevatedButton(
                    onPressed: () {
                      flutterListViewController.animateToIndex(
                          int.parse(textController.text),
                          offset: 0,
                          offsetBasedOnBottom: true,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.ease);
                    },
                    child: const Text("Animite")),
                ElevatedButton(
                    onPressed: () {
                      scrollController
                          .jumpTo(double.parse(textController.text));
                    },
                    child: const Text("Scroll To")),
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
                    FlutterListView(
                        controller: flutterListViewController,
                        delegate: FlutterListViewDelegate(
                            (BuildContext context, int index) {
                          return Container(
                            alignment: Alignment.centerLeft,
                            // color: Colors.lightBlue[100 * (index % 9)],
                            color: Colors.blue,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('List Item ${data[index]}'),
                            ),
                          );
                        },
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
