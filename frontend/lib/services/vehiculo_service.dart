import 'dart:convert';
import 'package:flutter/services.dart';

/// Servicio que simula un backend para FlexiDrive
/// Trabaja con JSON + ArrayList (List en Dart) en memoria
class VehiculoService {
  // ArrayList en memoria - "Base de datos" local
  List<Map<String, dynamic>> vehiculos = [];
  List<Map<String, dynamic>> usuarios = [];
  List<Map<String, dynamic>> rentas = [];
  List<Map<String, dynamic>> resenas = [];

  bool loaded = false; // Controla si ya cargamos el JSON

  /// Inicializa los datos desde el archivo JSON
  Future<void> init() async {
    if (loaded) return;

    // Carga el archivo JSON desde assets
    final response =
        await rootBundle.loadString('assets/data/vehiculos_data.json');

    final data = json.decode(response);

    // Cargar ArrayList de vehículos desde JSON
    vehiculos = List<Map<String, dynamic>>.from(data['vehiculos']);

    // Cargar ArrayList de usuarios desde JSON
    usuarios = List<Map<String, dynamic>>.from(data['usuarios']);

    // Cargar ArrayList de rentas desde JSON
    rentas = List<Map<String, dynamic>>.from(data['rentas']);

    // Cargar ArrayList de reseñas desde JSON
    resenas = List<Map<String, dynamic>>.from(data['reseñas']);

    loaded = true;
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
