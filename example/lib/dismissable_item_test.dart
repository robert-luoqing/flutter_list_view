import 'package:flutter/material.dart';
import 'package:flutter_list_view/flutter_list_view.dart';

class DismissibleItemTest extends StatefulWidget {
  const DismissibleItemTest({Key? key}) : super(key: key);

  @override
  State<DismissibleItemTest> createState() => _DismissibleItemTestState();
}

class _DismissibleItemTestState extends State<DismissibleItemTest> {
  List<int> items = List<int>.generate(100, (int index) => index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FlutterListView(
            delegate: FlutterListViewDelegate(
      (BuildContext context, int index) {
        return Dismissible(
          background: Container(
            color: Colors.green,
          ),
          key: ValueKey<int>(items[index]),
          onDismissed: (DismissDirection direction) {
            setState(() {
              items.removeAt(index);
            });
          },
          child: ListTile(
            title: Text(
              'Item ${items[index]}',
            ),
          ),
        );

        // return ListTile(
        //   title: Text(
        //     'Item ${items[index]}',
        //   ),
        // );
      },
      childCount: items.length,
    )));
  }
}
