import 'package:flutter_list_view/flutter_list_view.dart';
import 'package:flutter/material.dart';

class InitJumpPage extends StatefulWidget {
  const InitJumpPage({Key? key}) : super(key: key);

  @override
  State<InitJumpPage> createState() => _InitJumpPageState();
}

class _InitJumpPageState extends State<InitJumpPage> {
  List<int> data = [];
  @override
  initState() {
    for (var i = 0; i < 1000; i++) {
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
        title: const Text("Jump to the index what you want"),
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterListView(
                delegate: FlutterListViewDelegate(
                    (BuildContext context, int index) => Container(
                          color: Colors.white,
                          child:
                              ListTile(title: Text('List Item ${data[index]}')),
                        ),
                    childCount: data.length,
                    initIndex: 50,
                    initOffset: 0,
                    initOffsetBasedOnBottom: false)),
          ),
        ],
      ),
    );
  }
}
