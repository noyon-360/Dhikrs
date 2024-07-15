import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dhikr/Controller/NameClass.dart';

class UserSaveDuaProvider with ChangeNotifier {
  List<NameEntry> _savedDuas = [];

  List<NameEntry> get savedDuas => _savedDuas;

  UserSaveDuaProvider() {
    // Load saved data when the provider is initialized
    loadSavedDuas();
  }

  void addDua(NameEntry dua) {
    if (!_savedDuas.contains(dua)) {
      _savedDuas.add(dua);
      saveSavedDuas(); // Save data whenever it's modified
      notifyListeners();
    }
  }

  void removeDua(NameEntry dua) {
    if (_savedDuas.contains(dua)) {
      _savedDuas.remove(dua);
      saveSavedDuas(); // Save data whenever it's modified
      notifyListeners();
    }
  }

  Future<void> saveSavedDuas() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> encodedDuas =
        _savedDuas.map((dua) => jsonEncode(dua.toMap())).toList();
    prefs.setStringList('savedDuas', encodedDuas);
  }

  Future<void> loadSavedDuas() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? encodedDuas = prefs.getStringList('savedDuas');
    if (encodedDuas != null) {
      _savedDuas = encodedDuas
          .map((encodedDua) => NameEntry.fromMap(jsonDecode(encodedDua)))
          .toList();
      notifyListeners();
    }
  }

  List<NameEntry> getSelectedSaved() {
    return List<NameEntry>.from(_savedDuas);
  }
}
