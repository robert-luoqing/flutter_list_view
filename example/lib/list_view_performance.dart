import 'package:flutter/material.dart';

class ListViewPerformance extends StatefulWidget {
  const ListViewPerformance({Key? key}) : super(key: key);

  @override
  _TestListViewPerformanceState createState() =>
      _TestListViewPerformanceState();
}

class _TestListViewPerformanceState extends State<ListViewPerformance> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Test Performance"),
        ),
        body: ListView.builder(
          itemBuilder: (context, index) {
            return ListTile(
              title: Text("List Item $index"),
            );
          },
          itemCount: 1000000,
        ));
  }
}
