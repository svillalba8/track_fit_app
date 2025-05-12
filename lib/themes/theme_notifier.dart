import 'package:flutter/material.dart';
import 'logo_type.dart';
import 'app_themes.dart';

class ThemeNotifier extends ChangeNotifier {
  LogoType _currentLogo;
  ThemeData _currentTheme;

  ThemeNotifier(this._currentLogo)
  : _currentTheme = AppThemes.themeForLogo(_currentLogo);

  LogoType get currentLogo => _currentLogo;
  ThemeData get themeData => _currentTheme;

  void setLogo(LogoType logo) {
    if (logo != _currentLogo) {
      _currentLogo = logo;
      _currentTheme = AppThemes.themeForLogo(logo);
      notifyListeners();
    }
  }
}
