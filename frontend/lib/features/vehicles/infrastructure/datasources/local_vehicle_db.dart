import 'package:flexidrive/core/api/api_client.dart';
// Modelos de vehiculos
import 'package:flexidrive/features/vehicles/domain/entities/vehicle_models.dart';

// Base de datos local de vehiculos
class LocalVehicleDb {
  // Constructor privado para singleton
  LocalVehicleDb._();

  // Instancia unica de la base de datos
  static final LocalVehicleDb instance = LocalVehicleDb._();

  // Ya cargamos los datos?
  bool? _loaded = false;

  // Lista de vehiculos en memoria
  final List<VehicleModel> vehicles = [];

  // Carga los vehiculos desde JSON si no estan cargados
  Future<void> loadIfNeeded() async {
    // Si ya cargamos, no hacemos nada
    if (_loaded == true) return;

    // Limpiamos la lista y cargamos los nuevos datos
    vehicles
      ..clear()
      ..addAll(
        _parseList(await _loadList('vehicles'), VehicleModel.fromJson),
      );

    // Marcamos como cargado
    _loaded = true;
  }

  // Convierte una lista dinamica a lista tipada
  List<T> _parseList<T>(
    dynamic source,
    T Function(Map<String, dynamic>) parser,
  ) {
    // Si source es null o no es lista, retornamos lista vacia
    final raw = (source as List<dynamic>? ?? const []);
    // Convertimos cada item usando el parser (fromJson)
    return raw.map((item) => parser(item as Map<String, dynamic>)).toList();
  }

  /// Carga los datos necesarios para cargar lista.
  Future<List<dynamic>> _loadList(String endpoint) =>
      ApiClient.instance.getList(endpoint);
}
