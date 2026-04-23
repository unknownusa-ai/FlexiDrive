import 'dart:convert';

import 'package:flutter/services.dart';

import 'package:flexidrive/models/accounts/account_models.dart';

class LocalAccountDb {
  LocalAccountDb._();

  static final LocalAccountDb instance = LocalAccountDb._();

  bool? _loaded = false;

  final List<UserModel> users = [];
  final List<UserPreferenceModel> preferences = [];
  final List<String> referenceCities = [];

  bool get isLoaded => _loaded == true;

  Future<void> loadIfNeeded() async {
    if (_loaded == true) return;

    final rawUsers = await _loadList('assets/data/accounts/users.json');
    final rawPreferences = await _loadList(
      'assets/data/accounts/user_preferences.json',
    );
    final rawCities = await _loadList('assets/data/accounts/reference_cities.json');

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

  Future<List<dynamic>> _loadList(String assetPath) async {
    final sanitizedPath = assetPath.trim().replaceAll('"', '').replaceAll("'", '');
    final rawJson = await rootBundle.loadString(sanitizedPath);
    return (json.decode(rawJson) as List<dynamic>? ?? const []);
  }

  int nextUserId() {
    if (users.isEmpty) return 1;
    final maxId = users.map((u) => u.id).reduce((a, b) => a > b ? a : b);
    return maxId + 1;
  }

  int nextPreferenceId() {
    if (preferences.isEmpty) return 1;
    final maxId = preferences.map((p) => p.id).reduce((a, b) => a > b ? a : b);
    return maxId + 1;
  }
}
