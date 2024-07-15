import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dhikr/Controller/Notification.dart';
import 'package:permission_handler/permission_handler.dart';

class TimerProvider with ChangeNotifier {
  Timer? _timer;
  bool _isTimerRunning = false;
  int _selectedNumber = 10;
  late SharedPreferences _prefs;
  double _angleOffset = 0.0;
  bool _isEnglishSelected = true; // Track selected Translation
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  TimerProvider() {
    _initPreferences();
    // _initNotifications();
  }

  bool get isTimerRunning => _isTimerRunning;
  int get selectedNumber => _selectedNumber;
  double get angleOffset => _angleOffset;
  bool get isEnglishSelected => _isEnglishSelected;

  Future<void> _initPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _loadSelectedNumber();
    _loadTranslationPreference();
  }

  void _loadSelectedNumber() {
    int? selectedNumber = _prefs.getInt('selectedNumber');
    if (selectedNumber != null) {
      _selectedNumber = selectedNumber;
      notifyListeners();
    }
  }

  void _loadTranslationPreference() {
    bool? isEnglishSelected = _prefs.getBool('isEnglishSelected');
    if (isEnglishSelected != null) {
      _isEnglishSelected = isEnglishSelected;
      notifyListeners();
    }
  }

  Future<void> _saveSelectedNumber(int number) async {
    await _prefs.setInt('selectedNumber', number);
  }

  Future<void> _saveTranslationPreference(bool isEnglishSelected) async {
    await _prefs.setBool('isEnglishSelected', isEnglishSelected);
  }

  Future<void> _saveTimerState(bool isRunning) async {
    await _prefs.setBool('isTimerRunning', isRunning);
  }

  void startTimer(BuildContext context) async {
    var notificationStatus = await Permission.notification.status;

    if (notificationStatus.isDenied) {
      notificationStatus = await Permission.notification.request();

      if (notificationStatus.isGranted) {
        _startTimer(context);
      }
    } else if (notificationStatus.isGranted) {
      _startTimer(context);
    } else {
      print('Notification permission status: $notificationStatus');
    }
  }

  void _startTimer(BuildContext context) {
    if (_timer == null || !_timer!.isActive) {
      _timer = Timer.periodic(Duration(minutes: _selectedNumber), (timer) {
        showNotification(context, _isEnglishSelected);
        // addToStartup();
      });
      _isTimerRunning = true;
      _saveTimerState(true);
      notifyListeners();
    }
  }

  void pauseTimer() {
    _timer?.cancel();
    _isTimerRunning = false;
    // removeFromStartup();
    notifyListeners();
  }

  void toggleTimer(BuildContext context) {
    if (_isTimerRunning) {
      pauseTimer();
    } else {
      startTimer(context);
    }
  }

  void selectNumber(int number) {
    pauseTimer();
    _selectedNumber = number;
    _angleOffset = 0.0; // Reset angle offset
    _saveSelectedNumber(number);
    notifyListeners();
  }

  void updateAngle(double angle) {
    _angleOffset += angle;
    notifyListeners();
  }

  void setTranslation(bool isEnglish) {
    _isEnglishSelected = isEnglish;
    _saveTranslationPreference(isEnglish); // Save the Translation preference
    notifyListeners();
  }
}
