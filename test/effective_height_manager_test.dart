import 'package:flutter_list_view/src/effective_height_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('test HeightListWith1', () {
    var heightList = HeightList();
    heightList.addHeight(3, 10);

    expect(heightList.indexList.toString(), "[3]");
  });

  test('test HeightListWith2', () {
    var heightList = HeightList();
    heightList.addHeight(3, 10);
    heightList.addHeight(1, 10);
    expect(heightList.indexList.toString(), "[1, 3]");
  });

  test('test HeightList', () {
    var heightList = HeightList();
    heightList.addHeight(3, 10);
    heightList.addHeight(2, 10);
    heightList.addHeight(7, 10);
    heightList.addHeight(4, 10);
    heightList.addHeight(30, 10);
    expect(heightList.indexList.toString(), "[2, 3, 4, 7, 30]");
  });

  test('test HeightList2', () {
    var heightList = HeightList();
    heightList.addHeight(3, 10);
    heightList.addHeight(10, 10);
    heightList.addHeight(7, 10);
    heightList.addHeight(4, 10);
    heightList.addHeight(30, 10);
    expect(heightList.indexList.toString(), "[3, 4, 7, 10, 30]");
  });

  test('test HeightList3', () {
    var heightList = HeightList();
    heightList.addHeight(3, 10);
    heightList.addHeight(10, 10);
    heightList.addHeight(7, 10);
    heightList.addHeight(4, 10);
    heightList.addHeight(30, 10);
    heightList.addHeight(4, 10);
    expect(heightList.indexList.toString(), "[3, 4, 7, 10, 30]");
  });
}
