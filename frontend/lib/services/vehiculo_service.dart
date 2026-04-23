import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flexidrive/services/catalogs/local_catalog_db.dart';
import 'package:flexidrive/models/catalogs/catalog_models.dart';

/// Servicio que simula un backend para FlexiDrive
/// Trabaja con JSON + ArrayList (List en Dart) en memoria
class VehiculoService {
  // ArrayList en memoria - "Base de datos" local
  List<Map<String, dynamic>> vehiculos = [];
  List<Map<String, dynamic>> usuarios = [];
  List<Map<String, dynamic>> rentas = [];
  List<Map<String, dynamic>> resenas = [];
  List<VehicleCategoryModel> categories = [];

  bool loaded = false; // Controla si ya cargamos el JSON

  /// Inicializa los datos desde el archivo JSON
  Future<void> init() async {
    if (loaded) return;

    // Cargar ArrayList de vehículos desde JSON (28 vehículos)
    final rawVehicles = await _loadList('assets/data/operations/vehicles.json');
    
    // Mapear campos del nuevo JSON al formato legacy
    vehiculos = rawVehicles.map((v) {
      final mapped = _mapVehicleToLegacyFormat(v);
      print('DEBUG: Vehículo ${mapped['id']} asignado a ${mapped['ubicacion']}');
      return mapped;
    }).toList();

    // Cargar ArrayList de usuarios desde JSON consolidado
    usuarios = await _loadList('assets/data/accounts/users.json');

    // Cargar ArrayList de rentas desde JSON consolidado
    rentas = await _loadList('assets/data/operations/reservations.json');

    // Cargar ArrayList de reseñas desde JSON consolidado
    resenas = await _loadList('assets/data/operations/reviews.json');

    loaded = true;
  }

  /// Mapea un vehículo del formato operations al formato legacy
  Map<String, dynamic> _mapVehicleToLegacyFormat(Map<String, dynamic> v) {
    final categoryId = v['categoria_vehiculo_id'] as int;
    String categoryName = 'Sedán'; // Default
    
    // Mapeo simple de categorías sin dependencias complejas
    switch (categoryId) {
      case 1: categoryName = 'Sedán'; break;
      case 2: categoryName = 'SUV'; break;
      case 3: categoryName = 'Compacto'; break;
      case 4: categoryName = 'Premium'; break;
      case 5: categoryName = 'Pickup'; break;
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
      'puertos': v['asientos'],
      'precio_hora': 15000 + (vehicleId * 1000), // Precio determinista
      'precio_dia': 120000 + (vehicleId * 10000), // Precio determinista
      'precio_semana': 750000 + (vehicleId * 50000), // Precio determinista
      'ubicacion': ciudad, // Ciudad asignada correctamente
      'propietario_id': 1,
      'imagen': 'assets/imagenes_carros/cx5.jpg', // Imagen fija
      'descripcion': v['descripcion'],
      'calificacion': 4.5 + (vehicleId % 5) * 0.1, // Rating entre 4.5-4.9
      'resenas': vehicleId * 5, // Reseñas simuladas
      'disponible': true,
      'combustible': v['tipo_combustible'],
      'aire_acondicionado': v['aire_acondicionado'] ?? true,
    };
  }

  String _asignarCiudadPorVehiculoId(int vehicleId) {
    // Distribuir vehículos entre las 6 ciudades principales
    final ciudades = ['Bogotá', 'Medellín', 'Cali', 'Barranquilla', 'Cartagena', 'Bucaramanga'];
    
    // Usar módulo para distribuir equitativamente
    final index = (vehicleId - 1) % ciudades.length;
    return ciudades[index];
  }

  String _extractBrandFromLine(String linea) {
    // Extraer marca de la línea (ej: "Mazda 3 Touring" -> "Mazda")
    final parts = linea.split(' ');
    return parts.isNotEmpty ? parts.first : 'Toyota';
  }

  int _getRandomPrice() {
    // Precios entre 15000 y 80000
    return 15000 + (DateTime.now().millisecond % 65001);
  }

  String _getRandomLocation() {
    final locations = ['Bogotá', 'Medellín', 'Cali', 'Barranquilla', 'Cartagena', 'Bucaramanga'];
    return locations[DateTime.now().millisecond % locations.length];
  }

  int _getRandomOwnerId() {
    return 1 + (DateTime.now().millisecond % 10);
  }

  String _getRandomImage() {
    final images = [
      'assets/imagenes_carros/cx5.jpg',
      'assets/imagenes_carros/corolla.jpg',
      'assets/imagenes_carros/Renault-Sandero.jpg',
      'assets/imagenes_carros/mercedes.jpg',
      'assets/imagenes_carros/porsche.jpg',
      'assets/imagenes_carros/tesla.jpg',
    ];
    return images[DateTime.now().millisecond % images.length];
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
    return vehiculos.where((v) => v['propietario_id'] == propietarioId).toList();
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
