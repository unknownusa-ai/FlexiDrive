import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/vehicle_models.dart';

class LocalVehicleDb {
  LocalVehicleDb._();

  static final LocalVehicleDb instance = LocalVehicleDb._();

  bool? _loaded = false;

  final List<VehicleModel> vehicles = [];

  Future<void> loadIfNeeded() async {
    if (_loaded == true) return;

    final rawJson = await rootBundle.loadString('assets/data/operations_data.json');
    final decoded = json.decode(rawJson) as Map<String, dynamic>;

    vehicles
      ..clear()
      ..addAll(_parseList(decoded['vehiculo'], VehicleModel.fromJson));

    _loaded = true;
  }

  List<T> _parseList<T>(
    dynamic source,
    T Function(Map<String, dynamic>) parser,
  ) {
    final raw = (source as List<dynamic>? ?? const []);
    return raw.map((item) => parser(item as Map<String, dynamic>)).toList();
  }
}
