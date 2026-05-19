// Proveedor de temas para la aplicación
// Maneja el cambio entre modo claro y oscuro
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Proveedor que gestiona el tema de la aplicación
// Notifica a los widgets cuando cambia el modo de tema
class ThemeProvider extends ChangeNotifier {
  static const _themePrefKey = 'ui_theme_is_dark';

  // null => seguir tema del sistema
  bool? _isDarkMode;

  // Obtiene el estado actual del modo oscuro
  bool get isDarkMode => _isDarkMode ?? false;

  // Obtiene el modo de tema para MaterialApp
  ThemeMode get themeMode {
    if (_isDarkMode == null) return ThemeMode.system;
    return _isDarkMode! ? ThemeMode.dark : ThemeMode.light;
  }

  ThemeProvider() {
    _loadThemePreference();
  }

  // Cambia entre modo claro y oscuro
  void toggleTheme() {
    _isDarkMode = !(_isDarkMode ?? false);
    _saveThemePreference();
    notifyListeners();
  }

  // Establece explícitamente el modo oscuro
  void setDarkMode(bool value) {
    if (_isDarkMode != null && _isDarkMode == value) return;
    _isDarkMode = value;
    _saveThemePreference();
    notifyListeners();
  }

  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.containsKey(_themePrefKey)
          ? prefs.getBool(_themePrefKey)
          : null;
      notifyListeners();
    } catch (_) {
      // Si falla la lectura, mantenemos el valor por defecto.
    }
  }

  Future<void> _saveThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = _isDarkMode;
      if (isDark == null) {
        await prefs.remove(_themePrefKey);
      } else {
        await prefs.setBool(_themePrefKey, isDark);
      }
    } catch (_) {
      // No bloquea la UI si falla persistir la preferencia.
    }
  }
}
