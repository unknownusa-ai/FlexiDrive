import 'package:flexidrive/features/vehicles/domain/ports/repositorio_vehiculos_puerto.dart';
import 'package:flexidrive/features/vehicles/infrastructure/services/servicio_vehiculo.dart';

class RepositorioVehiculosLocal implements RepositorioVehiculosPuerto {
  RepositorioVehiculosLocal({VehiculoService? origen})
      : _origen = origen ?? VehiculoService();

  final VehiculoService _origen;

  @override
  Future<void> inicializar() async {
    await _origen.init();
  }

  @override
  List<Map<String, dynamic>> obtenerVehiculos() => _origen.getVehiculos();

  @override
  Map<String, dynamic>? obtenerVehiculoPorId(int id) =>
      _origen.getVehiculoById(id);

  @override
  Future<void> agregarVehiculo(Map<String, dynamic> vehiculo) {
    return _origen.addVehiculo(vehiculo);
  }

  @override
  void actualizarVehiculo(int id, Map<String, dynamic> nuevosDatos) {
    _origen.updateVehiculo(id, nuevosDatos);
  }

  @override
  void eliminarVehiculo(int id) {
    _origen.deleteVehiculo(id);
  }

  @override
  List<Map<String, dynamic>> obtenerVehiculosPorCategoria(String categoria) {
    return _origen.getVehiculosByCategoria(categoria);
  }

  @override
  List<Map<String, dynamic>> obtenerVehiculosPorUbicacion(String ubicacion) {
    return _origen.getVehiculosByUbicacion(ubicacion);
  }

  @override
  List<Map<String, dynamic>> obtenerVehiculosPorPropietario(int propietarioId) {
    return _origen.getVehiculosByPropietario(propietarioId);
  }

  @override
  List<Map<String, dynamic>> buscarVehiculos(String query) {
    return _origen.buscarVehiculos(query);
  }

  @override
  List<Map<String, dynamic>> obtenerUsuarios() => _origen.getUsuarios();

  @override
  Map<String, int> contarVehiculosPorCategoria() {
    return _origen.contarVehiculosPorCategoria();
  }

  @override
  double obtenerPromedioPrecios() => _origen.getPromedioPrecios();

  VehiculoService get origen => _origen;
}
