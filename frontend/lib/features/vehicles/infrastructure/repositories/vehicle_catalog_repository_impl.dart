import 'package:flexidrive/features/vehicles/domain/entities/vehicle_models.dart';
import 'package:flexidrive/features/vehicles/domain/ports/vehicle_catalog_repository_port.dart';
import 'package:flexidrive/features/vehicles/infrastructure/datasources/local_vehicle_db.dart';

/// Adaptador para exponer el catálogo tipado de vehículos.
class VehicleCatalogRepositoryImpl implements VehicleCatalogRepositoryPort {
  VehicleCatalogRepositoryImpl({LocalVehicleDb? source})
      : _source = source ?? LocalVehicleDb.instance;

  final LocalVehicleDb _source;

  /// Carga los datos necesarios para cargar if needed.
  @override
  Future<void> loadIfNeeded() => _source.loadIfNeeded();

  @override
  List<VehicleModel> get vehicles => _source.vehicles;
}
