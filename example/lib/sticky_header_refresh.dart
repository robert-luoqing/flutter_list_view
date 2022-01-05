import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_list_view/flutter_list_view.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'dataUtil.dart';
import 'model.dart';

class StickyHeaderWithRefresh extends StatefulWidget {
  const StickyHeaderWithRefresh({Key? key}) : super(key: key);

  @override
  _StickyHeaderWithRefreshState createState() =>
      _StickyHeaderWithRefreshState();
}

class _StickyHeaderWithRefreshState extends State<StickyHeaderWithRefresh> {
  FlutterListViewController controller = FlutterListViewController();
  final _refreshController = RefreshController(initialRefresh: false);
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

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) setState(() {});
    _refreshController.loadComplete();
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
    return Container(
      color: const Color(0xFFF3F4F5),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Text(
          text,
          style: const TextStyle(fontSize: 18, color: Color(0xFF767676)),
        ),
      ),
    );
  }

  Widget _renderItem(CountryModel itemData) {
    return Padding(
        padding: const EdgeInsets.only(right: 12.0),
        child: ListTile(
            title: Text(itemData.name), trailing: Text(itemData.phoneCode)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Stick Header")),
        body: SmartRefresher(
          enablePullDown: true,
          enablePullUp: true,
          header: const WaterDropHeader(),
          footer: CustomFooter(
            builder: (context, mode) {
              Widget body;
              if (mode == LoadStatus.idle) {
                body = const Text("pull up load");
              } else if (mode == LoadStatus.loading) {
                body = const CupertinoActivityIndicator();
              } else if (mode == LoadStatus.failed) {
                body = const Text("Load Failed!Click retry!");
              } else if (mode == LoadStatus.canLoading) {
                body = const Text("release to load more");
              } else {
                body = const Text("No more Data");
              }
              return SizedBox(
                height: 55.0,
                child: Center(child: body),
              );
            },
          ),
          controller: _refreshController,
          onRefresh: _onRefresh,
          onLoading: _onLoading,
          child: FlutterListView(
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
              ),
              controller: controller),
        ));
  }
}
