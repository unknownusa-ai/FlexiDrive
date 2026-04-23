import 'dart:convert';

import 'package:flutter/services.dart';

import 'package:flexidrive/models/notifications/notification_models.dart';

class LocalNotificationDb {
  LocalNotificationDb._();

  static final LocalNotificationDb instance = LocalNotificationDb._();

  bool? _loaded = false;

  final List<NotificationModel> notifications = [];

  Future<void> loadIfNeeded() async {
    if (_loaded == true) return;

    notifications
      ..clear()
      ..addAll(
        _parseList(
          await _loadList('assets/data/operations/notifications.json'),
          NotificationModel.fromJson,
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
