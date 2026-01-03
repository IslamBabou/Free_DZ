import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    loadThemeFromPrefs();
  }

  Future<void> loadThemeFromPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  final themeStr = prefs.getString('themeMode') ?? 'system';

  switch (themeStr) {
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

  void setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    prefs.setString('themeMode', mode.name); // saves 'light', 'dark', or 'system'
  }
}
