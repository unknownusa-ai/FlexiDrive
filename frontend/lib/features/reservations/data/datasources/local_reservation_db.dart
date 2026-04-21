import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/reservation_models.dart';

class LocalReservationDb {
  LocalReservationDb._();

  static final LocalReservationDb instance = LocalReservationDb._();

  bool? _loaded = false;

  final List<ReservationModel> reservations = [];

  Future<void> loadIfNeeded() async {
    if (_loaded == true) return;

    final rawJson = await rootBundle.loadString('assets/data/operations_data.json');
    final decoded = json.decode(rawJson) as Map<String, dynamic>;

    reservations
      ..clear()
      ..addAll(_parseList(decoded['reserva'], ReservationModel.fromJson));

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
