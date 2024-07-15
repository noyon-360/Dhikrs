import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:dhikr/Controller/NameClass.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomAddProvider with ChangeNotifier {
  List<NameEntry> _customNames = [];
  Set<String> _selectedNames = {};

  List<NameEntry> get customNames => _customNames;
  Set<String> get selectedNames => _selectedNames;

  CustomAddProvider() {
    loadNames();
  }

  void addName(NameEntry entry) {
    _customNames.add(entry);
    saveNames();
    notifyListeners();
  }

  void removeName(NameEntry entry) {
    _customNames.remove(entry);
    saveNames();
    notifyListeners();
  }

  void updateName(NameEntry entry, String newName, String newMeaning) {
    int index = _customNames.indexOf(entry);
    if (index != -1) {
      _customNames[index].name = newName;
      _customNames[index].meaning = newMeaning;
      saveNames();
      notifyListeners();
    }
  }

  void saveNames() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> encodedNames =
        _customNames.map((name) => jsonEncode(name.toMap())).toList();
    prefs.setStringList('customNames', encodedNames);
    saveSelectedNames();
  }

  void loadNames() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? encodedNames = prefs.getStringList('customNames');
    if (encodedNames != null) {
      _customNames = encodedNames
          .map((encodedName) => NameEntry.fromMap(jsonDecode(encodedName)))
          .toList();
    }
    loadSelectedNames();
    notifyListeners();
  }

  void toggleSelection(NameEntry entry, bool isSelected) {
    int index = _customNames.indexOf(entry);
    if (index != -1) {
      _customNames[index].isSelected = isSelected;
      if (isSelected) {
        _selectedNames.add(entry.name);
      } else {
        _selectedNames.remove(entry.name);
      }
      saveSelectedNames();
      notifyListeners();
    }
  }

  Future<void> saveSelectedNames() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('selectedNames', _selectedNames.toList());
  }

  Future<void> loadSelectedNames() async {
    final prefs = await SharedPreferences.getInstance();
    final selectedNames = prefs.getStringList('selectedNames') ?? [];
    _selectedNames = selectedNames.toSet();
    for (var entry in _customNames) {
      entry.isSelected = _selectedNames.contains(entry.name);
    }
    notifyListeners();
  }

  List<NameEntry> getCustomSelectedNames() {
    return _customNames.where((name) => name.isSelected).toList();
  }
}
