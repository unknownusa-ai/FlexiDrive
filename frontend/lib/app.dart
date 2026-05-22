import 'package:flutter/material.dart';
import 'package:flexidrive/core/theme/flexi_drive_app.dart';

/// Define la responsabilidad de `App` dentro de este módulo.
class App extends StatelessWidget {
  /// Crea una instancia y prepara el estado inicial de `App`.
  const App({super.key});

  /// Construye y devuelve el widget correspondiente a esta sección.
  @override
  Widget build(BuildContext context) {
    return const FlexiDriveApp();
  }
}
