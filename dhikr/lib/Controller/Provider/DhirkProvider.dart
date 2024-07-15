import 'package:flutter/material.dart';
import 'package:dhikr/Controller/NameClass.dart';
import 'package:dhikr/ListOfAllName/Dhikrs.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DhikrProvider with ChangeNotifier {
  final List<Dhikr> _dhikrs;
  late List<Dhikr>
      _filteredDhikrs; // Make sure to mark it 'late' if using null-safety
  final List<Dhikr> _dhikrsBangla = mostCommonDhikrBangla;
  late SharedPreferences _prefs;

  List<Dhikr> get filteredDhikrs => _filteredDhikrs;

  DhikrProvider(this._dhikrs) {
    _filteredDhikrs =
        List<Dhikr>.from(_dhikrs); // Initialize _filteredDhikrs here
    _initSharedPreferences();
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _loadSelectedDhikrs();
  }

  void _loadSelectedDhikrs() {
    for (var dhikr in _dhikrs) {
      dhikr.isSelected = _prefs.getBool(dhikr.name) ?? false;
    }
    notifyListeners();
  }

  void filterDhikrs(String query) {
    if (query.isEmpty) {
      _filteredDhikrs = _dhikrs;
    } else {
      _filteredDhikrs = _dhikrs.where((dhikr) {
        final nameLower = dhikr.name.toLowerCase();
        final meaningLower = dhikr.meaning.toLowerCase();
        final queryLower = query.toLowerCase();

        final banglaDhikr =
            _dhikrsBangla.firstWhere((element) => element.name == dhikr.name);
        final banglaDhikrLower = banglaDhikr.name.toLowerCase();
        final banglaMeaningLower = banglaDhikr.meaning.toLowerCase();

        return nameLower.contains(queryLower) ||
            meaningLower.contains(queryLower) ||
            banglaDhikrLower.contains(queryLower) ||
            banglaMeaningLower.contains(queryLower);
      }).toList();
    }
    notifyListeners();
  }

  Future<void> saveSelectedDhikr(Dhikr dhikr) async {
    await _prefs.setBool(dhikr.name, true);
    notifyListeners();
  }

  Future<void> removeSelectedDhikr(Dhikr dhikr) async {
    await _prefs.remove(dhikr.name);
    notifyListeners();
  }

  void toggleDhikrSelection(Dhikr dhikr, bool isSelected) {
    final index = _dhikrs.indexOf(dhikr);
    if (index != -1) {
      _dhikrs[index].isSelected = isSelected;
      notifyListeners();
    }
  }

  List<Dhikr> getFilteredDhikrs() {
    return List<Dhikr>.from(_filteredDhikrs);
  }

  List<Dhikr> getSelectedDhikrs() {
    return _dhikrs.where((dhikr) => dhikr.isSelected).toList();
  }

  void selectAllDhikrs() {
    for (var name in _dhikrs) {
      name.isSelected = true;
    }
    notifyListeners();
  }

  void deselectAllDhikrs() {
    for (var name in _dhikrs) {
      name.isSelected = false;
    }
    notifyListeners();
  }

  int get selectedDhikrCount {
    return filteredDhikrs.where((name) => name.isSelected).length;
  }
}
