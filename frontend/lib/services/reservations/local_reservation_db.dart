import 'dart:convert';

import 'package:flutter/services.dart';

import 'package:flexidrive/models/reservations/reservation_models.dart';

class LocalReservationDb {
  LocalReservationDb._();

  static final LocalReservationDb instance = LocalReservationDb._();

  bool? _loaded = false;

  final List<ReservationModel> reservations = [];

  Future<void> loadIfNeeded() async {
    if (_loaded == true) return;

    reservations
      ..clear()
      ..addAll(
        _parseList(
          await _loadList('assets/data/operations/reservations.json'),
          ReservationModel.fromJson,
        ),
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
