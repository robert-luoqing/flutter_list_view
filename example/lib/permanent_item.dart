import 'package:flutter/material.dart';
import 'package:flutter_list_view/flutter_list_view.dart';

class PermanentItem extends StatefulWidget {
  const PermanentItem({Key? key}) : super(key: key);

  @override
  _PermanentItemState createState() => _PermanentItemState();
}

class _PermanentItemState extends State<PermanentItem> {
  List<int> data = [];
  @override
  initState() {
    for (var i = 0; i < 10000; i++) {
      data.add(i);
    }
    super.initState();
  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Test permanent item in list"),
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterListView(
                delegate: FlutterListViewDelegate(
                    (BuildContext context, int index) =>
                        Item(text: data[index].toString()),
                    childCount: data.length,
                    onIsPermanent: (key) => key == "40")),
          ),
        ],
      ),
    );
  }
}

class Item extends StatefulWidget {
  const Item({Key? key, required this.text}) : super(key: key);
  final String text;

  @override
  _ItemState createState() => _ItemState();
}

class _ItemState extends State<Item> {
  List<String> testItemKeys = ["40", "50"];

  /// This is orig text
  late String origText;
  @override
  void initState() {
    origText = widget.text;
    // 40 is permanent item, 50 is not, just test both
    if (testItemKeys.contains(widget.text)) {
      print("-------------item init: ${widget.text}");
    }
    super.initState();
  }

  @override
  void didUpdateWidget(covariant Item oldWidget) {
    var newItemIsInTestScope = false;
    var itemIsInTestScope = false;
    if (testItemKeys.contains(widget.text)) {
      newItemIsInTestScope = true;
    }
    if (testItemKeys.contains(origText)) {
      itemIsInTestScope = true;
    }

    if (newItemIsInTestScope || itemIsInTestScope) {
      if (newItemIsInTestScope) {
        print(
            "-------------didUpdateWidget newItemIsInTestScope: ${widget.text}");
      }
      if (itemIsInTestScope) {
        print("-------------didUpdateWidget itemIsInTestScope: $origText");
      }
      print("--------- end >");
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListTile(title: Text("List Item ${widget.text}")),
    );
  }
}
