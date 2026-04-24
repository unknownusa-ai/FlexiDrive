// Para trabajar con JSON
import 'dart:convert';
// Para leer archivos locales (assets)
import 'package:flutter/services.dart';
// Modelos de vehiculos
import 'package:flexidrive/models/vehicles/vehicle_models.dart';

// Base de datos local de vehiculos
// Carga los carros desde un archivo JSON y los mantiene en memoria
class LocalVehicleDb {
  // Constructor privado para singleton
  LocalVehicleDb._();

  // Instancia unica de la base de datos
  static final LocalVehicleDb instance = LocalVehicleDb._();

  // Ya cargamos los datos?
  bool? _loaded = false;

  // Lista de vehiculos en memoria
  final List<VehicleModel> vehicles = [];

  // Carga los vehiculos desde JSON si no estan cargados
  Future<void> loadIfNeeded() async {
    // Si ya cargamos, no hacemos nada
    if (_loaded == true) return;

    // Limpiamos la lista y cargamos los nuevos datos
    vehicles
      ..clear()
      ..addAll(
        _parseList(await _loadList('assets/data/operations/vehicles.json'),
            VehicleModel.fromJson),
      );

    // Marcamos como cargado
    _loaded = true;
  }

  // Convierte una lista dinamica a lista tipada
  List<T> _parseList<T>(
    dynamic source,
    T Function(Map<String, dynamic>) parser,
  ) {
    // Si source es null o no es lista, retornamos lista vacia
    final raw = (source as List<dynamic>? ?? const []);
    // Convertimos cada item usando el parser (fromJson)
    return raw.map((item) => parser(item as Map<String, dynamic>)).toList();
  }

  // Carga un archivo JSON desde assets
  Future<List<dynamic>> _loadList(String assetPath) async {
    // Leemos el archivo como texto
    final rawJson = await rootBundle.loadString(assetPath);
    // Decodificamos el JSON y retornamos la lista
    return (json.decode(rawJson) as List<dynamic>? ?? const []);
  }
}
