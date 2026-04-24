// Importamos Flutter - esto es lo básico para cualquier app
import 'package:flutter/material.dart';
// Nuestra app principal con los temas
import 'core/theme/flexi_drive_app.dart';
// Servicios para manejar usuarios
import 'services/accounts/local_account_repository.dart';
// Para los carros y eso
import 'services/vehiculo_service.dart';
// Para las publicaciones de renta
import 'services/publications/local_publication_db.dart';
// Sistema de reseñas
import 'services/reviews/local_review_db.dart';
// Para saber quién está logueado hacen los usuarios
import 'services/reservations/local_reservation_db.dart';
// Catálogos de bancos, tipos de pago, etc.
import 'services/catalogs/local_catalog_db.dart';

// Acá empieza todo - el main de la app
Future<void> main() async {
  // Esto inicializa Flutter - siempre va primero
  WidgetsFlutterBinding.ensureInitialized();

  // Cargamos todas las bases de datos antes de mostrar la app
  // Si no hacemos esto, la app se ve vacía al inicio
  await LocalAccountRepository().init();
  await VehiculoService().init();
  await LocalPublicationDb.instance.loadIfNeeded();
  await LocalReviewDb.instance.loadIfNeeded();
  await LocalReservationDb.instance.loadIfNeeded();
  await LocalCatalogDb.instance.loadIfNeeded();

  // Ya con todo cargado, arrancamos la app
  runApp(const FlexiDriveApp());
}
