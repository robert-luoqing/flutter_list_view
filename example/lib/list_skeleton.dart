import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ListSkeleton extends StatefulWidget {
  const ListSkeleton(
      {Key? key,
      this.line = 1,
      this.hasIcon = true,
      this.iconWidth = 30,
      this.iconHeight = 30,
      this.itemHeight = 15.0,
      this.itemsRightPadding = const [15.0, 100.0],
      this.itemOffset = 2.0,
      this.lineOffset = 10.0})
      : super(key: key);

  final int line;
  final bool hasIcon;
  final double iconWidth;
  final double iconHeight;
  final double itemHeight;
  final List<double> itemsRightPadding;
  final double itemOffset;
  final double lineOffset;

  @override
  State<ListSkeleton> createState() => _ListSkeletonState();
}

class _ListSkeletonState extends State<ListSkeleton> {
  @override
  Widget build(BuildContext context) {
    var lineWidgets = <Widget>[];
    for (var i = 0; i < widget.line; i++) {
      var items = <Widget>[];
      for (var subItemIndex = 0;
          subItemIndex < widget.itemsRightPadding.length;
          subItemIndex++) {
        var rightPadding = widget.itemsRightPadding[subItemIndex];
        var top = widget.itemOffset / 2;
        if (subItemIndex == 0) top = 0.0;
        var bottom = widget.itemOffset / 2;
        if (subItemIndex == widget.itemsRightPadding.length - 1) bottom = 0.0;
        Widget item = Padding(
          padding:
              EdgeInsets.only(right: rightPadding, top: top, bottom: bottom),
          child: SizedBox(
            height: widget.itemHeight,
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.grey, borderRadius: BorderRadius.circular(0)),
            ),
          ),
        );
        items.add(item);
      }

      var lineWidget = Padding(
          padding: EdgeInsets.symmetric(vertical: widget.lineOffset / 2),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              widget.hasIcon
                  ? Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: SizedBox(
                        width: widget.iconWidth,
                        height: widget.iconHeight,
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(0)),
                        ),
                      ),
                    )
                  : Container(),
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.only(right: 15.0, left: 15.0),
                child: Column(
                  children: items,
                ),
              ))
            ],
          ));
      lineWidgets.add(lineWidget);
    }
    return Shimmer.fromColors(
      baseColor: Colors.yellow,
      highlightColor: Colors.grey,
      child: Stack(
        children: [
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Column(
                children: lineWidgets,
              ))
        ],
      ),
    );
  }
}
