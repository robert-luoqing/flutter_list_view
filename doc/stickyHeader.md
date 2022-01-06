# Sticky header

Sticky header releted below properties

- onItemSticky 
If the property is null, sticky header will disable in the package  
The property is a function callback, If you want to the item to sticky, return true, else return false 

For example:  
If you want item 2 and item 10 sticky to header. you should write like below
```dart
FlutterListView(
    delegate: FlutterListViewDelegate(
      (BuildContext context, int index) {
        var data = _countries[index];
        return _renderItem(data as CountryModel);
      },
      childCount: _countries.length,
      onItemSticky: (index) {
        if(index == 2 || index == 10) {
          return true;
        }
        return false;
      } 
    ))
```
