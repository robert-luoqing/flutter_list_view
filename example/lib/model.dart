class CountryModel {
  CountryModel(
      {required this.name, required this.countryCode, required this.phoneCode});
  String name;
  String countryCode;
  String phoneCode;
}

typedef SectionViewOnFetchAlphabet<T> = String Function(T header);

class AlphabetHeader<T> {
  AlphabetHeader({required this.alphabet, required this.items});
  String alphabet;
  List<T> items;
}
