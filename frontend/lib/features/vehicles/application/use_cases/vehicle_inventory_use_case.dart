import 'package:flexidrive/features/vehicles/domain/ports/repositorio_vehiculos_puerto.dart';

class VehicleInventoryUseCase {
  VehicleInventoryUseCase(this._repository);

  final RepositorioVehiculosPuerto _repository;

  Future<void> init() => _repository.inicializar();

  List<Map<String, dynamic>> get vehiculos => _repository.obtenerVehiculos();

  List<Map<String, dynamic>> get usuarios => _repository.obtenerUsuarios();

  List<Map<String, dynamic>> getVehiculos() => _repository.obtenerVehiculos();

  Map<String, dynamic>? getVehiculoById(int id) {
    return _repository.obtenerVehiculoPorId(id);
  }

  void addVehiculo(Map<String, dynamic> vehiculo) {
    _repository.agregarVehiculo(vehiculo);
  }

  void updateVehiculo(int id, Map<String, dynamic> nuevosDatos) {
    _repository.actualizarVehiculo(id, nuevosDatos);
  }

  void deleteVehiculo(int id) {
    _repository.eliminarVehiculo(id);
  }

  List<Map<String, dynamic>> getVehiculosByCategoria(String categoria) {
    return _repository.obtenerVehiculosPorCategoria(categoria);
  }

  List<Map<String, dynamic>> getVehiculosByUbicacion(String ubicacion) {
    return _repository.obtenerVehiculosPorUbicacion(ubicacion);
  }

  List<Map<String, dynamic>> getVehiculosByPropietario(int propietarioId) {
    return _repository.obtenerVehiculosPorPropietario(propietarioId);
  }

  List<Map<String, dynamic>> buscarVehiculos(String query) {
    return _repository.buscarVehiculos(query);
  }

  Map<String, int> contarVehiculosPorCategoria() {
    return _repository.contarVehiculosPorCategoria();
  }

  double getPromedioPrecios() => _repository.obtenerPromedioPrecios();
}
