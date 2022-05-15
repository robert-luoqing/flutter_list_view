## 0.1.0
* Provide keep position feature
* provide show top in reverse mode
* Reuse list item element to save performance
## 0.1.1
* Provide jumpToIndex
## 1.0.0
* Provide anmiteToIndex
* Integrate pull_to_refresh

## 1.0.2
* Add initIndex,initOffset and initOffsetBasedOnBottom
* Add Element Positions Callback

## 1.0.3
* Correct the items did not response the gesture event

## 1.0.4
* Correct sticky header may not response the gesture event

## 1.0.5
* Fix the exception when change size of child

## 1.0.7
* Fix drag down item will be clip if the items can't fill full screen.

## 1.0.8
* When reuse exist element, the same key will be priority reused it. avoid update one item twice in very short time.

## 1.0.9
* Resolve performance issue when without onItemHeight and onItemKey and child count more than 1M

## 1.1.0
* Add permanent item which will not to be reused and keep in FlutterListView util FlutterListView disposed

## 1.1.1
* Provide option to determine whether or not generate items during scrolling to make scroll to index more smooth

## 1.1.2
* Fix bug: It cause exception when the user stop scroll manually while invoke animite to index

## 1.1.3
* Add FlutterListView.builder and FlutterListView.separated

## 1.1.4
* Add ensureVisible(index) functionality

## 1.1.5
* Fixed jump to index or init index will scroll to wrong position

## 1.1.6
* Fixed jump to index or init index will scroll to wrong position when initOffsetBasedOnBottom: true

## 1.1.7
* Fixed when remove all items and jump to index was set, onItemKey will get wrong.

## 1.1.8
* Fixed when remove some items, onItemKey will get wrong.

## 1.1.10
* Sticky header support reverse

## 1.1.11
* Fixed support PopupMenuButton

## 1.1.12
* Support stickyAtTailer in FlutterListView

## 1.1.15
* Fixed detach issue

## 1.1.17
* Fixed touch item is incorrect when items can't fill full screen and firstItemAlign is FirstItemAlign.end

## 1.1.18
* Rewrite keep position logic.

## TODO
* Add horizontal scroll support
* Add creating items when flutter list view created
* Add Flutter Key to reference items' element
* Add header is not override