import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flexidrive/app.dart';
import 'package:flexidrive/injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const App());

  unawaited(_warmUpDependencies());
}

Future<void> _warmUpDependencies() async {
  try {
    await InjectionContainer.instance.warmUp();
  } catch (error) {
    debugPrint('FlexiDrive startup cache skipped: $error');
  }
}
