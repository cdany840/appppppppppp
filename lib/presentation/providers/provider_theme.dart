import 'package:appointment_app/infrastructure/shared_preferences.dart';
import 'package:flutter/material.dart';

class ProviderTheme extends ChangeNotifier {
  int _colorValue = 2;

  int get colorValue => _colorValue;

  set colorValue(int value) {
    _colorValue = value;
    Preferences.prefsThemeColor.setInt('color', _colorValue);
    notifyListeners();
  }
}

class ProviderFont extends ChangeNotifier {
  String _fontValue = 'Lato';

  String get fontValue => _fontValue;

  set fontValue(String value) {
    _fontValue = value;
    Preferences.prefsThemeFont.setString('font', _fontValue);
    notifyListeners();
  }
}