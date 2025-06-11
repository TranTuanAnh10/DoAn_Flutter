import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode? _mode;
  ThemeMode get mode => _mode == null ? ThemeMode.light : _mode as ThemeMode;
  ThemeProvider() {
    _readMode();
  }

  Future<void> changeMode() async {
    _mode = _mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    final pref = await SharedPreferences.getInstance();
    if (_mode == ThemeMode.light) {
      pref.setString('themeMode', 'light');
    }
    if (_mode == ThemeMode.dark) {
      pref.setString('themeMode', 'dark');
    }
  }

  Future<void> _readMode() async {
    final pref = await SharedPreferences.getInstance();
    var themeMode = pref.get('themeMode').toString();
    debugPrint(themeMode);
    if (themeMode.toString() == 'light') {
      _mode = ThemeMode.light;
    }
    if (themeMode.toString() == 'dark') {
      _mode = ThemeMode.dark;
    }
  }
}
