// Proveedor de temas para la aplicación
// Maneja el cambio entre modo claro y oscuro
import 'package:flutter/material.dart';

// Proveedor que gestiona el tema de la aplicación
// Notifica a los widgets cuando cambia el modo de tema
class ThemeProvider extends ChangeNotifier {
  // Estado interno del modo oscuro
  bool _isDarkMode = false;

  // Obtiene el estado actual del modo oscuro
  bool get isDarkMode => _isDarkMode;

  // Obtiene el modo de tema para MaterialApp
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  // Cambia entre modo claro y oscuro
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  // Establece explícitamente el modo oscuro
  void setDarkMode(bool value) {
    if (_isDarkMode == value) return;
    _isDarkMode = value;
    notifyListeners();
  }
}
