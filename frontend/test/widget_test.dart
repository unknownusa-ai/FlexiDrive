import 'package:flutter_test/flutter_test.dart';

import 'package:flexidrive/core/theme/flexi_drive_app.dart';

void main() {
  testWidgets('FlexiDrive app starts', (WidgetTester tester) async {
    await tester.pumpWidget(const FlexiDriveApp());
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
