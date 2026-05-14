import 'dart:async';
import 'dart:convert';

import 'package:flexidrive/core/api/api_client.dart';
import 'package:flexidrive/features/reservations/domain/entities/reservation_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Base de datos local para reservas
// Maneja el almacenamiento local de datos de reservas
class LocalReservationDb {
  // Constructor privado para patron singleton
  LocalReservationDb._();

  // Instancia unica de la clase (patron singleton)
  static final LocalReservationDb instance = LocalReservationDb._();
  static const _reservationsOverridesKey = 'local_reservations_created_v1';

  // Indica si los datos ya fueron cargados
  bool? _loaded = false;

  // Lista de reservas almacenadas localmente
  final List<ReservationModel> reservations = [];
  final List<ReservationModel> _createdReservations = [];

  // Carga los datos solo si es necesario
  Future<void> loadIfNeeded() async {
    if (_loaded == true) return;
    await forceReload();
  }

  // Recarga forzada desde API + overrides locales
  Future<void> forceReload() async {
    final apiReservations = _parseList(
      await _safeLoadList('reservations'),
      ReservationModel.fromJson,
    );
    final createdReservations = await _loadReservationOverrides();

    final mergedById = <int, ReservationModel>{
      for (final reservation in apiReservations) reservation.id: reservation,
    };
    for (final reservation in createdReservations) {
      mergedById[reservation.id] = reservation;
    }

    reservations
      ..clear()
      ..addAll(mergedById.values);
    _createdReservations
      ..clear()
      ..addAll(createdReservations);

    _loaded = true;
  }

  List<T> _parseList<T>(
    dynamic source,
    T Function(Map<String, dynamic>) parser,
  ) {
    final raw = (source as List<dynamic>? ?? const []);
    return raw.map((item) => parser(item as Map<String, dynamic>)).toList();
  }

  Future<List<dynamic>> _loadList(String endpoint) =>
      ApiClient.instance.getList(endpoint);

  Future<List<dynamic>> _safeLoadList(String endpoint) async {
    try {
      return await _loadList(endpoint).timeout(const Duration(seconds: 6));
    } catch (_) {
      return const [];
    }
  }

  // Agrega una nueva reserva con persistencia local
  Future<void> addReservation(ReservationModel reservation) async {
    await loadIfNeeded();
    ReservationModel model;
    try {
      final created = await ApiClient.instance
          .postMap('reservations', reservation.toJson());
      model = ReservationModel.fromJson(created);
    } catch (_) {
      model = reservation;
    }
    await _upsertReservation(model);
  }

  // Actualiza una reserva existente con persistencia local
  Future<void> updateReservation(ReservationModel reservation) async {
    await loadIfNeeded();
    ReservationModel model = reservation;
    try {
      final updated = await ApiClient.instance.patchMap(
        'reservations/${reservation.id}',
        reservation.toJson(),
      );
      if (updated.isNotEmpty) {
        model = ReservationModel.fromJson(updated);
      }
    } catch (_) {
      model = reservation;
    }
    await _upsertReservation(model);
  }

  void addReservationLocally(ReservationModel reservation) {
    final index = reservations.indexWhere((item) => item.id == reservation.id);
    if (index == -1) {
      reservations.add(reservation);
    } else {
      reservations[index] = reservation;
    }

    final createdIndex =
        _createdReservations.indexWhere((item) => item.id == reservation.id);
    if (createdIndex == -1) {
      _createdReservations.add(reservation);
    } else {
      _createdReservations[createdIndex] = reservation;
    }
    unawaited(_saveReservationOverrides());
  }

  Future<void> _upsertReservation(ReservationModel reservation) async {
    final index = reservations.indexWhere((item) => item.id == reservation.id);
    if (index == -1) {
      reservations.add(reservation);
    } else {
      reservations[index] = reservation;
    }

    final createdIndex =
        _createdReservations.indexWhere((item) => item.id == reservation.id);
    if (createdIndex == -1) {
      _createdReservations.add(reservation);
    } else {
      _createdReservations[createdIndex] = reservation;
    }

    await _saveReservationOverrides();
  }

  Future<List<ReservationModel>> _loadReservationOverrides() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_reservationsOverridesKey);
    if (raw == null || raw.isEmpty) return <ReservationModel>[];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return <ReservationModel>[];
      return decoded
          .whereType<Map>()
          .map(
            (item) => ReservationModel.fromJson(
              item.map((key, value) => MapEntry(key.toString(), value)),
            ),
          )
          .toList();
    } catch (_) {
      return <ReservationModel>[];
    }
  }

  Future<void> _saveReservationOverrides() async {
    final prefs = await SharedPreferences.getInstance();
    final created = _createdReservations
        .map((reservation) => reservation.toJson())
        .toList();
    await prefs.setString(_reservationsOverridesKey, jsonEncode(created));
  }
}
