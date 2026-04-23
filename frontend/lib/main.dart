import 'package:flutter/material.dart';
import 'core/theme/flexi_drive_app.dart';
import 'services/accounts/local_account_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalAccountRepository().init();
  runApp(const FlexiDriveApp());
}
