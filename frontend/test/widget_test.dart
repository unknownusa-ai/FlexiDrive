import 'package:flutter_test/flutter_test.dart';

import 'package:flexidrive/core/theme/flexi_drive_app.dart';

/// Punto de entrada de pruebas básicas del frontend.
void main() {
  /// Verifica que la aplicación principal se renderiza sin excepciones.
  testWidgets('FlexiDrive inicia correctamente', (WidgetTester tester) async {
    await tester.pumpWidget(const FlexiDriveApp());
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
