import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/account_models.dart';

class LocalAccountDb {
  LocalAccountDb._();

  static final LocalAccountDb instance = LocalAccountDb._();

  bool? _loaded = false;

  final List<UserModel> users = [];
  final List<UserPreferenceModel> preferences = [];
  final List<String> referenceCities = [];

  Future<void> loadIfNeeded() async {
    if (_loaded == true) return;

    final rawJson =
        await rootBundle.loadString('assets/data/accounts_payments_data.json');
    final decoded = json.decode(rawJson) as Map<String, dynamic>;

    final rawUsers = (decoded['usuarios'] as List<dynamic>? ?? const []);
    final rawPreferences =
        (decoded['preferencias_usuario'] as List<dynamic>? ?? const []);
    final rawCities =
        (decoded['ciudades_referencia'] as List<dynamic>? ?? const []);

    users
      ..clear()
      ..addAll(
        rawUsers.map(
          (item) => UserModel.fromJson(item as Map<String, dynamic>),
        ),
      );

    preferences
      ..clear()
      ..addAll(
        rawPreferences.map(
          (item) =>
              UserPreferenceModel.fromJson(item as Map<String, dynamic>),
        ),
      );

    referenceCities
      ..clear()
      ..addAll(rawCities.map((item) => item.toString()));

    _loaded = true;
  }
}
