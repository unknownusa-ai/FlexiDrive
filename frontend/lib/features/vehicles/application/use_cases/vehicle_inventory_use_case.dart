import 'package:flexidrive/features/vehicles/domain/ports/repositorio_vehiculos_puerto.dart';

/// Define la responsabilidad de `VehicleInventoryUseCase` dentro de este módulo.
class VehicleInventoryUseCase {
  /// Crea una instancia y prepara el estado inicial de `VehicleInventoryUseCase`.
  VehicleInventoryUseCase(this._repository);

  final RepositorioVehiculosPuerto _repository;

  /// Inicializa el flujo de inicialización antes de su uso.
  Future<void> init() => _repository.inicializar();

  List<Map<String, dynamic>> get vehiculos => _repository.obtenerVehiculos();

  List<Map<String, dynamic>> get usuarios => _repository.obtenerUsuarios();

  /// Obtiene la información asociada a obtener vehiculos.
  List<Map<String, dynamic>> getVehiculos() => _repository.obtenerVehiculos();

  /// Obtiene la información asociada a obtener vehiculo por id.
  Map<String, dynamic>? getVehiculoById(int id) {
    return _repository.obtenerVehiculoPorId(id);
  }

  /// Agregar vehiculo esta parte del flujo de trabajo.
  Future<void> addVehiculo(Map<String, dynamic> vehiculo) {
    return _repository.agregarVehiculo(vehiculo);
  }

  /// Actualiza el estado relacionado con actualizar vehiculo.
  void updateVehiculo(int id, Map<String, dynamic> nuevosDatos) {
    _repository.actualizarVehiculo(id, nuevosDatos);
  }

  /// Elimina los datos vinculados a eliminar vehiculo.
  void deleteVehiculo(int id) {
    _repository.eliminarVehiculo(id);
  }

  /// Obtiene la información asociada a obtener vehiculos por categoria.
  List<Map<String, dynamic>> getVehiculosByCategoria(String categoria) {
    return _repository.obtenerVehiculosPorCategoria(categoria);
  }

  /// Obtiene la información asociada a obtener vehiculos por ubicacion.
  List<Map<String, dynamic>> getVehiculosByUbicacion(String ubicacion) {
    return _repository.obtenerVehiculosPorUbicacion(ubicacion);
  }

  /// Obtiene la información asociada a obtener vehiculos por propietario.
  List<Map<String, dynamic>> getVehiculosByPropietario(int propietarioId) {
    return _repository.obtenerVehiculosPorPropietario(propietarioId);
  }

  /// Buscar vehiculos esta parte del flujo de trabajo.
  List<Map<String, dynamic>> buscarVehiculos(String query) {
    return _repository.buscarVehiculos(query);
  }

  /// Gestiona contar vehiculos por categoria dentro de esta parte del flujo.
  Map<String, int> contarVehiculosPorCategoria() {
    return _repository.contarVehiculosPorCategoria();
  }

  /// Obtiene la información asociada a obtener promedio precios.
  double getPromedioPrecios() => _repository.obtenerPromedioPrecios();
}
