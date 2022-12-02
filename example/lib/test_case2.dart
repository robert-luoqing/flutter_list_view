import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_list_view/flutter_list_view.dart';

class TestCase2 extends StatefulWidget {
  const TestCase2({Key? key}) : super(key: key);

  @override
  State<TestCase2> createState() => _TestCase2State();
}

class _TestCase2State extends State<TestCase2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterListView(
        reverse: true,
        delegate: FlutterListViewDelegate(
          (BuildContext context, int index) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Color(0xFF333333),
              ),
              height: 100,
              child: Builder(
                builder: (BuildContext context) {
                  return GestureDetector(
                    onTap: () {
                      try {
                        var box = context.findRenderObject() as RenderBox;
                        final Offset offset = box.localToGlobal(Offset.zero);
                        var size = box.size;
                        print("---------------------------${offset}");
                      } catch (e) {
                        print(e);
                      }
                    },
                    child: Text(
                      "$index",
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                },
              ),
            );
          },
          childCount: 5,
          firstItemAlign:
              FirstItemAlign.end, //for sure the list is aligning top
        ),
      ),
    );
  }
}
