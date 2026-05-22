import 'package:flexidrive/features/vehicles/domain/entities/vehicle_models.dart';

/// Puerto de dominio para el catálogo de vehículos en formato tipado.
///
/// Este contrato aísla la capa de aplicación de la fuente de datos concreta.
abstract class VehicleCatalogRepositoryPort {
  Future<void> loadIfNeeded();

  List<VehicleModel> get vehicles;
}
