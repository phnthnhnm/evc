import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme';
  static const String _showScoreKey = 'showScoreOnCard';
  ThemeMode _themeMode = ThemeMode.system;
  bool _showScoreOnCard = true;

  ThemeProvider() {
    loadThemeMode();
    loadShowScoreOnCard();
  }

  ThemeMode get themeMode => _themeMode;
  bool get showScoreOnCard => _showScoreOnCard;

  void setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode.toString().split('.').last);
  }

  void setShowScoreOnCard(bool value) async {
    _showScoreOnCard = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showScoreKey, value);
  }

  Future<void> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString(_themeKey);
    if (themeString != null) {
      switch (themeString) {
        case 'light':
          _themeMode = ThemeMode.light;
          break;
        case 'dark':
          _themeMode = ThemeMode.dark;
          break;
        default:
          _themeMode = ThemeMode.system;
      }
      notifyListeners();
    }
  }

  Future<void> loadShowScoreOnCard() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(_showScoreKey)) {
      _showScoreOnCard = prefs.getBool(_showScoreKey) ?? true;
      notifyListeners();
    }
  }
}
