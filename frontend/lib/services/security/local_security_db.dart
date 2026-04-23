import 'dart:convert';

import 'package:flutter/services.dart';

import 'package:flexidrive/models/security/security_models.dart';

class LocalSecurityDb {
  LocalSecurityDb._();

  static final LocalSecurityDb instance = LocalSecurityDb._();

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
}
