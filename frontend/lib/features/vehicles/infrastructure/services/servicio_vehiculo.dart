import 'package:flexidrive/core/api/api_client.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
// Modelos de categorías de carros
import 'package:flexidrive/features/catalogs/domain/entities/catalog_models.dart';

// Servicio que simula un backend
// En realidad todo está en JSON local, pero parece un backend real
class VehiculoService {
  static const _createdVehiclesKey = 'local_created_vehicles_v1';
  // Lista de carros en memoria (como un ArrayList de Java)
  List<Map<String, dynamic>> vehiculos = [];
  // Lista de usuarios
  List<Map<String, dynamic>> usuarios = [];
  // Lista de rentas/reservas
  List<Map<String, dynamic>> rentas = [];
  // Lista de reseñas
  List<Map<String, dynamic>> resenas = [];
  // Categorías de vehículos (Sedán, SUV, etc)
  List<VehicleCategoryModel> categories = [];

  // Ya cargamos los datos? (evita cargar dos veces)
  bool loaded = false;

  // Carga todos los datos desde los JSON
  Future<void> init() async {
    // Si ya cargamos, no hacemos nada
    if (loaded) return;

    // Cargamos los carros desde el JSON (28 vehículos)
    final rawVehicles = await _loadList('vehicles');

    // Convertimos al formato viejo que usa la app
    vehiculos = rawVehicles.map((v) => _mapVehicleToLegacyFormat(v)).toList();
    final createdVehicles = await _loadCreatedVehicles();
    vehiculos.addAll(createdVehicles);

    // Cargamos usuarios
    usuarios = await _loadList('users');

    // Cargamos rentas
    rentas = await _loadList('reservations');

    // Cargamos reseñas
    resenas = await _loadList('reviews');

    // Marcamos como cargado
    loaded = true;
  }

  // Convierte un carro del formato nuevo al formato viejo
  // Esto es para compatibilidad con el código anterior
  Map<String, dynamic> _mapVehicleToLegacyFormat(Map<String, dynamic> v) {
    // Tomamos el ID de categoría
    final categoryId = v['categoria_vehiculo_id'] as int;
    // Por defecto es Sedán
    String categoryName = 'Sedán';

    // Mapeo simple de categorías sin dependencias complejas
    switch (categoryId) {
      case 1:
        categoryName = 'Sedán';
        break;
      case 2:
        categoryName = 'SUV';
        break;
      case 3:
        categoryName = 'Compacto';
        break;
      case 4:
        categoryName = 'Premium';
        break;
      case 5:
        categoryName = 'Pickup';
        break;
    }

    final vehicleId = v['vehiculo_id'] as int;

    // Asignar ciudad basada en el ID del vehículo para distribución equitativa
    final ciudad = _asignarCiudadPorVehiculoId(vehicleId);

    return {
      'id': vehicleId,
      'vehiculo_id': vehicleId,
      'marca': _extractBrandFromLine(v['linea'] ?? ''),
      'modelo': v['linea'] ?? '',
      'anio': v['modelo'],
      'categoria': categoryName,
      'transmision': v['tipo_transmision'],
      'asientos': v['asientos'],
      'puertos': v['asientos'], // Compatibilidad legacy
      'precio_hora': 15000 + (vehicleId * 1000), // Precio determinista
      'precio_dia': 120000 + (vehicleId * 10000), // Precio determinista
      'precio_semana': 750000 + (vehicleId * 50000), // Precio determinista
      'ubicacion': ciudad, // Ciudad asignada correctamente
      'propietario_id': 1,
      'imagen': _imageForVehicle(vehicleId),
      'descripcion': v['descripcion'],
      'calificacion': 4.5 + (vehicleId % 5) * 0.1, // Rating entre 4.5-4.9
      'resenas': vehicleId * 5, // Reseñas simuladas
      'disponible': true,
      'combustible': v['tipo_combustible'],
      'color': v['color'], // Color del vehículo
      'aire_acondicionado': v['aire_acondicionado'] ?? true,
    };
  }

  String _asignarCiudadPorVehiculoId(int vehicleId) {
    // Distribuir vehículos entre las 6 ciudades principales
    final ciudades = [
      'Bogotá',
      'Medellín',
      'Cali',
      'Barranquilla',
      'Cartagena',
      'Bucaramanga'
    ];

    // Usar módulo para distribuir equitativamente
    final index = (vehicleId - 1) % ciudades.length;
    return ciudades[index];
  }

  String _extractBrandFromLine(String linea) {
    // Extraer marca de la línea (ej: "Mazda 3 Touring" -> "Mazda")
    final parts = linea.split(' ');
    return parts.isNotEmpty ? parts.first : 'Toyota';
  }

  String _imageForVehicle(int vehicleId) {
    const images = [
      'assets/imagenes_carros/mazda3.jpg',
      'assets/imagenes_carros/corolla.jpg',
      'assets/imagenes_carros/Renault-Sandero.jpg',
      'assets/imagenes_carros/onix.jpeg',
      'assets/imagenes_carros/cx5.jpg',
      'assets/imagenes_carros/tesla.jpg',
    ];
    return images[(vehicleId - 1) % images.length];
  }

  Future<List<Map<String, dynamic>>> _loadList(String endpoint) async {
    final decoded = await ApiClient.instance.getList(endpoint);
    return List<Map<String, dynamic>>.from(decoded);
  }

  // ========== OPERACIONES CRUD ==========

  /// READ - Obtener todos los vehículos (ArrayList)
  List<Map<String, dynamic>> getVehiculos() => vehiculos;

  /// READ - Obtener vehículo por ID
  Map<String, dynamic>? getVehiculoById(int id) {
    try {
      return vehiculos.firstWhere((v) => v['id'] == id);
    } catch (e) {
      return null;
    }
  }

  /// CREATE - Agregar nuevo vehículo al ArrayList
  void addVehiculo(Map<String, dynamic> vehiculo) {
    // Generar ID autoincremental
    final maxId = vehiculos
        .map((v) => (v['id'] as num?)?.toInt() ?? 0)
        .fold<int>(0, (current, next) => next > current ? next : current);
    final nuevoId = maxId + 1;
    vehiculo['id'] = nuevoId;
    vehiculo['vehiculo_id'] = nuevoId;
    vehiculo['_is_local_created'] = true;
    vehiculos.add(vehiculo);
    _saveCreatedVehicles();
  }

  Future<List<Map<String, dynamic>>> _loadCreatedVehicles() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_createdVehiclesKey);
    if (raw == null || raw.isEmpty) return <Map<String, dynamic>>[];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return <Map<String, dynamic>>[];
      return decoded
          .whereType<Map>()
          .map(
            (item) => item.map(
              (key, value) => MapEntry(key.toString(), value),
            ),
          )
          .toList();
    } catch (_) {
      return <Map<String, dynamic>>[];
    }
  }

  void _saveCreatedVehicles() {
    SharedPreferences.getInstance().then((prefs) {
      final created = vehiculos
          .where((vehicle) => vehicle['_is_local_created'] == true)
          .toList();
      prefs.setString(_createdVehiclesKey, jsonEncode(created));
    });
  }

  /// UPDATE - Editar vehículo en el ArrayList
  void updateVehiculo(int id, Map<String, dynamic> nuevosDatos) {
    final index = vehiculos.indexWhere((v) => v['id'] == id);
    if (index != -1) {
      vehiculos[index].addAll(nuevosDatos);
    }
  }

  /// DELETE - Eliminar vehículo del ArrayList
  void deleteVehiculo(int id) {
    vehiculos.removeWhere((v) => v['id'] == id);
  }

  // ========== OPERACIONES DE BÚSQUEDA/FILTRO ==========

  /// Filtrar vehículos por categoría
  List<Map<String, dynamic>> getVehiculosByCategoria(String categoria) {
    return vehiculos.where((v) => v['categoria'] == categoria).toList();
  }

  /// Filtrar vehículos por ubicación
  List<Map<String, dynamic>> getVehiculosByUbicacion(String ubicacion) {
    return vehiculos.where((v) => v['ubicacion'] == ubicacion).toList();
  }

  /// Filtrar vehículos por propietario (arrendatario)
  List<Map<String, dynamic>> getVehiculosByPropietario(int propietarioId) {
    return vehiculos
        .where((v) => v['propietario_id'] == propietarioId)
        .toList();
  }

  /// Buscar vehículos por marca o modelo
  List<Map<String, dynamic>> buscarVehiculos(String query) {
    final lowerQuery = query.toLowerCase();
    return vehiculos.where((v) {
      final marca = v['marca'].toString().toLowerCase();
      final modelo = v['modelo'].toString().toLowerCase();
      return marca.contains(lowerQuery) || modelo.contains(lowerQuery);
    }).toList();
  }

  // ========== OPERACIONES DE USUARIOS ==========

  /// READ - Obtener usuario por ID
  Map<String, dynamic>? getUsuarioById(int id) {
    try {
      return usuarios.firstWhere((u) => u['id'] == id);
    } catch (e) {
      return null;
    }
  }

  /// READ - Obtener todos los usuarios (ArrayList)
  List<Map<String, dynamic>> getUsuarios() => usuarios;

  // ========== OPERACIONES DE RENTAS ==========

  /// READ - Obtener rentas por vehículo
  List<Map<String, dynamic>> getRentasByVehiculo(int vehiculoId) {
    return rentas.where((r) => r['vehiculo_id'] == vehiculoId).toList();
  }

  /// READ - Obtener rentas por estado
  List<Map<String, dynamic>> getRentasByEstado(String estado) {
    return rentas.where((r) => r['estado'] == estado).toList();
  }

  /// CREATE - Agregar renta al ArrayList
  void addRenta(Map<String, dynamic> renta) {
    final nuevoId = rentas.isEmpty ? 1 : rentas.last['id'] + 1;
    renta['id'] = nuevoId;
    rentas.add(renta);
  }

  /// UPDATE - Cambiar estado de renta
  void updateRentaEstado(int rentaId, String nuevoEstado) {
    final index = rentas.indexWhere((r) => r['id'] == rentaId);
    if (index != -1) {
      rentas[index]['estado'] = nuevoEstado;
    }
  }

  // ========== OPERACIONES DE RESEÑAS ==========

  /// READ - Obtener reseñas por vehículo (relación)
  List<Map<String, dynamic>> getResenasByVehiculo(int vehiculoId) {
    // Obtener rentas del vehículo
    final rentasVehiculo = getRentasByVehiculo(vehiculoId);
    final rentaIds = rentasVehiculo.map((r) => r['id']).toList();

    // Filtrar reseñas de esas rentas
    return resenas.where((res) => rentaIds.contains(res['renta_id'])).toList();
  }

  /// CREATE - Agregar reseña al ArrayList
  void addResena(Map<String, dynamic> resena) {
    final nuevoId = resenas.isEmpty ? 1 : resenas.last['id'] + 1;
    resena['id'] = nuevoId;
    resenas.add(resena);
  }

  // ========== ESTADÍSTICAS ==========

  /// Contar vehículos por categoría
  Map<String, int> contarVehiculosPorCategoria() {
    final conteos = <String, int>{};
    for (final vehiculo in vehiculos) {
      final cat = vehiculo['categoria'] as String;
      conteos[cat] = (conteos[cat] ?? 0) + 1;
    }
    return conteos;
  }

  /// Calcular promedio de precios
  double getPromedioPrecios() {
    if (vehiculos.isEmpty) return 0.0;
    final total = vehiculos.fold<int>(
      0,
      (sum, v) => sum + (v['precio_dia'] as int),
    );
    return total / vehiculos.length;
  }
}
