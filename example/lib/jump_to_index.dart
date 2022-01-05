import 'package:flutter_list_view/flutter_list_view.dart';
import 'package:flutter/material.dart';

class JumpToIndexPage extends StatefulWidget {
  const JumpToIndexPage({Key? key}) : super(key: key);

  @override
  State<JumpToIndexPage> createState() => _JumpToIndexPageState();
}

class _JumpToIndexPageState extends State<JumpToIndexPage> {
  FlutterListViewController controller = FlutterListViewController();
  TextEditingController textController = TextEditingController(text: "50");

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
    textController.dispose();
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
          Wrap(spacing: 20, children: [
            TextField(controller: textController),
            ElevatedButton(
                onPressed: () {
                  controller.sliverController
                      .jumpToIndex(int.parse(textController.text));
                },
                child: const Text("Jump")),
            ElevatedButton(
                onPressed: () {
                  controller.sliverController.animateToIndex(
                      int.parse(textController.text),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.ease);
                },
                child: const Text("Animite")),
          ]),
          Expanded(
            child: FlutterListView(
                controller: controller,
                delegate: FlutterListViewDelegate(
                  (BuildContext context, int index) => Container(
                    color: Colors.white,
                    child: ListTile(title: Text('List Item ${data[index]}')),
                  ),
                  childCount: data.length,
                )),
          ),
        ],
      ),
    );
  }
}
