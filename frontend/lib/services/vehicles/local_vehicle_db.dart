import 'dart:convert';

import 'package:flutter/services.dart';

import 'package:flexidrive/models/vehicles/vehicle_models.dart';

class LocalVehicleDb {
  LocalVehicleDb._();

  static final LocalVehicleDb instance = LocalVehicleDb._();

  bool? _loaded = false;

  final List<VehicleModel> vehicles = [];

  Future<void> loadIfNeeded() async {
    if (_loaded == true) return;

    vehicles
      ..clear()
      ..addAll(
        _parseList(await _loadList('assets/data/operations/vehicles.json'), VehicleModel.fromJson),
      );

    _loaded = true;
  }

  List<T> _parseList<T>(
    dynamic source,
    T Function(Map<String, dynamic>) parser,
  ) {
    final raw = (source as List<dynamic>? ?? const []);
    return raw.map((item) => parser(item as Map<String, dynamic>)).toList();
  }

  Future<List<dynamic>> _loadList(String assetPath) async {
    final rawJson = await rootBundle.loadString(assetPath);
    return (json.decode(rawJson) as List<dynamic>? ?? const []);
  }
}
