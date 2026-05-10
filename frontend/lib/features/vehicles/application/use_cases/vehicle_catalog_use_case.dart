import 'package:flexidrive/features/vehicles/domain/entities/vehicle_models.dart';
import 'package:flexidrive/features/vehicles/infrastructure/datasources/local_vehicle_db.dart';

class VehicleCatalogUseCase {
  VehicleCatalogUseCase(this._source);

  final LocalVehicleDb _source;

  Future<void> loadIfNeeded() => _source.loadIfNeeded();

  List<VehicleModel> get vehicles => _source.vehicles;
}
