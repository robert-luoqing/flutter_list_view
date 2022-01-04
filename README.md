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
            (BuildContext context, int index) {
          return Container(
            alignment: Alignment.centerLeft,
            // color: Colors.lightBlue[100 * (index % 9)],
            color: Colors.blue,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('List Item ${data[index]}'),
            ),
          );
        },
        childCount: data.length,
        onItemKey: (index) => data[index].toString(),
        keepPosition: keepPosition,
        keepPositionOffset: 80,
        firstItemAlign: firstItemAlign)),
  ],
),
```
### Jump to index
```dart
/// Declare
FlutterListViewController flutterListViewController = FlutterListViewController();
...
flutterListViewController.jumpToIndex(
                          100,
                          offset: 100,
                          offsetBasedOnBottom: true);
```
Or
```dart
flutterListViewController.jumpToIndex(100);
```                          