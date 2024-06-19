import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_list_view/flutter_list_view.dart';

class TestApiWidget extends HookWidget {
  TestApiWidget({super.key});

  @override
  Widget build(final BuildContext context) {
    final chatListScrollController = useMemoized(FlutterListViewController.new);
    final dataList = useState(List.generate(50, (final index) => index + 1));

    void scrollToEdgeListener() {
      if (chatListScrollController.position.atEdge) {
        final isTop = chatListScrollController.position.pixels == 0;
        if (isTop) {
          /// At the top
        } else {
          /// At the bottom
          dataList.value = List.generate(
              dataList.value.length + 50, (final index) => index + 1);
          // Jump to 50.
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            chatListScrollController.sliverController.jumpToIndex(50);
          });
        }
      }
    }

    useEffect(
      () {
        if (dataList.value.isNotEmpty) {
          chatListScrollController.addListener(scrollToEdgeListener);
        }
        return () {
          chatListScrollController.removeListener(scrollToEdgeListener);
        };
      },
      [dataList.value.isNotEmpty],
    );

    return FlutterListView(
      controller: chatListScrollController,
      shrinkWrap: true,
      delegate: FlutterListViewDelegate(
        (final BuildContext _, final int index) {
          final item = dataList.value[index];
          return Container(
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Text(item.toString()),
          );
        },
        onItemKey: (final index) => dataList.value[index].toString(),
        childCount: dataList.value.length,
        initIndex: 10,
        disableCacheItems: true,
      ),
    );
  }
}
