// Aplicación principal FlexiDrive
// Widget raíz que maneja el tema y la navegación
import 'package:flutter/material.dart';
import 'theme_provider.dart';
import 'app_themes.dart';
import 'package:flexidrive/features/splash/presentation/pages/splash/splash_page.dart';

// Widget principal de la aplicación
// Gestiona el estado del tema y proporciona acceso global al estado
class FlexiDriveApp extends StatefulWidget {
  // Constructor principal de la app
  const FlexiDriveApp({super.key});

  // Método estático para acceder al estado de la app desde cualquier widget
  static FlexiDriveAppState? of(BuildContext context) {
    final state = context.findAncestorStateOfType<FlexiDriveAppState>();
    return state;
  }

  /// Gestiona crear estado dentro de esta parte del flujo.
  @override
  State<FlexiDriveApp> createState() => FlexiDriveAppState();
}

// Estado de la aplicación principal
// Maneja el proveedor de temas y construye la UI
class FlexiDriveAppState extends State<FlexiDriveApp> {
  // Proveedor que gestiona el modo claro/oscuro
  final ThemeProvider _themeProvider = ThemeProvider();

  /// Inicializa el proceso de inicialización del estado antes de su uso.
  @override
  void initState() {
    super.initState();
    _themeProvider.addListener(_onThemeChanged);
  }

  /// Gestiona dispose dentro de esta parte del flujo.
  @override
  void dispose() {
    _themeProvider.removeListener(_onThemeChanged);
    super.dispose();
  }

  /// Gestiona on tema changed dentro de esta parte del flujo.
  void _onThemeChanged() {
    setState(() {});
  }

  /// Alternar tema esta parte del flujo de trabajo.
  void toggleTheme() {
    _themeProvider.toggleTheme();
  }

  /// Actualiza el estado relacionado con definir dark modo.
  void setDarkMode(bool isDark) {
    _themeProvider.setDarkMode(isDark);
  }

  /// Construye y devuelve el widget correspondiente a esta sección.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlexiDrive',
      debugShowCheckedModeBanner: false,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: _themeProvider.themeMode,
      home: const SplashPage(),
    );
  }
}
