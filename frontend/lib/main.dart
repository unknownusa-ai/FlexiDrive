import 'package:flutter/material.dart';
import 'package:flexidrive/app.dart';

/// Gestiona main dentro de esta parte del flujo.
Future<void> main() async {
  /// Crea una instancia y prepara el estado inicial de `WidgetsFlutterBinding`.
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const App());
}
