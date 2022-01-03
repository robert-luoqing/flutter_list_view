Vertical marquee view

## Features

1. Support up and down direction scroll
2. Support multiple line marquee list

## Screen

![](screens/screen.gif)

## Usage

Firstly, you can construct data like

```dart
MarqueeVertical(
  itemCount: texts.length,
  lineHeight: 20,
  marqueeLine: 3,
  direction: MarqueeVerticalDirection.moveDown,
  itemBuilder: (index) {
    return Align(
        alignment: Alignment.centerLeft,
        child: Text(
          texts[index],
          overflow: TextOverflow.ellipsis,
        ));
  },
  scrollDuration: const Duration(milliseconds: 300),
  stopDuration: const Duration(seconds: 3),
),
```