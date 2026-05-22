import 'package:flexidrive/features/vehicles/domain/entities/vehicle_models.dart';
import 'package:flexidrive/features/vehicles/domain/ports/vehicle_catalog_repository_port.dart';

/// Caso de uso para consultar el catálogo tipado de vehículos.
class VehicleCatalogUseCase {
  /// Crea una instancia y prepara el estado inicial de `VehicleCatalogUseCase`.
  VehicleCatalogUseCase(this._repository);

  final VehicleCatalogRepositoryPort _repository;

  /// Carga los datos necesarios para cargar if needed.
  Future<void> loadIfNeeded() => _repository.loadIfNeeded();

  List<VehicleModel> get vehicles => _repository.vehicles;
}
