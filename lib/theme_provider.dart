import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('theme_mode') ?? 0;

    if (themeIndex == 1) {
      _themeMode = ThemeMode.light;
    } else if (themeIndex == 2) {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    int themeIndex = 0;
    if (mode == ThemeMode.light) {
      themeIndex = 1;
    } else if (mode == ThemeMode.dark) {
      themeIndex = 2;
    }
    await prefs.setInt('theme_mode', themeIndex);
    notifyListeners();
  }
}
