import 'package:flexidrive/core/api/api_client.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
// Modelos de categorías de carros
import 'package:flexidrive/features/catalogs/domain/entities/catalog_models.dart';
import 'package:flexidrive/core/utils/vehicle_image_resolver.dart';

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
    for (final localVehicle in createdVehicles) {
      final vehicleId =
          _asInt(localVehicle['vehiculo_id'] ?? localVehicle['id']);
      final exists =
          vehiculos.any((item) => _asInt(item['vehiculo_id']) == vehicleId);
      if (!exists) {
        vehiculos.add(localVehicle);
      }
    }

    await _applyPublicationImages();

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
      'imagen': _imageForVehicle(
        vehicleId: vehicleId,
        line: v['linea']?.toString() ?? '',
      ),
      'descripcion': v['descripcion'],
      'calificacion': 4.5 + (vehicleId % 5) * 0.1, // Rating entre 4.5-4.9
      'resenas': vehicleId * 5, // Reseñas simuladas
      'disponible': true,
      'combustible': v['tipo_combustible'],
      'color': v['color'], // Color del vehículo
      'aire_acondicionado': v['aire_acondicionado'] ?? true,
    };
  }

  /// Gestiona asignar ciudad por vehiculo id dentro de esta parte del flujo.
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

  /// Gestiona extract marca desde line dentro de esta parte del flujo.
  String _extractBrandFromLine(String linea) {
    // Extraer marca de la línea (ej: "Mazda 3 Touring" -> "Mazda")
    final parts = linea.split(' ');
    return parts.isNotEmpty ? parts.first : 'Toyota';
  }

  String _imageForVehicle({
    required int vehicleId,
    required String line,
  }) {
    final matchedByName = VehicleImageResolver.assetByVehicleName(line);
    if (matchedByName != null) return matchedByName;

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

  /// Carga los datos necesarios para cargar lista.
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

  /// creación - Agregar nuevo vehículo al ArrayList
  Future<void> addVehiculo(Map<String, dynamic> vehiculo) async {
    await init();

    try {
      final createdVehicleRaw = await ApiClient.instance.postMap(
        'vehicles',
        _toApiVehiclePayload(vehiculo),
      );
      final normalizedRemote = _mapVehicleToLegacyFormat(createdVehicleRaw)
        ..addAll({
          'precio_hora': vehiculo['precio_hora'] ?? 18000,
          'precio_dia': vehiculo['precio_dia'] ?? 150000,
          'precio_semana': vehiculo['precio_semana'] ?? 900000,
          'ubicacion': vehiculo['ubicacion'] ?? 'Bogotá',
          'propietario_id': vehiculo['propietario_id'] ?? 1,
          'imagen': vehiculo['imagen'] ??
              _imageForVehicle(
                vehicleId: _asInt(createdVehicleRaw['vehiculo_id']),
                line: '${createdVehicleRaw['linea'] ?? ''}',
              ),
          'calificacion': vehiculo['calificacion'] ?? 5.0,
          'resenas': vehiculo['resenas'] ?? 0,
          'disponible': vehiculo['disponible'] ?? true,
        });
      final remoteVehicleId = _asInt(createdVehicleRaw['vehiculo_id']);
      if (remoteVehicleId > 0) {
        vehiculo['id'] = remoteVehicleId;
        vehiculo['vehiculo_id'] = remoteVehicleId;
      }
      _upsertVehicle(normalizedRemote);
      return;
    } catch (_) {}

    // Fallback local: generar ID autoincremental para uso offline.
    final maxId = vehiculos
        .map((v) => (v['id'] as num?)?.toInt() ?? 0)
        .fold<int>(0, (current, next) => next > current ? next : current);
    final nuevoId = maxId + 1;
    vehiculo['id'] = nuevoId;
    vehiculo['vehiculo_id'] = nuevoId;
    vehiculo['_is_local_created'] = true;
    _upsertVehicle(vehiculo);
    await _saveCreatedVehicles();
  }

  /// Carga los datos necesarios para cargar created vehicles.
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

  /// Guardar created vehicles esta parte del flujo de trabajo.
  Future<void> _saveCreatedVehicles() async {
    final prefs = await SharedPreferences.getInstance();
    final created = vehiculos
        .where((vehicle) => vehicle['_is_local_created'] == true)
        .toList();
    await prefs.setString(_createdVehiclesKey, jsonEncode(created));
  }

  /// Gestiona apply publicación imágenes dentro de esta parte del flujo.
  Future<void> _applyPublicationImages() async {
    List<Map<String, dynamic>> publications = const [];
    List<Map<String, dynamic>> images = const [];
    try {
      publications = await _loadList('publications');
      images = await _loadList('publication-images');
    } catch (_) {
      return;
    }

    final publicationToVehicle = <int, int>{};
    for (final publication in publications) {
      final publicationId = _asInt(publication['publicacion_id']);
      final vehicleId = _asInt(publication['vehiculo_id']);
      if (publicationId > 0 && vehicleId > 0) {
        publicationToVehicle[publicationId] = vehicleId;
      }
    }

    final imageByVehicle = <int, String>{};
    for (final image in images) {
      final publicationId = _asInt(image['publicacion_id']);
      final vehicleId = publicationToVehicle[publicationId] ?? 0;
      if (vehicleId == 0) continue;

      final rawPath = '${image['url_imagen'] ?? ''}'.trim();
      if (rawPath.isEmpty) continue;

      final isMain = image['es_principal'] == true;
      if (isMain || !imageByVehicle.containsKey(vehicleId)) {
        imageByVehicle[vehicleId] = rawPath;
      }
    }

    if (imageByVehicle.isEmpty) return;
    for (final vehicle in vehiculos) {
      final vehicleId = _asInt(vehicle['vehiculo_id'] ?? vehicle['id']);
      final uploadedPath = imageByVehicle[vehicleId];
      if (uploadedPath == null || uploadedPath.isEmpty) continue;
      vehicle['imagen'] = uploadedPath;
    }
  }

  /// Convierte el vehículo local al formato requerido por la API.
  Map<String, dynamic> _toApiVehiclePayload(Map<String, dynamic> vehiculo) {
    final model = _asInt(vehiculo['anio']);
    return {
      'categoria_vehiculo_id':
          _categoryNameToId('${vehiculo['categoria'] ?? ''}'),
      'linea': '${vehiculo['modelo'] ?? ''}'.trim(),
      'modelo': model == 0 ? DateTime.now().year : model,
      'color': '${vehiculo['color'] ?? 'Negro'}'.trim(),
      'asientos':
          _asInt(vehiculo['asientos']) == 0 ? 5 : _asInt(vehiculo['asientos']),
      'tipo_transmision': '${vehiculo['transmision'] ?? 'Automática'}'.trim(),
      'aire_acondicionado': vehiculo['aire_acondicionado'] == true,
      'tipo_combustible': '${vehiculo['combustible'] ?? 'Combustión'}'.trim(),
      'descripcion': '${vehiculo['descripcion'] ?? ''}'.trim(),
    };
  }

  /// Gestiona category name a id dentro de esta parte del flujo.
  int _categoryNameToId(String categoryName) {
    switch (categoryName.trim()) {
      case 'Sedán':
        return 1;
      case 'SUV':
        return 2;
      case 'Compacto':
      case 'Eléctrico':
        return 3;
      case 'Premium':
      case 'Deportivo':
        return 4;
      case 'Pickup':
        return 5;
      default:
        return 1;
    }
  }

  /// Gestiona upsert vehicle dentro de esta parte del flujo.
  void _upsertVehicle(Map<String, dynamic> vehicle) {
    final vehicleId = _asInt(vehicle['vehiculo_id'] ?? vehicle['id']);
    final index = vehiculos.indexWhere(
      (item) => _asInt(item['vehiculo_id'] ?? item['id']) == vehicleId,
    );
    if (index == -1) {
      vehiculos.add(vehicle);
      return;
    }
    vehiculos[index] = vehicle;
  }

  /// Convierte el valor a entero de forma segura.
  int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }

  /// actualizar - Editar vehículo en el ArrayList
  void updateVehiculo(int id, Map<String, dynamic> nuevosDatos) {
    final index = vehiculos.indexWhere((v) => v['id'] == id);
    if (index != -1) {
      vehiculos[index].addAll(nuevosDatos);
    }
  }

  /// eliminar - Eliminar vehículo del ArrayList
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

  /// Agregar renta esta parte del flujo de trabajo.
  void addRenta(Map<String, dynamic> renta) {
    final nuevoId = rentas.isEmpty ? 1 : rentas.last['id'] + 1;
    renta['id'] = nuevoId;
    rentas.add(renta);
  }

  /// actualizar - Cambiar estado de renta
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

  /// creación - Agregar reseña al ArrayList
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
