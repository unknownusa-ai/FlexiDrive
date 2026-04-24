// Para trabajar con JSON
import 'dart:convert';
// Para leer archivos locales
import 'package:flutter/services.dart';
// Modelos de categorías de carros
import 'package:flexidrive/models/catalogs/catalog_models.dart';

// Servicio que simula un backend
// En realidad todo está en JSON local, pero parece un backend real
class VehiculoService {
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
    final rawVehicles = await _loadList('assets/data/operations/vehicles.json');

    // Convertimos al formato viejo que usa la app
    vehiculos = rawVehicles.map((v) => _mapVehicleToLegacyFormat(v)).toList();

    // Cargamos usuarios
    usuarios = await _loadList('assets/data/accounts/users.json');

    // Cargamos rentas
    rentas = await _loadList('assets/data/operations/reservations.json');

    // Cargamos reseñas
    resenas = await _loadList('assets/data/operations/reviews.json');

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
      'imagen': v['imagen'], // Imagen siempre viene del JSON
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

  Future<List<Map<String, dynamic>>> _loadList(String assetPath) async {
    final response = await rootBundle.loadString(assetPath);
    final decoded = json.decode(response) as List<dynamic>? ?? const [];
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
    final nuevoId = vehiculos.isEmpty ? 1 : vehiculos.last['id'] + 1;
    vehiculo['id'] = nuevoId;
    vehiculos.add(vehiculo);
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
