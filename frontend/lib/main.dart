import 'package:flutter/material.dart';
import 'core/theme/flexi_drive_app.dart';
import 'services/accounts/local_account_repository.dart';
import 'services/vehiculo_service.dart';
import 'services/publications/local_publication_db.dart';
import 'services/reviews/local_review_db.dart';
import 'services/reservations/local_reservation_db.dart';
import 'services/catalogs/local_catalog_db.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar todas las bases de datos ANTES de iniciar la app
  await LocalAccountRepository().init();
  await VehiculoService().init();
  await LocalPublicationDb.instance.loadIfNeeded();
  await LocalReviewDb.instance.loadIfNeeded();
  await LocalReservationDb.instance.loadIfNeeded();
  await LocalCatalogDb.instance.loadIfNeeded();
  
  runApp(const FlexiDriveApp());
}
