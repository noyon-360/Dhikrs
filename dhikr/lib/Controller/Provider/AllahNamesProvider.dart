import 'package:flutter/material.dart';
import 'package:dhikr/Controller/NameClass.dart';
// import 'package:dhikr/Controller/AllahName.dart';
import 'package:dhikr/ListOfAllName/ListOfAllNameInBangla.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AllahNamesProvider with ChangeNotifier {
  final List<AllahName> _names;
  late List<AllahName> _filteredNames;
  late SharedPreferences _prefs;
  final List<AllahName> _namesBangla = allahNamesBangla;

  List<AllahName> get filteredNames => _filteredNames;

  AllahNamesProvider(this._names) {
    _filteredNames = List<AllahName>.from(_names); // Initialize in constructor
    _initSharedPreferences();
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _loadSelectedNames();
  }

  void _loadSelectedNames() {
    for (var name in _names) {
      name.isSelected = _prefs.getBool(name.name) ?? false;
    }
    notifyListeners();
  }

  void filterNames(String query) {
    if (query.isEmpty) {
      _filteredNames = _names;
    } else {
      _filteredNames = _names.where((name) {
        final nameLower = name.name.toLowerCase();
        final meaningLower = name.meaning.toLowerCase();
        final queryLower = query.toLowerCase();

        final banglaName =
            _namesBangla.firstWhere((element) => element.name == name.name);
        final banglaNameLower = banglaName.name.toLowerCase();
        final banglaMeaningLower = banglaName.meaning.toLowerCase();

        return nameLower.contains(queryLower) ||
            meaningLower.contains(queryLower) ||
            banglaNameLower.contains(queryLower) ||
            banglaMeaningLower.contains(queryLower);
      }).toList();
    }
    notifyListeners();
  }

  Future<void> saveSelectedName(AllahName name) async {
    await _prefs.setBool(name.name, true);
    notifyListeners();
  }

  Future<void> removeSelectedName(AllahName name) async {
    await _prefs.remove(name.name);
    notifyListeners();
  }

  void toggleSelection(AllahName name, bool isSelected) {
    final index = _names.indexOf(name);
    if (index != -1) {
      _names[index].isSelected = isSelected;
      notifyListeners();
    }
  }

  List<AllahName> getFilteredNames() {
    return List<AllahName>.from(_filteredNames);
  }

  List<AllahName> getSelectedNames() {
    return _names.where((name) => name.isSelected).toList();
  }

  void selectAllNames() {
    for (var name in _names) {
      name.isSelected = true;
    }
    notifyListeners();
  }

  void deselectAllNames() {
    for (var name in _names) {
      name.isSelected = false;
    }
    notifyListeners();
  }

  int get selectedNamesCount {
    return filteredNames.where((name) => name.isSelected).length;
  }
}
