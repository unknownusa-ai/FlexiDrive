// Proveedor de temas para la aplicación.
//
// Este componente implementa un patrón tipo Provider con ChangeNotifier:
// - expone el estado global de tema,
// - notifica cambios a los widgets suscritos,
// - y persiste la preferencia localmente con SharedPreferences.
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Proveedor que gestiona el tema de la aplicación.
// Notifica a la UI cuando cambia el modo de tema.
class ThemeProvider extends ChangeNotifier {
  // Key de persistencia local para la preferencia de tema.
  // true: dark, false: light, ausente: ThemeMode.system.
  static const _themePrefKey = 'ui_theme_is_dark';

  // null => seguir tema del sistema
  bool? _isDarkMode;

  // Obtiene el estado actual del modo oscuro para la UI.
  bool get isDarkMode => _isDarkMode ?? false;

  // Traduce el estado interno al ThemeMode de MaterialApp.
  ThemeMode get themeMode {
    if (_isDarkMode == null) return ThemeMode.system;
    return _isDarkMode! ? ThemeMode.dark : ThemeMode.light;
  }

  /// Crea una instancia y prepara el estado inicial de `ThemeProvider`.
  ThemeProvider() {
    _loadThemePreference();
  }

  // Cambia entre modo claro y oscuro y persiste el cambio.
  void toggleTheme() {
    _isDarkMode = !(_isDarkMode ?? false);
    _saveThemePreference();
    notifyListeners();
  }

  // Establece explícitamente el modo oscuro y persiste el cambio.
  void setDarkMode(bool value) {
    if (_isDarkMode != null && _isDarkMode == value) return;
    _isDarkMode = value;
    _saveThemePreference();
    notifyListeners();
  }

  /// Carga la preferencia de tema almacenada localmente.
  ///
  /// Si la key no existe, deja el estado en `null` para usar
  /// `ThemeMode.system`.
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

  /// Persiste la preferencia de tema en SharedPreferences.
  ///
  /// Cuando `_isDarkMode` es `null`, elimina la key para volver
  /// al comportamiento por sistema.
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
