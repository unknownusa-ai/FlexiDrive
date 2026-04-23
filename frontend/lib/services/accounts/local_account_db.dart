import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flexidrive/models/accounts/account_models.dart';

class LocalAccountDb {
  LocalAccountDb._();

  static final LocalAccountDb instance = LocalAccountDb._();
  static const _usersOverridesKey = 'accounts_users_overrides_v1';

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
    final rawCities =
        await _loadList('assets/data/accounts/reference_cities.json');

    users
      ..clear()
      ..addAll(
        rawUsers.map(
          (item) => UserModel.fromJson(item as Map<String, dynamic>),
        ),
      );

    final overrides = await _loadUserOverrides();
    for (final override in overrides) {
      final index = users.indexWhere((u) => u.id == override.id);
      if (index == -1) {
        users.add(override);
      } else {
        users[index] = override;
      }
    }

    preferences
      ..clear()
      ..addAll(
        rawPreferences.map(
          (item) => UserPreferenceModel.fromJson(item as Map<String, dynamic>),
        ),
      );

    referenceCities
      ..clear()
      ..addAll(rawCities.map((item) => item.toString()));

    _loaded = true;
  }

  Future<List<dynamic>> _loadList(String assetPath) async {
    final sanitizedPath =
        assetPath.trim().replaceAll('"', '').replaceAll("'", '');
    final rawJson = await rootBundle.loadString(sanitizedPath);
    return (json.decode(rawJson) as List<dynamic>? ?? const []);
  }

  Future<void> saveUserOverride(UserModel user) async {
    await loadIfNeeded();

    final overrides = await _loadUserOverrides();
    final index = overrides.indexWhere((u) => u.id == user.id);

    if (index == -1) {
      overrides.add(user);
    } else {
      overrides[index] = user;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _usersOverridesKey,
      jsonEncode(overrides.map((item) => item.toJson()).toList()),
    );
  }

  Future<List<UserModel>> _loadUserOverrides() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_usersOverridesKey);
    if (raw == null || raw.isEmpty) return <UserModel>[];

    try {
      final decoded = jsonDecode(raw);
      final list = decoded is List ? decoded : const [];
      return list
          .whereType<Map>()
          .map(
            (item) => UserModel.fromJson(
              item.map((key, value) => MapEntry(key.toString(), value)),
            ),
          )
          .toList();
    } catch (_) {
      return <UserModel>[];
    }
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
