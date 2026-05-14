abstract class RepositorioVehiculosPuerto {
  Future<void> inicializar();
  List<Map<String, dynamic>> obtenerVehiculos();
  Map<String, dynamic>? obtenerVehiculoPorId(int id);
  Future<void> agregarVehiculo(Map<String, dynamic> vehiculo);
  void actualizarVehiculo(int id, Map<String, dynamic> nuevosDatos);
  void eliminarVehiculo(int id);
  List<Map<String, dynamic>> obtenerVehiculosPorCategoria(String categoria);
  List<Map<String, dynamic>> obtenerVehiculosPorUbicacion(String ubicacion);
  List<Map<String, dynamic>> obtenerVehiculosPorPropietario(int propietarioId);
  List<Map<String, dynamic>> buscarVehiculos(String query);
  List<Map<String, dynamic>> obtenerUsuarios();
  Map<String, int> contarVehiculosPorCategoria();
  double obtenerPromedioPrecios();
}
