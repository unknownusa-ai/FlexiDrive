import 'dart:async';

import 'package:flutter/material.dart';

import 'core/theme/flexi_drive_app.dart';
import 'services/accounts/local_account_repository.dart';
import 'services/catalogs/local_catalog_db.dart';
import 'services/publications/local_publication_db.dart';
import 'services/reservations/local_reservation_db.dart';
import 'services/reviews/local_review_db.dart';
import 'services/vehiculo_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const FlexiDriveApp());

  unawaited(_warmUpApiCaches());
}

Future<void> _warmUpApiCaches() async {
  final tasks = <Future<void> Function()>[
    () => LocalAccountRepository().init(),
    () => VehiculoService().init(),
    () => LocalPublicationDb.instance.loadIfNeeded(),
    () => LocalReviewDb.instance.loadIfNeeded(),
    () => LocalReservationDb.instance.loadIfNeeded(),
    () => LocalCatalogDb.instance.loadIfNeeded(),
  ];

  await Future.wait(
    tasks.map(
      (task) async {
        try {
          await task();
        } catch (error) {
          debugPrint('FlexiDrive startup cache skipped: $error');
        }
      },
    ),
  );
}
