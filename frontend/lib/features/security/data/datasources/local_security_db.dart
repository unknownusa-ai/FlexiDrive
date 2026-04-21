import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/security_models.dart';

class LocalSecurityDb {
  LocalSecurityDb._();

  static final LocalSecurityDb instance = LocalSecurityDb._();

  bool? _loaded = false;

  final List<UserSecurityModel> userSecurities = [];
  final List<UserSessionModel> userSessions = [];

  Future<void> loadIfNeeded() async {
    if (_loaded == true) return;

    final rawJson =
        await rootBundle.loadString('assets/data/accounts_payments_data.json');
    final decoded = json.decode(rawJson) as Map<String, dynamic>;

    userSecurities
      ..clear()
      ..addAll(
        _parseList(decoded['seguridad_usuario'], UserSecurityModel.fromJson),
      );
    userSessions
      ..clear()
      ..addAll(
        _parseList(decoded['sesiones_usuario'], UserSessionModel.fromJson),
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
}
