import 'package:flexidrive/features/vehicles/domain/ports/repositorio_vehiculos_puerto.dart';
import 'package:flexidrive/features/vehicles/infrastructure/services/servicio_vehiculo.dart';

/// Define la responsabilidad de `RepositorioVehiculosLocal` dentro de este módulo.
class RepositorioVehiculosLocal implements RepositorioVehiculosPuerto {
  RepositorioVehiculosLocal({VehiculoService? origen})
      : _origen = origen ?? VehiculoService();

  final VehiculoService _origen;

  /// Gestiona inicializar dentro de esta parte del flujo.
  @override
  Future<void> inicializar() async {
    await _origen.init();
  }

  /// Obtiene la información asociada a obtener vehiculos.
  @override
  List<Map<String, dynamic>> obtenerVehiculos() => _origen.getVehiculos();

  /// Obtiene la información asociada a obtener vehiculo por id.
  @override
  Map<String, dynamic>? obtenerVehiculoPorId(int id) =>
      _origen.getVehiculoById(id);

  /// Agregar vehiculo esta parte del flujo de trabajo.
  @override
  Future<void> agregarVehiculo(Map<String, dynamic> vehiculo) {
    return _origen.addVehiculo(vehiculo);
  }

  /// Actualiza el estado relacionado con actualizar vehiculo.
  @override
  void actualizarVehiculo(int id, Map<String, dynamic> nuevosDatos) {
    _origen.updateVehiculo(id, nuevosDatos);
  }

  /// Elimina los datos vinculados a eliminar vehiculo.
  @override
  void eliminarVehiculo(int id) {
    _origen.deleteVehiculo(id);
  }

  /// Obtiene la información asociada a obtener vehiculos por categoria.
  @override
  List<Map<String, dynamic>> obtenerVehiculosPorCategoria(String categoria) {
    return _origen.getVehiculosByCategoria(categoria);
  }

  /// Obtiene la información asociada a obtener vehiculos por ubicacion.
  @override
  List<Map<String, dynamic>> obtenerVehiculosPorUbicacion(String ubicacion) {
    return _origen.getVehiculosByUbicacion(ubicacion);
  }

  /// Obtiene la información asociada a obtener vehiculos por propietario.
  @override
  List<Map<String, dynamic>> obtenerVehiculosPorPropietario(int propietarioId) {
    return _origen.getVehiculosByPropietario(propietarioId);
  }

  /// Buscar vehiculos esta parte del flujo de trabajo.
  @override
  List<Map<String, dynamic>> buscarVehiculos(String query) {
    return _origen.buscarVehiculos(query);
  }

  /// Obtiene la información asociada a obtener usuarios.
  @override
  List<Map<String, dynamic>> obtenerUsuarios() => _origen.getUsuarios();

  /// Gestiona contar vehiculos por categoria dentro de esta parte del flujo.
  @override
  Map<String, int> contarVehiculosPorCategoria() {
    return _origen.contarVehiculosPorCategoria();
  }

  /// Obtiene la información asociada a obtener promedio precios.
  @override
  double obtenerPromedioPrecios() => _origen.getPromedioPrecios();

  VehiculoService get origen => _origen;
}
