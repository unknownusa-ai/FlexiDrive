import 'package:flutter/material.dart';
import 'theme_provider.dart';
import 'app_themes.dart';
import '../../presentation/pages/splash/splash_page.dart';

class FlexiDriveApp extends StatefulWidget {
  const FlexiDriveApp({super.key});

  static FlexiDriveAppState? of(BuildContext context) {
    final state = context.findAncestorStateOfType<FlexiDriveAppState>();
    return state;
  }

  @override
  State<FlexiDriveApp> createState() => FlexiDriveAppState();
}

class FlexiDriveAppState extends State<FlexiDriveApp> {
  final ThemeProvider _themeProvider = ThemeProvider();

  @override
  void initState() {
    super.initState();
    _themeProvider.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    _themeProvider.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  void toggleTheme() {
    _themeProvider.toggleTheme();
  }

  void setDarkMode(bool isDark) {
    _themeProvider.setDarkMode(isDark);
  }

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
