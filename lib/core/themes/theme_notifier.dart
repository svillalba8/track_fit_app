import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_themes.dart';
import 'logo_type.dart';

/// Notificador para el tema de la app basado en el logo seleccionado.
/// - Lee y guarda selección en SharedPreferences
/// - Actualiza ThemeData y notifica cambios
class ThemeNotifier extends ChangeNotifier {
  // Clave para guardar la selección de logo en prefs
  static const _logoKey = 'selected_logo';

  // Logo actualmente activo
  LogoType _currentLogo;
  // ThemeData correspondiente al logo activo
  ThemeData _currentTheme;

  /// Constructor privado: recibe logo inicial y construye el tema
  ThemeNotifier(this._currentLogo)
    : _currentTheme = AppThemes.themeForLogo(_currentLogo);

  // Getter para el logo actual
  LogoType get currentLogo => _currentLogo;
  // Getter para el ThemeData actual
  ThemeData get themeData => _currentTheme;

  /// Crea una instancia leyendo la última selección de logo de SharedPreferences
  static Future<ThemeNotifier> create() async {
    final prefs = await SharedPreferences.getInstance();
    final logoString = prefs.getString(_logoKey);
    // Convierte el string guardado a LogoType, o usa rosaNegro por defecto
    final logo = LogoType.values.firstWhere(
      (e) => e.name == logoString,
      orElse: () => LogoType.rosaNegro,
    );
    return ThemeNotifier(logo);
  }

  /// Cambia el logo (y por tanto el tema), notifica y persiste en prefs
  void setLogo(LogoType logo) async {
    if (logo != _currentLogo) {
      _currentLogo = logo;
      // Actualiza el ThemeData según el nuevo logo
      _currentTheme = AppThemes.themeForLogo(logo);
      notifyListeners(); // Notifica a los widgets que usen este notifier

      // Guarda la nueva selección en SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_logoKey, logo.name);
    }
  }
}
