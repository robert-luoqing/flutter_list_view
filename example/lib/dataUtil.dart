import 'dart:convert';

import 'package:flutter/services.dart';
import 'model.dart';

Future<List<CountryModel>> loadCountriesFromAsset() async {
  var value = await rootBundle.loadString('assets/countryCode.json');
  List<dynamic> _jsonData = json.decode(value);
  var result = <CountryModel>[];
  for (var item in _jsonData) {
    result.add(CountryModel(
        name: item["countryName"].toString(),
        countryCode: item["countryCode"].toString(),
        phoneCode: item["phoneCode"].toString()));
  }
  result.sort((a, b) => a.name.compareTo(b.name));
  return result;
}

List<AlphabetHeader<T>> convertListToAlphaHeader<T>(
    Iterable<T> data, SectionViewOnFetchAlphabet<T> onAlphabet) {
  List<AlphabetHeader<T>> result = [];
  Map<String, List<T>> map = {};
  for (var item in data) {
    var alphabet = onAlphabet(item);
    if (!map.containsKey(alphabet)) {
      var header = AlphabetHeader<T>(alphabet: alphabet, items: []);
      result.add(header);
      map[alphabet] = header.items;
    }
    map[alphabet]!.add(item);
  }

  return result;
}

List<dynamic> convertHierarchyToList<T>(List<AlphabetHeader<T>> list) {
  var result = <dynamic>[];
  for (var item in list) {
    result.add(item);
    for (var subItem in item.items) {
      result.add(subItem);
    }
  }
  return result;
}
