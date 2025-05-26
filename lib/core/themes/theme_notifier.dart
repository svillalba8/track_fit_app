import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_themes.dart';
import 'logo_type.dart';

class ThemeNotifier extends ChangeNotifier {
  static const _logoKey = 'selected_logo';

  LogoType _currentLogo;
  ThemeData _currentTheme;

  ThemeNotifier(this._currentLogo)
    : _currentTheme = AppThemes.themeForLogo(_currentLogo);

  LogoType get currentLogo => _currentLogo;
  ThemeData get themeData => _currentTheme;

  /// Carga el logo guardado desde shared_preferences
  static Future<ThemeNotifier> create() async {
    final prefs = await SharedPreferences.getInstance();
    final logoString = prefs.getString(_logoKey);
    final logo = LogoType.values.firstWhere(
      (e) => e.name == logoString,
      orElse: () => LogoType.rosaNegro,
    );
    return ThemeNotifier(logo);
  }

  void setLogo(LogoType logo) async {
    if (logo != _currentLogo) {
      _currentLogo = logo;
      _currentTheme = AppThemes.themeForLogo(logo);
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_logoKey, logo.name);
    }
  }
}
