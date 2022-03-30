import 'package:flutter/material.dart';
import 'package:flutter_list_view/flutter_list_view.dart';

import 'dataUtil.dart';
import 'model.dart';

class StickyHeader extends StatefulWidget {
  const StickyHeader({Key? key}) : super(key: key);

  @override
  _StickyHeaderState createState() => _StickyHeaderState();
}

class _StickyHeaderState extends State<StickyHeader> {
  FlutterListViewController controller = FlutterListViewController();
  List<dynamic> _countries = [];

  _loadCountry() async {
    var data = await loadCountriesFromAsset();
    var hierarchyData = convertListToAlphaHeader<CountryModel>(
        data, (item) => (item.name).substring(0, 1).toUpperCase());
    setState(() {
      _countries = convertHierarchyToList(hierarchyData);
    });
  }

  _stickyHeaderChanged() {
    print(
        "Sticky Header Change To: ${controller.sliverController.stickyIndex.value}");
  }

  _fetchStickHeader() async {
    await Future.delayed(const Duration(milliseconds: 100));
    print(
        "Sticky Header Change To: ${controller.sliverController.stickyIndex.value}");
  }

  @override
  void initState() {
    _loadCountry();
    controller.sliverController.stickyIndex.addListener(_stickyHeaderChanged);
    _fetchStickHeader();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget _renderHeader(String text) {
    return GestureDetector(
        onTap: () {
          print("header clicked $text");
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          color: const Color(0xFFF3F4F5),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Text(
              text,
              style: const TextStyle(fontSize: 18, color: Color(0xFF767676)),
            ),
          ),
        ));
  }

  Widget _renderItem(CountryModel itemData) {
    return GestureDetector(
      onTap: () {
        print("item clicked ${itemData.name}");
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: ListTile(
              title: Text(itemData.name), trailing: Text(itemData.phoneCode))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Stick Header")),
      body: FlutterListView(
          reverse: true,
          delegate: FlutterListViewDelegate(
            (BuildContext context, int index) {
              var data = _countries[index];
              if (data is AlphabetHeader) {
                return _renderHeader(data.alphabet);
              } else {
                return _renderItem(data as CountryModel);
              }
            },
            childCount: _countries.length,
            onItemSticky: (index) => _countries[index] is AlphabetHeader,
            stickyAtTailer: true,
          ),
          controller: controller),
    );
  }
}
