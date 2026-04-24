import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flexidrive/models/security/security_models.dart';

class LocalSecurityDb {
  LocalSecurityDb._();

  static final LocalSecurityDb instance = LocalSecurityDb._();
  static const _securityOverridesKey = 'security_user_overrides_v1';

  bool? _loaded = false;

  final List<UserSecurityModel> userSecurities = [];
  final List<UserSessionModel> userSessions = [];

  Future<void> loadIfNeeded() async {
    if (_loaded == true) return;

    userSecurities
      ..clear()
      ..addAll(
        _parseList(
          await _loadList('assets/data/security/user_security.json'),
          UserSecurityModel.fromJson,
        ),
      );

    final overrides = await _loadSecurityOverrides();
    for (final override in overrides) {
      final index =
          userSecurities.indexWhere((item) => item.userId == override.userId);
      if (index == -1) {
        userSecurities.add(override);
      } else {
        userSecurities[index] = override;
      }
    }

    userSessions
      ..clear()
      ..addAll(
        _parseList(
          await _loadList('assets/data/security/user_sessions.json'),
          UserSessionModel.fromJson,
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

  Future<void> upsertUserSecurity({
    required int userId,
    required bool twoFactorVerification,
    required bool biometricAccess,
  }) async {
    await loadIfNeeded();

    final current =
        userSecurities.where((item) => item.userId == userId).toList();
    final updated = UserSecurityModel(
      id: current.isEmpty ? _nextSecurityId() : current.first.id,
      userId: userId,
      twoFactorVerification: twoFactorVerification,
      biometricAccess: biometricAccess,
    );

    final index = userSecurities.indexWhere((item) => item.userId == userId);
    if (index == -1) {
      userSecurities.add(updated);
    } else {
      userSecurities[index] = updated;
    }

    final overrides = await _loadSecurityOverrides();
    final overrideIndex = overrides.indexWhere((item) => item.userId == userId);
    if (overrideIndex == -1) {
      overrides.add(updated);
    } else {
      overrides[overrideIndex] = updated;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _securityOverridesKey,
      jsonEncode(overrides.map((item) => item.toJson()).toList()),
    );
  }

  int _nextSecurityId() {
    if (userSecurities.isEmpty) return 1;
    final maxId =
        userSecurities.map((item) => item.id).reduce((a, b) => a > b ? a : b);
    return maxId + 1;
  }

  Future<List<UserSecurityModel>> _loadSecurityOverrides() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_securityOverridesKey);
    if (raw == null || raw.isEmpty) return <UserSecurityModel>[];

    try {
      final decoded = jsonDecode(raw);
      final list = decoded is List ? decoded : const [];
      return list
          .whereType<Map>()
          .map(
            (item) => UserSecurityModel.fromJson(
              item.map((key, value) => MapEntry(key.toString(), value)),
            ),
          )
          .toList();
    } catch (_) {
      return <UserSecurityModel>[];
    }
  }
}
