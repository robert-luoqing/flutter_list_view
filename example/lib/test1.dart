import 'dart:async';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_list_view/flutter_list_view.dart';

class Test1 extends StatefulWidget {
  const Test1({Key? key}) : super(key: key);

  @override
  State<Test1> createState() => _TestHomePageState();
}

class _TestHomePageState extends State<Test1> {
  late EasyRefreshController _controller;

  List<List<int>> newTestData =
      List.generate(8, (index) => [index, index % 2 == 0 ? 50 : 75]);

  FlutterListViewController listViewController = FlutterListViewController();

  StreamController<List<FlutterListViewItemPosition>> streamController =
      StreamController();

  @override
  void initState() {
    super.initState();

    _controller = EasyRefreshController(
      controlFinishRefresh: true,
      controlFinishLoad: true,
    );

    listViewController.sliverController.onPaintItemPositionsCallback =
        (double widgetHeight, List<FlutterListViewItemPosition> positions) {
      var firstIndex = positions.first.index;
      var lastIndex = positions.last.index;

      // if (positions.first.offset + positions.first.height > widgetHeight) {
      //   print('marsru: 第一个偏移量超出屏幕范围，不算做上报');
      // }

      var newList = positions
          .where((pos) => pos.height + pos.offset < widgetHeight)
          .toList();
      streamController.add(newList);
    };
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EasyRefresh'),
      ),
      body: Column(
        children: [
          Expanded(
            child: EasyRefresh(
              controller: _controller,
              footer: const ClassicFooter(infiniteOffset: null),
              onLoad: () async {
                await Future.delayed(const Duration(seconds: 2));
                if (!mounted) {
                  return;
                }
                int last = newTestData.last[0];
                setState(() {
                  newTestData.addAll([
                    [last + 1, (last + 1) % 2 == 0 ? 50 : 75],
                    [last + 2, (last + 2) % 2 == 0 ? 50 : 75]
                  ]);
                });
                _controller.finishLoad(newTestData.length >= 20
                    ? IndicatorResult.noMore
                    : IndicatorResult.success);
              },
              child: FlutterListView(
                reverse: true,
                controller: listViewController,
                delegate: FlutterListViewDelegate(
                  (BuildContext context, int index) =>
                      _buildCard(newTestData[index]),
                  childCount: newTestData.length,
                  firstItemAlign: FirstItemAlign.end,
                  onItemKey: (index) => newTestData[index][0].toString(),
                  keepPosition: true,
                  initOffsetBasedOnBottom: false,
                  initIndex: 6,
                ),
              ),
            ),
          ),
          Row(
            children: [
              TextButton(
                child: const Text('底部插入新消息'),
                onPressed: () {
                  int first = newTestData.first[0];
                  setState(() {
                    newTestData
                        .insert(0, [first - 1, (first - 1) % 2 == 0 ? 50 : 75]);
                  });
                },
              ),
              TextButton(
                child: const Text('跳转至index为9的消息'),
                onPressed: () {
                  listViewController.sliverController.animateToIndex(
                    9,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.linear,
                  );
                },
              ),
            ],
          )
        ],
      ),
    );
  }

  Card _buildCard(List<int> newTestData) {
    return Card(
      child: Container(
        alignment: Alignment.center,
        // height: 200,
        height: newTestData[1].toDouble(),
        child: Text('${newTestData[0]}'),
      ),
    );
  }
}
