import 'package:flutter/material.dart';

typedef FlutterListViewDelegateOnItemKey = String Function(int index);
typedef FlutterListViewDelegateOnItemSticky = bool Function(int index);
typedef FlutterListViewDelegateOnItemHeight = double Function(int index);

enum FirstItemAlign { start, end }

class FlutterListViewDelegate extends SliverChildDelegate {
  /// Creates a delegate that supplies children for slivers using the given
  /// builder callback.
  ///
  /// The [builder], [addAutomaticKeepAlives], [addRepaintBoundaries],
  /// [addSemanticIndexes], and [semanticIndexCallback] arguments must not be
  /// null.
  ///
  /// If the order in which [builder] returns children ever changes, consider
  /// providing a [findChildIndexCallback]. This allows the delegate to find the
  /// new index for a child that was previously located at a different index to
  /// attach the existing state to the [Widget] at its new location.
  const FlutterListViewDelegate(this.builder,
      {this.childCount,
      this.addAutomaticKeepAlives = true,
      this.addRepaintBoundaries = true,
      this.addSemanticIndexes = true,
      this.semanticIndexCallback = _kDefaultSemanticIndexCallback,
      this.semanticIndexOffset = 0,
      this.onItemKey,
      this.keepPosition = false,
      this.keepPositionOffset = 0,
      this.onItemSticky,
      this.stickyAtTailer = false,
      this.onItemHeight,
      this.preferItemHeight = 50,
      this.firstItemAlign = FirstItemAlign.start,
      this.initIndex = 0,
      this.forceToExecuteInitIndex,
      this.initOffset = 0.0,
      this.initOffsetBasedOnBottom = false,
      this.onIsPermanent,
      this.isSupressElementGenerate = false});

  /// When childCount from 0 to non-zore, the [initIndex] will effect,
  /// When initIndex changed, if child count is not 0, it also effect
  /// [initOffset] is scroll to index and the distance from top or bottom based
  /// on [initOffsetBasedOnBottom]
  /// If your [initIndex] didn't change. but data have changed, if you want force wiget to jump to initIndex,
  /// You can change [forceToExecuteInitIndex], widget will detct does the forceToExecuteInitIndex have be changed.
  /// Once it changed, It also enforce to execute jump to initIndex.
  final int initIndex;
  final int? forceToExecuteInitIndex;
  final double initOffset;
  final bool initOffsetBasedOnBottom;

  /// When item is not enough fill one viewport. Where is the items shoule align to
  /// For example: if reverse is false,
  /// When [firstItemAlign]=FirstItemAlign.start, the item should located on top.
  /// When [firstItemAlign]=FirstItemAlign.end, the item should located on bottom.
  final FirstItemAlign firstItemAlign;

  /// [onItemKey] will indicate the item key
  /// The key will used to ref the item's height
  /// If you enable keepPosition, the key will be used to identify inserted items
  /// which is before the current rendered key
  final FlutterListViewDelegateOnItemKey? onItemKey;

  /// Whem keepPosition is false, If some item insert to header, the render items will scroll down a distance
  /// which is equal the inserted items' height, When the property set to true, The current render item will
  /// keep same position. Notice: it the keepPosition set to true, [onItemKey] must not be null and each item's must
  /// unique.
  /// When [keepPosition] is true and scrolloffset>=keepPositionOffset, the keep position will enable
  final bool keepPosition;
  final double keepPositionOffset;

  /// Query the item is sticky to header.
  /// [stickyAtTailer] is mean sticky from bottom to top, in normal sticky item will show on top, but if it is true, it mean the sticky will show on bottom
  final FlutterListViewDelegateOnItemSticky? onItemSticky;
  final bool stickyAtTailer;

  /// If you know the item height, it is better provider the height
  /// It can provide better user expierence
  final FlutterListViewDelegateOnItemHeight? onItemHeight;

  /// If you didn't provide onItemHeight, the preferItemHeight will be apply to item which is not render.
  final double preferItemHeight;

  /// Called to build children for the sliver.
  ///
  /// Will be called only for indices greater than or equal to zero and less
  /// than [childCount] (if [childCount] is non-null).
  ///
  /// Should return null if asked to build a widget with a greater index than
  /// exists.
  ///
  /// The delegate wraps the children returned by this builder in
  /// [RepaintBoundary] widgets.
  final NullableIndexedWidgetBuilder builder;

  /// The total number of children this delegate can provide.
  ///
  /// If null, the number of children is determined by the least index for which
  /// [builder] returns null.
  final int? childCount;

  /// Whether to wrap each child in an [AutomaticKeepAlive].
  ///
  /// Typically, children in lazy list are wrapped in [AutomaticKeepAlive]
  /// widgets so that children can use [KeepAliveNotification]s to preserve
  /// their state when they would otherwise be garbage collected off-screen.
  ///
  /// This feature (and [addRepaintBoundaries]) must be disabled if the children
  /// are going to manually maintain their [KeepAlive] state. It may also be
  /// more efficient to disable this feature if it is known ahead of time that
  /// none of the children will ever try to keep themselves alive.
  ///
  /// Defaults to true.
  final bool addAutomaticKeepAlives;

  /// Whether to wrap each child in a [RepaintBoundary].
  ///
  /// Typically, children in a scrolling container are wrapped in repaint
  /// boundaries so that they do not need to be repainted as the list scrolls.
  /// If the children are easy to repaint (e.g., solid color blocks or a short
  /// snippet of text), it might be more efficient to not add a repaint boundary
  /// and simply repaint the children during scrolling.
  ///
  /// Defaults to true.
  final bool addRepaintBoundaries;

  /// Whether to wrap each child in an [IndexedSemantics].
  ///
  /// Typically, children in a scrolling container must be annotated with a
  /// semantic index in order to generate the correct accessibility
  /// announcements. This should only be set to false if the indexes have
  /// already been provided by an [IndexedSemantics] widget.
  ///
  /// Defaults to true.
  ///
  /// See also:
  ///
  ///  * [IndexedSemantics], for an explanation of how to manually
  ///    provide semantic indexes.
  final bool addSemanticIndexes;

  /// An initial offset to add to the semantic indexes generated by this widget.
  ///
  /// Defaults to zero.
  final int semanticIndexOffset;

  /// A [SemanticIndexCallback] which is used when [addSemanticIndexes] is true.
  ///
  /// Defaults to providing an index for each widget.
  final SemanticIndexCallback semanticIndexCallback;

  /// Query does the item is permanent item
  /// permanent item will not reused and release util list view disposed
  /// [keyOrIndex] is onItemKey provide, the param is key, else it is index
  final bool Function(String keyOrIndex)? onIsPermanent;

  /// [isSupressElementGenerate] is true, the element will not generated during scroll
  final bool isSupressElementGenerate;

  /// [syncCreatedItemIndexs] is used to create item when list view created
  /// indexs which need create
  /// The method will be invoke to create element when childCount from 0 to non-zero
  /// or childCount is non-zero when list view mounted
  /// or syncCreatedItemIndexs changed
  /// Notice, it will be trigger when syncCreatedItemKeyOrIndexs object mutated
  /// It will rememeber the keyOrIndex once created
  // final List<String>? syncCreatedItemIndexs;

  Widget _createErrorWidget(Object exception, StackTrace stackTrace) {
    final FlutterErrorDetails details = FlutterErrorDetails(
      exception: exception,
      stack: stackTrace,
      library: 'widgets library',
      context: ErrorDescription('building'),
    );
    FlutterError.reportError(details);
    return ErrorWidget.builder(details);
  }

  @override
  @pragma('vm:notify-debugger-on-exception')
  Widget? build(BuildContext context, int index) {
    if (index < 0 || (childCount != null && index >= childCount!)) return null;
    Widget? child;
    try {
      child = builder(context, index);
    } catch (exception, stackTrace) {
      child = _createErrorWidget(exception, stackTrace);
    }
    if (child == null) {
      return null;
    }
    final Key? key = child.key != null ? _SaltedValueKey(child.key!) : null;
    if (addRepaintBoundaries) child = RepaintBoundary(child: child);
    if (addSemanticIndexes) {
      final int? semanticIndex = semanticIndexCallback(child, index);
      if (semanticIndex != null) {
        child = IndexedSemantics(
            index: semanticIndex + semanticIndexOffset, child: child);
      }
    }
    if (addAutomaticKeepAlives) child = AutomaticKeepAlive(child: child);
    return KeyedSubtree(key: key, child: child);
  }

  @override
  int? get estimatedChildCount => childCount;

  @override
  bool shouldRebuild(covariant FlutterListViewDelegate oldDelegate) => true;
}

class _SaltedValueKey extends ValueKey<Key> {
  const _SaltedValueKey(Key key) : super(key);
}

int _kDefaultSemanticIndexCallback(Widget _, int localIndex) => localIndex;
