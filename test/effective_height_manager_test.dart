import 'package:flutter_list_view/src/effective_height_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('test HeightListWith1', () {
    var heightList = HeightList();
    heightList.setHeight(3, 10);

    expect(heightList.indexList.toString(), "[3]");
  });

  test('test HeightListWith2', () {
    var heightList = HeightList();
    heightList.setHeight(3, 10);
    heightList.setHeight(1, 10);
    expect(heightList.indexList.toString(), "[1, 3]");
  });

  test('test HeightList', () {
    var heightList = HeightList();
    heightList.setHeight(3, 10);
    heightList.setHeight(2, 10);
    heightList.setHeight(7, 10);
    heightList.setHeight(4, 10);
    heightList.setHeight(30, 10);
    expect(heightList.indexList.toString(), "[2, 3, 4, 7, 30]");
  });

  test('test HeightList2', () {
    var heightList = HeightList();
    heightList.setHeight(3, 10);
    heightList.setHeight(10, 10);
    heightList.setHeight(7, 10);
    heightList.setHeight(4, 10);
    heightList.setHeight(30, 10);
    expect(heightList.indexList.toString(), "[3, 4, 7, 10, 30]");
  });

  test('test HeightList3', () {
    var heightList = HeightList();
    heightList.setHeight(3, 10);
    heightList.setHeight(10, 10);
    heightList.setHeight(7, 10);
    heightList.setHeight(4, 10);
    heightList.setHeight(30, 10);
    heightList.setHeight(4, 10);
    expect(heightList.indexList.toString(), "[3, 4, 7, 10, 30]");
  });

  test('test HeightList4', () {
    var heightList = HeightList();
    heightList.setHeight(6, 10);
    heightList.setHeight(7, 10);
    heightList.setHeight(5, 10);
    expect(heightList.indexList.toString(), "[5, 6, 7]");
  });
}
