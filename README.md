## Flutter List View

I don't like official list view. There are some features don't provide and jumpTo performance is not good. I rewrite the list supported these features in [Features] sections

## Features

1. Support jump to index
   Jump to index is not support in listview. But it is useful function 
2. Support keep position
   If some data insert before other items, It will scroll down. Some chat software may want to keep the position not scroll down when new message coming.
3. Support show top in reverse mode if the data can't fill full viewport.
4. Performance
   When listview jump to somewhere, The items which layout before the position will always loaded. It is not realy lazy loading.

## Screen

## Example
```dart
CustomScrollView(
  reverse: reverse,
  slivers: [
    FlutterListView(
        controller: flutterListViewController,
          delegate: FlutterListViewDelegate(
            (BuildContext context, int index) => Container(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('List Item ${data[index]}'),
              ),
            ),
            childCount: data.length,
          )),
  ],
),
```
### Jump to index
```dart
flutterListViewController.jumpToIndex(100);
```
OR
```dart
/// Declare
FlutterListViewController flutterListViewController = FlutterListViewController();
...
flutterListViewController.jumpToIndex(
                          100,
                          offset: 100,
                          offsetBasedOnBottom: true);
```

### Keep Position
```dart
CustomScrollView(
  reverse: reverse,
  slivers: [
    FlutterListView(
        controller: flutterListViewController,
        delegate: FlutterListViewDelegate(
          (BuildContext context, int index) => Container(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('List Item ${data[index]}'),
            ),
          ),
          childCount: data.length,
          onItemKey: (index) => data[index].toString(),
          keepPosition: true,
          keepPositionOffset: 80)),
  ],
),
```